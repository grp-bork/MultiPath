params.annotation = [:]
params.annotation.prokka = [:]
params.annotation.prokka.kingdom = "Bacteria"
params.annotation.prokka.genus = "Genus"

process prokka {
	container "docker://quay.io/biocontainers/prokka:1.14.6--pl5321hdfd78af_5"

	input:
	tuple val(sample), path(genome_fasta)

	output:
	tuple val(sample), path("annotations/prokka/${sample.id}/${sample.id}.faa"), emit: proteins
	tuple val(sample), path("annotations/prokka/${sample.id}/${sample.id}.ffn"), emit: genes
	tuple val(sample), path("annotations/prokka/${sample.id}/${sample.id}.fna"), emit: genome
	tuple val(sample), path("annotations/prokka/${sample.id}/${sample.id}.gff"), emit: gff

	script:
	"""
	mkdir -p annotations/prokka/${sample.id}/
	prokka --cpus ${task.cpus} --outdir prokka_out/ --prefix ${sample.id} --kingdom ${params.annotation.prokka.kingdom} --genus ${params.annotation.prokka.genus} ${genome_fasta}

	mv -v prokka_out/* annotations/prokka/${sample.id}/
	"""
	
}