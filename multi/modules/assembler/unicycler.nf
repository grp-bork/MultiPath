process unicycler {

	input:
	tuple val(sample), path(short_reads), path(long_reads)

	// output:

	script:

	def long_read_files = []
	def r1_files = []
	def r2_files = []
	def orphan_files = []
	r1_files.addAll(fastqs.findAll( { it.name.endsWith("_R1.fastq.gz") && !it.name.matches("(.*)(singles|orphans|chimeras)(.*)") && it.name.matches("(.*)metaG(.*)") } ))
	r2_files.addAll(fastqs.findAll( { it.name.endsWith("_R2.fastq.gz") && it.name.matches("(.*)metaG(.*)") } ))
	orphan_files.addAll(fastqs.findAll( { it.name.matches("(.*)(singles|orphans|chimeras)(.*)") && it.name.matches("(.*)metaG(.*)") } ))
	long_read_files.addAll(long_reads.findAll( { it.name != "NO_INPUT" }))

	def input_files = ""
	if (r1_files.size() != 0) {
		input_files += "-1 ${r1_files.join(' ')}"
	}
	if (r2_files.size() != 0) {
		input_files += " -2 ${r2_files.join(' ')}"
	}
	if (orphans.size() != 0) {
		input_files += " -s ${orphans.join(' ')}"
	}
	if (long_read_files.size() > 0) {
		input_files += " -l ${long_read_files.join(',')}"
	}
		
	"""
	mkdir -p assemblies/unicycler/${sample.id}/

	unicycler -t ${task.cpus} -o assemblies/unicycler/${sample.id}/ ${input_files}
	"""
	


}