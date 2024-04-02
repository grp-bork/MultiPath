process memote {
	container "docker://quay.io/biocontainers/memote:0.17.0--pyhdfd78af_0"

	input:
	tuple val(sample), path(model)

	output:
	path("reports/memote/${sample.id}/*"), emit: report

	script:

	"""
	mkdir -p reports/memote/${sample.id}

	memote report snapshot --filename reports/memote/${sample.id}/${sample.id}.html ${model}
	"""

}