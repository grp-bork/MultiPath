process memote {

	input:
	tuple val(sample), path(model)

	output:
	path("reports/memote/${sample.id}/*"), emit: report

	script:

	"""
	mkdir -p reports/memote/${sample.id}

	memote --filename reports/memote/${sample.id}.html ${model}
	"""

}