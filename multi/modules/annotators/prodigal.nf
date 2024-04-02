process prodigal {
	container "docker://quay.io/biocontainers/prodigal:2.6.3--h031d066_8"

	input:
	tuple val(sample), path(genome_fasta)

	output:
	tuple val(sample), path("${sample.id}/${sample.id}.faa"), emit: proteins
	tuple val(sample), path("${sample.id}/${sample.id}.ffn"), emit: genes
	tuple val(sample), path("${sample.id}/${sample.id}.gff"), emit: genome_annotation

	script:
	def gunzip_cmd = (genome_fasta.name.endsWith(".gz")) ? "gzip -dc ${genome_fasta} > \$(basename ${genome_fasta} .gz)" : ""
	def outdir = "annotations/prodigal/${sample.id}"
	"""
	mkdir -p ${outdir}
	${gunzip_cmd}
	prodigal -i \$(basename ${genome_fasta} .gz) -f gff -o ${outdir}/${sample.id}.gff -a ${outdir}/${sample.id}.faa -d ${outdir}/${sample.id}.ffn
	"""
}
