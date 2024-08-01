# MultiPath workflow
<table>
  <tr width="100%">
    <td width="150px">
      <a href="https://www.bork.embl.de/"><img src="https://www.bork.embl.de/assets/img/normal_version.png" alt="Bork Group Logo" width="150px" height="auto"></a>
    </td>
    <td width="425px" align="center">
      <b>Developed by the <a href="https://www.bork.embl.de/">Bork Group</a> in collaboration with <a href="https://www.ufz.de/">UFZ</a></b><br>
      Raise an <a href="https://github.com/grp-bork/MultiPath/issues">issue</a> or <a href="mailto:N4M@embl.de">contact us</a><br><br>
      See our <a href="https://www.bork.embl.de/services.html">other Software & Services</a>
    </td>
    <td width="250px">
      Contributors:<br>
      <ul>
        <li>
          <a href="https://github.com/cschu/">Christian Schudoma</a> <a href="https://orcid.org/0000-0003-1157-1354"><img src="https://orcid.org/assets/vectors/orcid.logo.icon.svg" alt="ORCID icon" width="20px" height="20px"></a><br>
        </li>
        <li>
          <a href="https://github.com/mahdi-robbani/">Mahdi Robbani</a> <a href="https://orcid.org/0000-0003-0161-0559"><img src="https://orcid.org/assets/vectors/orcid.logo.icon.svg" alt="ORCID icon" width="20px" height="20px"></a><br>
        </li>
        <li>
          <a href="https://github.com/danielpodlesny/">Daniel Podlesny</a> <a href="https://orcid.org/0000-0002-5685-0915"><img src="https://orcid.org/assets/vectors/orcid.logo.icon.svg" alt="ORCID icon" width="20px" height="20px"></a><br>
        </li>
      </ul>
    </td>
    <td width="250px">
      Collaborators:<be>
      <ul>
        <li>
          <a href="https://github.com/stefaniamagg/">Stefanía Magnúsdóttir</a> <a href="https://orcid.org/0000-0001-6506-8696"><img src="https://orcid.org/assets/vectors/orcid.logo.icon.svg" alt="ORCID icon" width="20px" height="20px"></a><br>
        </li>
        <li>
          <a href="https://www.ufz.de/index.php?en=43142">Ulisses Nunes da Rocha</a> <a href="https://orcid.org/0000-0001-6972-6692"><img src="https://orcid.org/assets/vectors/orcid.logo.icon.svg" alt="ORCID icon" width="20px" height="20px"></a><br>
        </li>
      </ul>
    </td>
  </tr>
  <tr>
    <td colspan="4" align="center">The development of this workflow was supported by <a href="https://www.nfdi4microbiota.de/">NFDI4Microbiota <img src="https://github.com/user-attachments/assets/1e78f65e-9828-46c0-834c-0ed12ca9d5ed" alt="NFDI4Microbiota icon" width="20px" height="20px"></a> 
</td>
  </tr>
</table>

---
#### Description
The `MultiPath workflow` is a multi-omics workflow for the integration of multi-omics data of microbial species. The [workflow](https://github.com/mdsufz/MULTI) was originally developed at the Helmholtz Centre for Environmental Research GmbH (UFZ) within the `UC-Multi` use case for [NFDI4Microbiota](https://nfdi4microbiota.de/). `MultiPath` is a nextflow port developed at EMBL Heidelberg, powered by the independent [nevermore](https://github.com/cschu/nevermore) workflow component library.

#### Citation
This workflow: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.13143222.svg)](https://doi.org/10.5281/zenodo.13143222)

---
# Overview
![MultiPath Workflow Schema](https://raw.githubusercontent.com/grp-bork/MultiPath/main/docs/multipath.svg)


---
# Requirements

We recommend running `MultiPath` with Docker/Singularity. By default, it makes use of the biocontainers versions of its dependencies (with the exception of `bwa`/`samtools`, s. below)

## Essential/Mandatory

* `Unicycler`
* `prodigal`
* `salmon`
* `carveme`
* `memote` (note that nextflow versions >= 23 have problems with the `memote` container, see usage)
* `seqtk`

## Optional

* `bbmap` (`bbduk`, `reformat`)
* `kraken2`
* `sortmeRNA`
* `FastQC`
* `MultiQC`

---
# Usage
## Cloud-based Workflow Manager (CloWM)
This workflow will be available on the CloWM platform (coming soon).

## Command-Line Interface (CLI)
The workflow run is controlled by environment-specific parameters (see [run.config](https://github.com/grp-bork/MultiPath/blob/main/config/run.config)) and study-specific parameters (see [params.yml](https://github.com/grp-bork/MultiPath/blob/main/config/params.yml)). The parameters in the `params.yml` can be specified on the command line as well.

You can either clone this repository from GitHub and run it as follows
```
git clone https://github.com/grp-bork/MultiPath.git
nextflow run /path/to/MultiPath [-resume] -c /path/to/run.config -params-file /path/to/params.yml
```

Or, you can have nextflow pull it from github and run it from the `$HOME/.nextflow` directory.
```
nextflow run grp-bork/MultiPath [-resume] -c /path/to/run.config -params-file /path/to/params.yml
```

## Input files
Fastq files are supported and can be either uncompressed (but shouldn't be!) or compressed with `gzip` or `bzip2`. Sample data must be arranged in one directory per sample.

### Per-sample input directories
All files in a sample directory will be associated with the name of the sample folder. Paired-end mate files need to have matching prefixes. Mates 1 and 2 can be specified with suffixes `_[12]`, `_R[12]`, `.[12]`, `.R[12]`. Lane IDs or other read id modifiers have to precede the mate identifier. Files with names not containing either of those patterns will be assigned to be single-ended. Samples consisting of both single and paired end files are assumed to be paired end with all single end files being orphans (quality control survivors). 


