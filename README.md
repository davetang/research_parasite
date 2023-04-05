# Research parasite

[Research parasites](https://www.nejm.org/doi/10.1056/NEJMe1516564) are:

> people who had nothing to do with the design and execution of the study but
> use another group's data for their own ends, possibly stealing from the
> research productivity planned by the data gatherers, or even use the data to
> try to disprove what the original investigators had posited.

In the interests of science, we should never ever reuse data or heaven forbid,
try to disprove each other. This repository contains notes on how research
parasites may download your data. To protect yourself as a "front-line
researcher" you should never deposit your data to any of the following
resources (or publish your research, for that matter) or risk being proven
wrong by someone who re-analysed your data with more appropriate and/or updated
methodology or worse yet, have your data contribute to your field of research.

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
