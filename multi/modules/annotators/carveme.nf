params.annotation.carveme.solver = "scip"

process carveme {
	input:
	tuple val(sample), path(proteins)

	output:
	tuple val(sample), path("carveme/${sample.id}/${sample.id}.carveme.xml"), emit: "model"

	script:
	"""
	mkdir -p carveme/${sample.id}/

	carve --solver ${params.annotation.carveme.solver} --output carveme/${sample.id}/${sample.id}.carveme.xml ${proteins}
	"""
}