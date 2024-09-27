process unicycler {
	container "quay.io/biocontainers/unicycler:0.4.4--py38h5cf8b27_6"
	label "compute_xlarge"
	cpus 64

	input:
	tuple val(sample), path(short_reads), path(long_reads)

	output:
	tuple val(sample), path("assemblies/unicycler/${sample.id}/${sample.id}.unicycler.fasta"), emit: assembly_fasta

	script:

	def long_read_files = []
	def r1_files = []
	def r2_files = []
	def orphan_files = []
	r1_files.addAll(short_reads.findAll( { it.name.endsWith("_R1.fastq.gz") && !it.name.matches("(.*)(singles|orphans|chimeras)(.*)") } ))
	r2_files.addAll(short_reads.findAll( { it.name.endsWith("_R2.fastq.gz") } ))
	orphan_files.addAll(short_reads.findAll( { it.name.matches("(.*)(singles|orphans|chimeras)(.*)") } ))
	long_read_files.addAll(long_reads.findAll( { it.name != "LONG_READ_DUMMY_INPUT" }))

	def input_files = ""
	if (r1_files.size() != 0) {
		input_files += "-1 ${r1_files.join(' ')}"
	}
	if (r2_files.size() != 0) {
		input_files += " -2 ${r2_files.join(' ')}"
	}
	if (orphan_files.size() != 0) {
		input_files += " -s ${orphan_files.join(' ')}"
	}
	if (long_read_files.size() > 0) {
		input_files += " -l ${long_read_files.join(' ')}"
	}
		
	"""
	mkdir -p assemblies/unicycler/${sample.id}/ unicycler_out/

	unicycler -t ${task.cpus} -o unicycler_out/ ${input_files}
	mv -v unicycler_out/assembly.fasta assemblies/unicycler/${sample.id}/${sample.id}.unicycler.fasta
	"""
	


}