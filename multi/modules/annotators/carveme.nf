params.annotation.carveme.solver = "scip"
params.annotation.carveme.gapfill_model = "M3"
params.annotation.carveme.media_db = ""


process carveme {
	input:
	tuple val(sample), path(proteins)
	path(mediadb)

	output:
	tuple val(sample), path("carveme/${sample.id}/${sample.id}.carveme.xml"), emit: "model"

	script:
	def g_param = "-g ${params.annotation.carveme.gapfill_model}"
	"""
	mkdir -p carveme/${sample.id}/

	carve --solver ${params.annotation.carveme.solver} --cobra --mediadb ${mediadb} ${g_param} --output carveme/${sample.id}/${sample.id}.carveme.xml ${proteins}
	"""
	// python /home/magnusdo/.conda/envs/carvemep37/lib/python3.7/site-packages/carveme/cli/carve.py -g M3 --mediadb /work/magnusdo/magRecons/media_db.tsv /work/magnusdo/evoniche/mags/annotations/"$MAG" --cobra --threads "$2" --output /work/magnusdo/evoniche/reconstructions/"${MAG/.faa/.xml}"
}