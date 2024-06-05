Usage
=====


### General Usage


```
nextflow run /path/to/multipath --rna_input_dir </path/to/meta_t_data> --dna_input_dir </path/to/meta_g_data> [--long_reads_input_dir </path/to/long/reads>] --output_dir [PARAMETERS]
```

### Input data

* Fastq files need to be ordered into a sample-per-folder structure (s. tree below).
* Supported file endings are `.fastq,.fq,.fastq.gz,.fq.gz,.fastq.bz2,.fq.bz2`
* Files in sample-specific folders will automatically be assigned to a sample labeled with the folder name.
* Filenames for paired-end data need to share a common prefix terminated by `_R?[12]` in order to be automatically matched. 
* Suffixes following the `_R?[12]` pattern, such as `_001` from newer Illumina machines need to be removed.
* In case of paired-end data with additional unpaired reads (e.g. as obtained from preprocessed ENA datasets), the unpaired files can be automatically picked up from the same folder but should be labeled as `<sample_prefix>.single(s).<fastq-suffix>`. 

In the following example, the paths to the input datasets need to be set as `--rna_input_dir /path/to/input/rnaseq --dna_input_dir /path/to/input/dnaseq`. nevermoreIMP will then automatically detect the sample-specific folders within those directories. Long reads (DNA!) can be supplied with `--long_reads_dir /path/to/input/long_reads`.

```
/path/to/input
├── dnaseq
│   └── sample1
│       ├── sample1_R1.fastq.gz
│       └── sample2_R2.fastq.gz
└── rnaseq
│   └── sample1
│       ├── sample1_R1.fastq.gz
│       └── sample1_R2.fastq.gz
└── long_reads
    └── sample1
        └── sample1_long.fastq.gz
```

### MEMOTE/Singularity 

The final model benchmarking step with [MEMOTE](https://memote.readthedocs.io/en/latest/) causes problems when running Nextflow >= 23. We therefore disabled this step from running automatically. You can instruct the workflow to run MEMOTE anyway via the `--run_memote` parameter.



### Parameters

* `run_preprocessing [true]`

  Run preprocessing (quality control, [human] host removal, rRNA removal.)

* `remove_host [true]`

  Run host removal.

* `drop_orphans [false]`

  Drop paired-end reads whose mate did not survive quality processing.

* `qc_minlen [45]`

  Drop reads shorter than `qc_minlen` base pairs.

* `qc_params_shotgun ["qtrim=rl trimq=3 maq=25 ktrim=r k=23 mink=11 hdist=1 ftm=5 entropy=0.5 entropywindow=50 entropyk=5 tpe tbo"]`

  bbduk parameter string

* `remove_host_kraken2_db`

  Path to a kraken2 database for host removal

* `kraken2_min_hit_groups [10]`

  kraken2 sensitivity cutoff

* `run_sortmerna [false]`

  Run rRNA removal.

* `sortmerna_db`

  Path to a sortmerna database (fasta file).

* `subsample_percentile`

  Set to an integer value in (0, 100) to set RNAseq downsampling percentile.

* `subsample_random_seed [313]`

  Set random seed of seqtk's random number generator for subsampling.


