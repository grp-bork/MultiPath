process calculate_library_size_cutoff {
	input:
	path(readcounts)

	output:
	val(libsize_cutoff)

	script:
	"""
	nlibs=\$(cat ${readcounts} | wc -l)
	cat ${readcounts} | sort -k1,1g | awk -v nlibs=\$nlibs 'BEGIN {q75=int(nlibs*0.75 + 0.5)} NR<q75 {print;}' | awk '{sum+=\$1} END {printf("%d\\", sum/NR) }' > file
	"""
	// cat ${readcounts} | sort -k1,1g | awk -v nlibs=\$nlibs 'BEGIN {q75=int(nlibs*0.75 + 0.5)} NR<q75 {sum+=$1; n+=1;} END {printf("%d\n",sum/n) }'
}