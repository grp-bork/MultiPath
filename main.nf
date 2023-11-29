#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { nevermore_main } from "./nevermore/workflows/nevermore"
include { metaT_input; metaG_input; assembly_prep } from "./multi/workflows/input"

include { unicycler } from "./multi/modules/assembler/unicycler"
include { prokka } from "./multi/modules/annotators/prokka"
include { carveme } from "./multi/modules/annotators/carveme"
include { memote } from "./multi/modules/reports/memote"
include { salmon_index; salmon_quant } from "./multi/modules/profilers/salmon"

params.run_qa = true


workflow {

	// input short reads
	nvm_input_ch = Channel.empty()
	metaT_ch = Channel.empty()
	if (params.metaT_input_dir) {
		metaT_input(
			Channel.fromPath(params.metaT_input_dir + "/*", type: "dir")
		)
		metaT_ch = metaT_input.out.reads
		nvm_input_ch = nvm_input_ch.concat(metaT_ch)
	}
	metaG_ch = Channel.empty()
	if (params.metaG_input_dir) {
		metaG_input(
			Channel.fromPath(params.metaG_input_dir + "/*", type: "dir")
		)
		metaG_ch = metaG_input.out.reads
		nvm_input_ch = nvm_input_ch.concat(metaG_ch)
	}
	//

	// preprocessing
	nevermore_main(nvm_input_ch)

	// collect all fastq files for a sample and identify related fastqs via sample id
	assembly_prep(nevermore_main.out.fastqs)

	// TODO: long reads
	long_reads_ch = Channel.empty()
	if (params.long_reads_input_dir) {
		long_reads_ch = Channel.fromPath(params.long_reads_input_dir + "/**.{fq.gz,fastq.gz}")
			.map { file ->
				return tuple(file.getParent().getName(), file)
			}
			.groupTuple(by: 0)
		long_reads_ch.dump(pretty: true, tag: "long_reads_ch")

	} // else {

	empty_file = file("${workDir}/NO_INPUT")
	empty_file.text = "NOTHING TO SEE HERE."
		// long_reads_ch = Channel.of(empty_file)
	// }

	// get the WGS reads for genome assembly
	metaG_assembly_ch = assembly_prep.out.reads
		.filter { it[0].library_source == "metaG" }
		.map { sample, fastqs -> return tuple(sample.id, sample, fastqs) }
		.groupTuple(by: 0, size: 2, remainder: true)
		.map { sample_id, sample, short_reads -> 
			def new_sample = [:]
			new_sample.id = sample_id.replaceAll(/\.metaG/, "")
			new_sample.library_source = "metaG"
			new_sample.library = sample[0].library
			// return tuple(new_sample, [short_reads].flatten(), [empty_file])
			return tuple(new_sample.id, new_sample, [short_reads].flatten())
		}
		.join(long_reads_ch, by: 0, remainder: true)
		.map { sample_id, sample, short_reads, long_reads ->
			return tuple(sample, short_reads, [long_reads ?= empty_file])
		}

	metaG_assembly_ch.dump(pretty: true, tag: "metaG_hybrid_input")

	// run genome assembly
	unicycler(metaG_assembly_ch)

	// annotate genome
	prokka(unicycler.out.assembly_fasta)

	// generate salmon index from annotated genes
	salmon_index(prokka.out.genes)
	salmon_index.out.index.dump(pretty: true, tag: "salmon_index.out.index")

	// metabolic network reconstruction from proteins
	carveme(
		prokka.out.proteins,
		(params.annotation.carveme.media_db) ?: "${projectDir}/assets/carveme/media_db.tsv"
	)

	// benchmarking metabolic network model
	memote(carveme.out.model)

	// get the RNAseq reads ready for gene quantification
	metaT_quant_ch = assembly_prep.out.reads
		.filter { it[0].library_source == "metaT" }
		.map { sample, fastqs -> return tuple(sample.id, sample, fastqs) }
		.groupTuple(by: 0, size: 2, remainder: true)
		.map { sample_id, sample, short_reads -> 
			def new_sample = [:]
			new_sample.id = sample_id
			new_sample.index_id = sample_id.replaceAll(/\.metaT/, "")
			new_sample.library_source = "metaT"
			new_sample.library = sample[0].library
			return tuple(new_sample.index_id, new_sample, [short_reads].flatten())
		}
		.combine(
			salmon_index.out.index
				.map { sample, index ->
					return tuple(sample.id.replaceAll(/\.metaG/, ""), index)
				},
			by: 0
		)		
		.map { index_id, sample, reads, index -> return tuple(sample, reads, index)}
	metaT_quant_ch.dump(pretty: true, tag: "metaT_quant_ch")

	// run gene quantification
	salmon_quant(metaT_quant_ch)
	salmon_quant.out.quant.dump(pretty: true, tag: "salmon_quant.out.quant")	

}
