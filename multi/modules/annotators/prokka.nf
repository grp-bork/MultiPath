params.annotation.prokka.kingdom = "Bacteria"
params.annotation.prokka.genus = "Genus"

process prokka {

	input:
	tuple val(sample), path(genome_fasta)

	script:
	"""
	mkdir -p annotations/prokka/${sample.id}/ prokka_out/
	prokka --cpus ${task.cpus} --outdir prokka_out/ --prefix ${sample.id} --kingdom ${params.annotation.prokka.kingdom} --genus ${params.annotation.prokka.genus} ${genome_fasta}
	"""
	prokka \
    --outdir /work/magnusdo/bfr/workflow/05_prokka/ \
    --force \
    --prefix L1436 \
    --kingdom Bacteria \
    --genus Listeria \
    --cpus 8 \
    /work/magnusdo/bfr/workflow/04_unicycler/1436/assembly.fasta
}