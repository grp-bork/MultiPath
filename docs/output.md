Workflow Output
===============

A successful run of `MultiPath` will generate the following outputs.

## Outputs

* `<sample>.unicycler.fasta` -- a set of (circular) contigs assembled by Unicycler
* `<sample>.ffn`, `<sample>.faa`, `<sample>.gff`  -- Prodigal gene predictions and sequences of predicted genes and proteins 
* `<sample>.carveme.xml` -- CarveMe metabolic network reconstruction
* Memote model benchmarking (note: when running memote from a Docker/Singularity container, this requires a Nextflow version < 23 (for whatever reason.))
* Salmon gene expression quantification against the Prodigal-predicted genes (if input includes transcriptomics data)

