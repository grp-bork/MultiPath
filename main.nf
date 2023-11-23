#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { nevermore_main } from "./nevermore/workflows/nevermore"
// include { gffquant_flow } from "./nevermore/workflows/gffquant"
// include { fastq_input } from "./nevermore/workflows/input"
include { metaT_input; metaG_input; assembly_prep } from "./multi/workflows/input"

// include { rnaspades; metaspades } from "./imp/modules/assemblers/spades"
// include { bwa_index } from "./imp/modules/alignment/indexing/bwa_index"
// include { extract_unmapped } from "./imp/modules/alignment/extract"

// include { metaT_assembly } from "./imp/workflows/meta_t"
// include { assembly_prep } from "./imp/workflows/input"
// include { hybrid_megahit } from "./imp/modules/assemblers/megahit"
// include { get_unmapped_reads } from "./imp/workflows/extract"
// include { concatenate_contigs; filter_fastq } from "./imp/modules/assemblers/functions"

include { unicycler } from "./multi/modules/assembler/unicycler"
include { prokka } from "./multi/modules/annotators/prokka"
include { carveme } from "./multi/modules/annotators/carveme"
include { memote } from "./multi/modules/reports/memote"
include { salmon_index; salmon_quant } from "./multi/modules/profilers/salmon"

// if (params.input_dir && params.remote_input_dir) {
// 	log.info """
// 		Cannot process both --input_dir and --remote_input_dir. Please check input parameters.
// 	""".stripIndent()
// 	exit 1
// } else if (!params.input_dir && !params.remote_input_dir) {
// 	log.info """
// 		Neither --input_dir nor --remote_input_dir set.
// 	""".stripIndent()
// 	exit 1
// }

// each sample has at most 2 groups of files: [2 x PE, 1 x orphan], [1 x singles]


def input_dir = (params.input_dir) ? params.input_dir : params.remote_input_dir

params.remote_input_dir = false

params.assembler = "megahit"


workflow {

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

	nevermore_main(nvm_input_ch)


	empty_file = file("${launchDir}/NO_INPUT")
	empty_file.text = "NOTHING TO SEE HERE."
	print empty_file

	long_reads_ch = Channel.of(empty_file)

	assembly_prep(
		nevermore_main.out.fastqs
			// .filter { it[0].library_source == "metaG" }
	)

	metaG_assembly_ch = assembly_prep.out.reads
		.filter { it[0].library_source == "metaG" }
		.map { sample, fastqs -> return tuple(sample.id, sample, fastqs) }
		.groupTuple(by: 0, size: 2, remainder: true)
		.map { sample_id, sample, short_reads -> 
			def new_sample = [:]
			new_sample.id = sample_id
			new_sample.library_source = "metaG"
			new_sample.library = sample[0].library
			return tuple(new_sample, [short_reads].flatten(), [empty_file])
		}


	metaG_assembly_ch.dump(pretty: true, tag: "metaG_hybrid_input")

	unicycler(metaG_assembly_ch)

	prokka(unicycler.out.assembly_fasta)

	salmon_index(prokka.out.genes)
	salmon_index.out.index.dump(pretty: true, tag: "salmon_index.out.index")

	carveme(
		prokka.out.proteins,
		(params.annotation.carveme.media_db) ?: "${projectDir}/assets/carveme/media_db.tsv"
	)

	memote(carveme.out.model)

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
		.map { index_id, sample, reads, index -> return tuple(sample, reads, index)}
		)		

	metaT_quant_ch.dump(pretty: true, tag: "metaT_quant_ch")

	salmon_quant(metaT_quant_ch)
	salmon_quant.out.quant.dump(pretty: true, tag: "salmon_quant.out.quant")


}
