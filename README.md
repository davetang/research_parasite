## Table of Contents

- [Research parasite](#research-parasite)
  - [Conda](#conda)
  - [Sequence Read Archive](#sequence-read-archive)
    - [NCBI sralite.1](#ncbi-sralite1)
    - [Useful resources](#useful-resources)
  - [Aspera Connect](#aspera-connect)
  - [European Nucleotide Archive](#european-nucleotide-archive)
  - [DNA Data Bank of Japan](#dna-data-bank-of-japan)
  - [NCBI Datasets](#ncbi-datasets)
  - [Metadata](#metadata)
    - [Entrez Direct](#entrez-direct)
    - [ffq](#ffq)
    - [ffs](#ffs)
  - [fetchngs](#fetchngs)
  - [Example](#example)

# Research parasite

[Research parasites](https://www.nejm.org/doi/10.1056/NEJMe1516564) are:

> people who had nothing to do with the design and execution of the study but
> use another group's data for their own ends, possibly stealing from the
> research productivity planned by the data gatherers, or even use the data to
> try to disprove what the original investigators had posited.

In the interests of science, we should never ever reuse data or heaven forbid, try to disprove each other. This repository contains notes on how research parasites may download your data. To protect yourself as a "front-line researcher" you should never deposit your data to any of the following resources (or publish your research, for that matter) or risk being proven wrong by someone who re-analysed your data with more appropriate and/or updated methodology or worse yet, risk having your data contribute to your field of research.

## Conda

With tools like [Conda](https://docs.conda.io/en/latest/), it is an uphill
battle against research parasites. Conda makes it easy to install the necessary
tools to download data from various sources. Since Conda can become very slow
when solving dependencies, one should use
[Mamba](https://github.com/mamba-org/mamba), which is a faster version of
Conda, and create new environments for a set of tools.

Below are some useful tools for downloading sequencing data that can be
installed using Conda/Mamba into a new environment called research_parasite.

```console
mamba create \
   -n research_parasite \
   -c Bioconda -c conda-forge \
   parallel-fastq-dump awscli sra-tools entrez-direct

conda activate research_parasite
```

## Sequence Read Archive

The [Sequence Read Archive](https://www.ncbi.nlm.nih.gov/sra) (SRA) is the
largest publicly available repository of high throughput sequencing data. If
you generate sequencing data, remember not to deposit it here since it is quite
easy to [download data from the
SRA](https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/).

There are [four hierarchical
levels](https://www.ncbi.nlm.nih.gov/sra/docs/srasearch/) of SRA entities and
their accessions (where `#` indicates a sequence of numbers):

1. STUDY with accessions in the form of SRP#, ERP#, or DRP#
2. SAMPLE with accessions in the form of SRS#, ERS#, or DRS#
3. EXPERIMENT with accessions in the form of SRX#, ERX#, or DRX#
4. RUN with accessions in the form of SRR#, ERR#, or DRR#

You would first have to [install the SRA
Toolkit](https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit),
which is simply downloading a tarball (and adding the `bin` directory to your
`PATH`) or by using [Conda](#conda).

For example, a research parasite using CentOS can simply download the tarball
and use the toolkit.

```console
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-centos_linux64.tar.gz
tar -xzf sratoolkit.current-centos_linux64.tar.gz
```

On Debian/Ubuntu.

```console
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz
tar -xzf sratoolkit.current-ubuntu64.tar.gz
```

The executables are stored in `sratoolkit.3.0.1-centos_linux64/bin` and to test
that the toolkit is functional, run the following command. (Your command may
differ depending on the extracted directory.) The `--stdout` option will output
the data to stdout. `-X` specifies the maximum number of spots to download.
[SRR390728](https://www.ncbi.nlm.nih.gov/sra/?term=SRR390728) is the SRA Run
ID.

```console
time sratoolkit.3.0.1-centos_linux64/bin/fastq-dump --stdout -X 2 SRR390728
# Read 2 spots for SRR390728
# Written 2 spots for SRR390728
# @SRR390728.1 1 length=72
# CATTCTTCACGTAGTTCTCGAGCCTTGGTTTTCAGCGATGGAGAATGACTTTGACAAGCTGAGAGAAGNTNC
# +SRR390728.1 1 length=72
# ;;;;;;;;;;;;;;;;;;;;;;;;;;;9;;665142;;;;;;;;;;;;;;;;;;;;;;;;;;;;;96&&&&(
# @SRR390728.2 2 length=72
# AAGTAGGTCTCGTCTGTGTTTTCTACGAGCTTGTGTTCCAGCTGACCCACTCCCTGGGTGGGGGGACTGGGT
# +SRR390728.2 2 length=72
# ;;;;;;;;;;;;;;;;;4;;;;3;393.1+4&&5&&;;;;;;;;;;;;;;;;;;;;;<9;<;;;;;464262
# 
# real    0m23.184s
# user    0m0.465s
# sys     0m0.097s
```

The entire run can be downloaded by simply providing the SRA Run ID to
`fastq-dump`.

```console
time sratoolkit.3.0.1-centos_linux64/bin/fastq-dump SRR390728
# Read 7178576 spots for SRR390728
# Written 7178576 spots for SRR390728
# 
# real    15m22.349s
# user    3m16.858s
# sys     0m22.203s
```

The `prefetch` command can be used to sequence files in the compressed SRA
format.

```console
time sratoolkit.3.0.1-centos_linux64/bin/prefetch SRR390728
# snipped
# real    9m7.301s
# user    0m17.872s
# sys     0m9.246s
```

`fasterq-dump` can be used to convert the prefetched Runs from compressed SRA
format to FASTQ.

```console
time sratoolkit.3.0.1-centos_linux64/bin/fasterq-dump --split-files SRR390728.sra
# spots read      : 7,178,576
# reads read      : 14,357,152
# reads written   : 14,357,152
# 
# real    0m25.232s
# user    0m53.398s
# sys     0m7.542s
```

`fasterq-dump` can be used in a single step to download FASTQ files, which is
faster than using `fastq-dump`.

```console
time ../sratoolkit.3.0.1-centos_linux64/bin/fasterq-dump --split-files SRR390728
# spots read      : 7,178,576
# reads read      : 14,357,152
# reads written   : 14,357,152
# 
# real    7m3.119s
# user    2m12.225s
# sys     0m21.876s
```

[parallel-fastq-dump](https://github.com/rvalieris/parallel-fastq-dump), which
is not part of the SRA Toolkit, can be used to download blocks in parallel;
blocks can be specified by using `-N` (Minimum spot id) and `-X` (Maximum spot
id). The recommended way to install `parallel-fastq-dump` is by using Conda (or
Mamba); see the [Conda](#conda) section above. I have omitted the `--gzip`
option to make a fairer comparison of the timing between `fastq-dump` and
`fasterq-dump`, which did not gzip the output.

```console
conda activate research_parasite
time parallel-fastq-dump --sra-id SRR390728 --threads 8 --outdir out/ --split-files
```

Unfortunately, `parallel-fastq-dump` hung and I stopped the job.

I found that the fastest way a research parasite can download your SRA data is
via AWS. This requires the [AWS Command Line
Interface](https://aws.amazon.com/cli/) and [SRA
Toolkit](https://github.com/ncbi/sra-tools), which can be installed using
[Conda](#conda). The data is downloaded in the `sra` format and `fasterq-dump`
is used to convert `sra` to FASTQ.

Note that no AWS credentials are needed, which is why `--no-sign-request` is
used so that credentials will not be loaded.

```console
conda activate research_parasite

time aws s3 sync s3://sra-pub-run-odp/sra/SRR390728 SRR390728 --no-sign-request
# download: s3://sra-pub-run-odp/sra/SRR390728/SRR390728 to SRR390728/SRR390728
# 
# real    0m29.429s
# user    0m2.701s
# sys     0m1.640s

time fasterq-dump ./SRR390728 --progress --threads 8 --split-files
# lookup :|-------------------------------------------------- 100.00%
# merge  : 17199388
# join   :|-------------------------------------------------- 100.00%
# concat :|-------------------------------------------------- 100.00%
# spots read      : 7,178,576
# reads read      : 14,357,152
# reads written   : 14,357,152
# 
# real    2m39.493s
# user    1m21.257s
# sys     0m17.675s
```

### NCBI sralite.1

If you downloaded a `sralite.1` file, you would also use `fasterq-dump` to generate the FASTQ files.

```console
wget -c https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos5/sra-pub-zq-11/SRR001/216/SRR1216023/SRR1216023.sralite.1
fasterq-dump --split-files SRR1216023.sralite.1
```
```
spots read      : 9,578,089
reads read      : 19,156,178
reads written   : 19,156,178
```

You will need to gzip the files afterwards.

```console
ls SRR1216023_*
```
```
SRR1216023_1.fastq  SRR1216023_2.fastq
```

### Useful resources

* The [SRA Explorer](https://sra-explorer.info/) can be used to search for
  specific datasets within the SRA.

## Aspera Connect

IBM Aspera Connect ([acquired by IBM in
2014](https://en.wikipedia.org/wiki/Aspera_(company))) is a high-performance
transfer client. Aspera Connect requires more updated version of C libraries,
which is why I created a [Docker
image](https://hub.docker.com/r/davetang/aspera_connect) for the tool; see the
[Dockerfile](https://github.com/davetang/learning_docker/blob/main/aspera_connect/Dockerfile)
for more information. (If you want to install the tool for yourself, you can
use the `install_aspera.sh` script in the `script` directory.)

Start a container and download the FASTQ files using Aspera Connect.

```console
docker run --rm -it -u parasite davetang/aspera_connect:4.2.5.306 /bin/bash

cd
time ascp -QT -l 300m -P33001 -i $HOME/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR390/SRR390728/SRR390728_1.fastq.gz .
# real    0m16.839s
# user    0m1.308s
# sys     0m9.536s

time ascp -QT -l 300m -P33001 -i $HOME/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR390/SRR390728/SRR390728_2.fastq.gz .
# real    0m17.668s
# user    0m1.177s
# sys     0m8.981s
```

## European Nucleotide Archive

The European Nucleotide Archive (ENA) provides a comprehensive record of the
world’s nucleotide sequencing information, covering raw sequencing data,
sequence assembly information and functional annotation.

The [SRA Explorer](https://sra-explorer.info/) can be used to generate download
links for FASTQ files.

```console
time wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR390/SRR390728/SRR390728_1.fastq.gz
# snipped
# real    0m59.909s
# user    0m0.108s
# sys     0m1.073s

time wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR390/SRR390728/SRR390728_2.fastq.gz
# snipped
# real    1m12.205s
# user    0m0.077s
# sys     0m0.898s
```

## DNA Data Bank of Japan

The [DNA Data Bank of Japan](https://www.ddbj.nig.ac.jp/about/index-e.html)
(DDBJ) is a biological database that collects DNA sequences. The [DDBJ search
page](https://ddbj.nig.ac.jp/search) can be used to find download links. There
were no FASTQ files for SRR390728, so the `sra` file was downloaded and
converted into FASTQ. (I also checked another SRA Run and FASTQ files were not
available too; in the past, I could directly download FASTQ files from DDBJ.)

```console
time wget ftp://ftp.ddbj.nig.ac.jp/ddbj_database/dra/sralite/ByExp/litesra/SRX/SRX079/SRX079566/SRR390728/SRR390728.sra
# snipped
# real    0m12.608s
# user    0m0.075s
# sys     0m0.748s
```

## NCBI Datasets

As advertised, [NCBI Datasets](https://www.ncbi.nlm.nih.gov/datasets/) is:

> A one-stop shop for finding, browsing, and downloading genomic data

The NCBI Datasets [command-line tools](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/) (CLI) are `datasets` and `dataformat`.

* Use `datasets` to download biological sequence data across all domains of life from NCBI.
* Use `dataformat` to convert metadata from JSON Lines format to other formats.

For x86_64/amd64, download the following files.

```console
wget -c https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets
wget -c https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/dataformat

chmod 755 datasets dataformat
```

Download genome sequence of [NC_004065.1](https://www.ncbi.nlm.nih.gov/nuccore/NC_004065).

```console
./datasets download virus genome accession NC_004065.1 --include genome cds annotation
unzip -d NC_004065.1 ncbi_dataset.zip
```
```
Archive:  ncbi_dataset.zip
  inflating: NC_004065.1/README.md
  inflating: NC_004065.1/ncbi_dataset/data/data_report.jsonl
  inflating: NC_004065.1/ncbi_dataset/data/genomic.fna
  inflating: NC_004065.1/ncbi_dataset/data/virus_dataset.md
  inflating: NC_004065.1/ncbi_dataset/data/dataset_catalog.json
  inflating: NC_004065.1/md5sum.txt
```

Download gene reports.

```console
./datasets download gene accession NC_004065.1 --include product-report
unzip -d NC_004065.1_gene ncbi_dataset.zip
```

Convert into TSV.

```console
./dataformat tsv gene --inputfile ./NC_004065.1_gene/ncbi_dataset/data/data_report.jsonl
./dataformat tsv gene-product --inputfile ./NC_004065.1_gene/ncbi_dataset/data/product_report.jsonl
```

## Metadata

A primary concern of research parasites is as follows:

> The first concern is that someone not involved in the generation and
> collection of the data may not understand the choices made in defining the
> parameters.

While a research parasite can easily download parameters of a study, i.e. a
study's metadata, it can be safely assumed that they have no knowledge of
experimental design and/or lack the scientific rigor to research the
methodology when they do not understand something. Furthermore, it is
definitely impossible for a research parasite to email/contact the original
authors of a study for further clarification. Can you even imagine opening up a
channel of communication and potentially collaborating with these clueless
leeches!?

This section includes some tools that can be used to obtain metadata, for
whatever good it will do for the research parasite.

### Entrez Direct

[Entrez Direct](https://www.ncbi.nlm.nih.gov/books/NBK179288/) (EDirect) is a
tool that provides access to NCBI's databases, such as its publication,
sequence, structure, gene, variation, and expression databases. Below are some
useful commands.

Download the metadata associated with a SRA Experiment ID.

```console
conda activate research_parasite
esearch -db sra -query SRX079566 | efetch -format runinfo
# Run,ReleaseDate,LoadDate,spots,bases,spots_with_mates,avgLength,size_MB,AssemblyName,download_path,Experiment,LibraryName,LibraryStrategy,LibrarySelection,LibrarySource,LibraryLayout,InsertSize,InsertDev,Platform,Model,SRAStudy,BioProject,Study_Pubmed_id,ProjectID,Sample,BioSample,SampleType,TaxID,ScientificName,SampleName,g1k_pop_code,source,g1k_analysis_group,Subject_ID,Sex,Disease,Tumor,Affection_Status,Analyte_Type,Histological_Type,Body_Site,CenterName,Submission,dbgap_study_accession,Consent,RunHash,ReadHash
# SRR292241,2011-06-24 15:12:07,2015-06-28 00:33:07,9721384,699939648,9721384,72,956,,https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos5/sra-pub-run-32/SRR000/292/SRR292241/SRR292241.3,SRX079566,HS0798,RNA-Seq,cDNA,TRANSCRIPTOMIC,PAIRED,0,0,ILLUMINA,Illumina Genome Analyzer IIx,SRP020237,PRJNA172563,,172563,SRS212581,SAMN00630374,simple,9606,Homo sapiens,HS0798,,,,,,,no,,,,,BCCAGSC,SRA039051,,public,0CDE83A17F8054DF7149F7407B49F82A,D87E6B8E105E190E4C939C490575028E
# SRR390728,2011-12-21 19:11:28,2022-12-22 12:23:54,7178576,516857472,7178576,72,185,GCF_000001405.12,https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos2/sra-pub-zq-20/SRR000/390/SRR390728/SRR390728.lite.2,SRX079566,HS0798,RNA-Seq,cDNA,TRANSCRIPTOMIC,PAIRED,0,0,ILLUMINA,Illumina Genome Analyzer IIx,SRP020237,PRJNA172563,,172563,SRS212581,SAMN00630374,simple,9606,Homo sapiens,HS0798,,,,,,,no,,,,,BCCAGSC,SRA039051,,public,6ECEAB01ACBA62F942073E84603E8756,8BF399452ED769A11B9A2BC869F941B0
```

The above command can be piped to other commands to get a list of the SRA Run
IDs associated with an SRA Experiment ID or SRA Study ID.

```console
esearch -db sra -query SRX079566 \
   | efetch -format runinfo \
   | cut -f1 -d',' \
   | grep -v "^Run"
# SRR292241
# SRR390728
````

Get more information on a sample using the biosample ID.

```console
esummary -db biosample -id SRS212581
# XML output
```

### ffq

[ffq](https://github.com/pachterlab/ffq) is a tool that can be used to fetch
metadata from the following databases:

* Gene Expression Omnibus (GEO)
* Sequence Read Archive (SRA)
* European Molecular Biology Laboratory's European Bioinformatics Institute (EMBL-EBI)
* DNA Data Bank of Japan (DDBJ)
* NIH Biosample
* The Encyclopedia of DNA Elements (ENCODE)

It can be easily installed using `pip`.

```console
pip install ffq
```

It requires one argument, which is an ID (or IDs) that corresponds to one or
multiple SRA / GEO / ENCODE / ENA / EBI-EMBL / DDBJ / Biosample accessions,
DOIs, or paper titles.

```console
ffq SRX079566
# metadata in JSON format
```

To generate links to the raw data, specify the choice of host. (You can use a
proper JSON parser to obtain the URLs more cleanly.)

```console
ffq --ftp SRX079566 | grep '"url"'
# snipped
#         "url": "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR292/SRR292241/SRR292241_1.fastq.gz"
#         "url": "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR292/SRR292241/SRR292241_2.fastq.gz"
#         "url": "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR390/SRR390728/SRR390728_1.fastq.gz"
#         "url": "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR390/SRR390728/SRR390728_2.fastq.gz"

ffq --aws SRX079566 | grep '"url"'
# snipped
#         "url": "https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR292241/SRR292241"
#         "url": "s3://sra-pub-src-13/SRR292241/Run94367Lane6.srf"
#         "url": "s3://sra-pub-src-15/SRR390728/30KWMAAXX_6.sorted_withJunctionsOnGenome_dupsFlagged.bam.1"
#         "url": "https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR390728/SRR390728"

ffq --gcp SRX079566 | grep '"url"'
# snipped
#         "url": "gs://sra-pub-crun-3/SRR292241/SRR292241.3"
#         "url": "gs://sra-pub-run-1/SRR390728/SRR390728.3"

ffq --ncbi SRX079566 | grep '"url"'
# snipped
#         "url": "https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos5/sra-pub-run-32/SRR000/292/SRR292241/SRR292241.3"
#         "url": "https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos2/sra-pub-zq-20/SRR000/390/SRR390728/SRR390728.lite.2"
```

I [submitted a GitHub Issue](https://github.com/pachterlab/ffq/issues/59) that
suggested an `--aspera` option. But for now you can generate the Aspera URLs
using `sed`.

```console
ffq --ftp SRX079566 \
   | grep '"url"' \
   | sed 's/ftp:\/\/ftp.sra.ebi.ac.uk\//era-fasp@fasp.sra.ebi.ac.uk:/'
# snipped
#         "url": "era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR292/SRR292241/SRR292241_1.fastq.gz"
#         "url": "era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR292/SRR292241/SRR292241_2.fastq.gz"
#         "url": "era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR390/SRR390728/SRR390728_1.fastq.gz"
#         "url": "era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR390/SRR390728/SRR390728_2.fastq.gz"
```

### ffs

The `ffs` script will parse `ffq`'s output to generate a download script.

Generate a script to download from the FTP site.

```console
ffq --ftp SRX079566 | script/ffs ftp - > ftp.sh
cat ftp.sh
# if [[ ! -f SRR292241_1.fastq.gz ]]; then
#    wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR292/SRR292241/SRR292241_1.fastq.gz
# fi
# if [[ ! -f SRR292241_2.fastq.gz ]]; then
#    wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR292/SRR292241/SRR292241_2.fastq.gz
# fi
# if [[ ! -f SRR390728_1.fastq.gz ]]; then
#    wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR390/SRR390728/SRR390728_1.fastq.gz
# fi
# if [[ ! -f SRR390728_2.fastq.gz ]]; then
#    wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR390/SRR390728/SRR390728_2.fastq.gz
# fi
```

Generate a download script for use with the [Aspera connect Docker
container](#aspera-connect).

```console
ffq --ftp SRX079566 | script/ffs aspera - > aspera.sh
cat aspera.sh
# if [[ ! -f SRR292241_1.fastq.gz ]]; then
#    ascp -QT -l 300m -P33001 -i ${HOME}/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR292/SRR292241/SRR292241_1.fastq.gz .
# fi
# if [[ ! -f SRR292241_2.fastq.gz ]]; then
#    ascp -QT -l 300m -P33001 -i ${HOME}/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR292/SRR292241/SRR292241_2.fastq.gz .
# fi
# if [[ ! -f SRR390728_1.fastq.gz ]]; then
#    ascp -QT -l 300m -P33001 -i ${HOME}/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR390/SRR390728/SRR390728_1.fastq.gz .
# fi
# if [[ ! -f SRR390728_2.fastq.gz ]]; then
#    ascp -QT -l 300m -P33001 -i ${HOME}/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR390/SRR390728/SRR390728_2.fastq.gz .
# fi

docker run --rm -it -u parasite -v $(pwd):$(pwd) -w $(pwd) davetang/aspera_connect:4.2.5.306 /bin/bash
bash aspera.sh

# SRR292241_1.fastq.gz                                                                                                                                                           100%  369MB  238Mb/s    00:13
# Completed: 378151K bytes transferred in 13 seconds
#  (227709K bits/sec), in 1 file.
# SRR292241_2.fastq.gz                                                                                                                                                           100%  376MB  272Mb/s    00:13
# Completed: 385855K bytes transferred in 14 seconds
#  (218815K bits/sec), in 1 file.
# SRR390728_1.fastq.gz                                                                                                                                                           100%   96MB  265Mb/s    00:05
# Completed: 99006K bytes transferred in 5 seconds
#  (141136K bits/sec), in 1 file.
# SRR390728_2.fastq.gz                                                                                                                                                           100%   97MB  261Mb/s    00:07
# Completed: 99628K bytes transferred in 7 seconds
#  (105342K bits/sec), in 1 file.
```

A list of accessions can be saved in a file, e.g. `list.txt`, used as input to
`ffq`, and piped to `ffs` to generate a download file with all the accessions.

```console
ffq --ftp $(cat list.txt) | ./script/ffs aspera - > list.sh

tail list.sh
# fi
# if [[ ! -f SRR22891597_2.fastq.gz ]]; then
#    ascp -QT -l 300m -P33001 -i ${HOME}/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR228/097/SRR22891597/SRR22891597_2.fastq.gz .
# fi
# if [[ ! -f SRR22891598_1.fastq.gz ]]; then
#    ascp -QT -l 300m -P33001 -i ${HOME}/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR228/098/SRR22891598/SRR22891598_1.fastq.gz .
# fi
# if [[ ! -f SRR22891598_2.fastq.gz ]]; then
#    ascp -QT -l 300m -P33001 -i ${HOME}/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:vol1/fastq/SRR228/098/SRR22891598/SRR22891598_2.fastq.gz .
# fi
```

## fetchngs

Install `nf-core/tools` first.

```console
pip install nf-core

# upgrade
pip install --upgrade nf-core
```

Find version.

```console
nf-core pipelines list | grep fetchngs
```
```
                                          ,--./,-.
          ___     __   __   __   ___     /,-._.--~\
    |\ | |__  __ /  ` /  \ |__) |__         }  {
    | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                          `._,._,'

    nf-core/tools version 3.2.1 - https://nf-co.re


│ fetchngs                  │   175 │         1.12.0 │   1 years ago │           - │ -                    │
```

Download `nf-core/fetchngs`.

```console
export NXF_SINGULARITY_CACHEDIR=/data/nxf_singularity

nf-core pipelines download --revision 1.12.0 --outdir /data/nf-core/fetchngs --compress none --container-system singularity --parallel-downloads 4 fetchngs
```

Run `nf-core/fetchngs`.

```console
nextflow /data/nf-core/fetchngs/1_12_0/main.nf \
   -profile singularity \
   --input ids.csv \
   --outdir data

ll data/fastq
```
```
total 828K
-rw-r--r-- 1 dtang dtang  38K May 17 16:36 DRX024467_DRR026872.fastq.gz
-rw-r--r-- 1 dtang dtang 8.0K May 17 16:36 ERX1188904_ERR1109373_2.fastq.gz
-rw-r--r-- 1 dtang dtang 8.0K May 17 16:36 ERX1188904_ERR1109373_1.fastq.gz
-rw-r--r-- 1 dtang dtang 592K May 17 16:36 SRX6725035_SRR9984183.fastq.gz
-rw-r--r-- 1 dtang dtang  18K May 17 16:37 ERX1234253_ERR1160846.fastq.gz
-rw-r--r-- 1 dtang dtang  16K May 17 16:37 SRX9626017_SRR13191702_2.fastq.gz
-rw-r--r-- 1 dtang dtang  16K May 17 16:37 SRX9626017_SRR13191702_1.fastq.gz
-rw-r--r-- 1 dtang dtang  61K May 17 16:37 DRX026011_DRR028935_2.fastq.gz
-rw-r--r-- 1 dtang dtang  59K May 17 16:37 DRX026011_DRR028935_1.fastq.gz
drwxr-xr-x 2 dtang dtang 4.0K May 17 16:37 md5
```

## Example

Let's say someone actually had the nerve to try and re-use data for the purposes of further understanding a disease (beyond the conclusions reached in the original publication) so that we can try to develop better therapeutics. They will look in the [paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3483540/) to see if the authors were foolish enough to deposit their data in a central repository.

> Gene expression values for 87 lung adenocarcinomas and 77 adjacent normal tissues can be viewed at http://gene.gmi.ac.kr and at the NCBI Gene Expression Omnibus (GEO) (http://www.ncbi.nlm.nih.gov/geo/) under accession number GSE40419.

The GEO accession number can be used to [search for associated datasets](https://www.ncbi.nlm.nih.gov/gds/?term=GSE40419[Accession]), where one can find sample IDs (e.g. [GSM993771](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM993771), which is linked to the associated experiment ([ERX140426](https://www.ncbi.nlm.nih.gov/sra?term=ERX140426)).

Now using the tools described in this document, one can quickly download a dataset from the paper!

```console
ffq --ftp ERX140426 | script/ffs aspera - > ERX140426.sh

docker run --rm --env PATH=$PATH:/home/parasite/.aspera/connect/bin/ -v $(pwd):$(pwd) -w $(pwd) -u parasite davetang/aspera_connect:4.2.5.306 /bin/bash ./ERX140426.sh
```
```
Completed: 4232933K bytes transferred in 2243 seconds
 (15457K bits/sec), in 1 file.
Completed: 4292000K bytes transferred in 2947 seconds
 (11928K bits/sec), in 1 file.
```

Aspera used to be very fast (and was the fastest approach) but perhaps there has been too many research parasites using it and they have limited the speed?

```console
bc -l<<<2243/60
```
```
37.38333333333333333333
```
```console
bc -l<<<2947/60
```
```
49.11666666666666666666
```

Downloading using the FTP is much quicker now.

```console
wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR164/ERR164549/ERR164549_1.fastq.gz
```
```
ERR164549_1.fastq.gz 100%[=======================================================>]   4.04G  12.4MB/s    in 7m 4s
```
```console
wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR164/ERR164549/ERR164549_2.fastq.gz
```
```
ERR164549_2.fastq.gz 100%[=======================================================>]   4.09G  11.4MB/s    in 7m 48s
```

Checksums.

```console
md5sum ERR164549_*
```
```
03fc4414c511c9420e1b2614594e659e  ERR164549_1.fastq.gz
6f9d710761ffa39fc45ab333c9b7c94f  ERR164549_2.fastq.gz
```

ERX140426 is for `LC_S52_nor` (Adjacent lung normal cells); `LC_S52` (Lung cancer cells) is ERX140511. Download the corresponding sample too.

```console
ffq --ftp ERX140511 | grep '"url"'
```
```
"url": "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR164/ERR164634/ERR164634_1.fastq.gz"
"url": "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR164/ERR164634/ERR164634_2.fastq.gz"
```

Download using FTP.

```console
wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR164/ERR164634/ERR164634_1.fastq.gz
wget -c ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR164/ERR164634/ERR164634_2.fastq.gz
```

Checksums

```console
md5sum ERR164634_*
f33e261013c4bbc59b2045244a587a25  ERR164634_1.fastq.gz
f9b543e99e1a5aa431695f6528beaa12  ERR164634_2.fastq.gz
```
