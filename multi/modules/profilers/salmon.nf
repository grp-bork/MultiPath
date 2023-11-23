params.profilers.salmon.k = 31

process salmon_index {
	input:
	tuple val(sample), path(genes)

	output:
	tuple val(sample), path("salmon/index/${sample.id}/${sample.id}*"), emit: index

	script:
	"""
	mkdir -p salmon/index/${sample.id}/

	salmon index -t ${genes} -i salmon/index/${sample.id}/${sample.id} -k ${params.profilers.salmon.k}

	"""

}

// > ./bin/salmon index -t transcripts.fa -i transcripts_index --decoys decoys.txt -k 31
