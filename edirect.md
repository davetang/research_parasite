# Entrez Direct

[Entrez Direct](https://www.ncbi.nlm.nih.gov/books/NBK179288/) (EDirect)
provides access to the NCBI's suite of interconnected databases (publication,
sequence, structure, gene, variation, expression, etc.) from the terminal.

Navigation programs (`esearch`, `elink`, `efilter`, and `efetch`) communicate
by means of a small structured message, which can be passed invisibly between
operations with a Unix pipe. **The message includes the current database, so it
does not need to be given as an argument after the first step**.

`esearch` performs a new Entrez search using terms in indexed fields. It
requires a `-db` argument for the database name and uses `-query` for the
search terms.

`elink` looks up precomputed neighbours within a database, or finds associated
records in other databases. It also connects to the NIH Open Citation
Collection dataset to find publications that cite the selected PubMed articles,
or to follow the reference lists of PubMed records.

`efilter` limits the results of a previous query, with shortcuts that can also
be used in `esearch`.

`efetch` downloads selected records or reports in a style designated by
`-format`.

There is no need to use a script to loop over records in small groups, or write
code to retry after a transient network or server failure, or add a time delay
between requests. All of those features are already built into the EDirect
commands.

The `xtract` program uses command-line arguments to direct the selective
conversion of data in XML format. It allows path exploration, element
selection, conditional processing, and report formatting to be controlled
independently.

```
  xtract uses command-line arguments to convert XML data into a tab-delimited table.

  -pattern places the data from individual records into separate rows.

  -element extracts values from specified fields into separate columns.

  -group, -block, and -subset limit element exploration to selected XML subregions.
```

## Examples

### Experiment conditions

Metadata for [PRJNA860770](https://www.ncbi.nlm.nih.gov/bioproject/860770)
(data published in [JCI](https://www.jci.org/articles/view/164428)).

`esearch` result shows 27 runs.

```console
esearch -db sra -query PRJNA860770
# <ENTREZ_DIRECT>
#   <Db>sra</Db>
#   <WebEnv>MCID_64e2e96528928e70847f5e6e</WebEnv>
#   <QueryKey>1</QueryKey>
#   <Count>27</Count>
#   <Step>1</Step>
# </ENTREZ_DIRECT>
```

Pipe to `efetch` and `xtract` the information we need from the XML output.

```console
esearch -db sra -query PRJNA860770 \
   | efetch -format xml \
   | xtract -pattern EXPERIMENT_PACKAGE -element EXPERIMENT \
      -block RUN -element PRIMARY_ID \
      -block SAMPLE -element TITLE

# SRR22891572     SRS16280692     Trastuzumab-Sensitive
# SRR22891573     SRS16280690     Trastuzumab-Sensitive
# SRR22891574     SRS16280691     Trastuzumab-Sensitive
# SRR22891575     SRS16280689     Trastuzumab-Sensitive
# SRR22891576     SRS16280688     Trastuzumab-Sensitive
# SRR22891577     SRS16280687     Trastuzumab-Sensitive
# SRR22891578     SRS16280686     Trastuzumab-Sensitive
# SRR22891579     SRS16280685     Trastuzumab-Resistant
# SRR22891580     SRS16280684     Trastuzumab-Resistant
# SRR22891581     SRS16280683     Trastuzumab-Resistant
# SRR22891582     SRS16280682     Trastuzumab-Resistant
# SRR22891583     SRS16280681     Trastuzumab-Resistant
# SRR22891584     SRS16280680     Trastuzumab-Resistant
# SRR22891585     SRS16280679     Trastuzumab-Resistant
# SRR22891586     SRS16280678     Trastuzumab-Sensitive
# SRR22891587     SRS16280677     Trastuzumab-Resistant
# SRR22891588     SRS16280676     Trastuzumab-Resistant
# SRR22891589     SRS16280675     Trastuzumab-Resistant
# SRR22891590     SRS16280674     Trastuzumab-Resistant
# SRR22891591     SRS16280673     Trastuzumab-Resistant
# SRR22891592     SRS16280672     Trastuzumab-Resistant
# SRR22891593     SRS16280671     Trastuzumab-Sensitive
# SRR22891594     SRS16280670     Trastuzumab-Sensitive
# SRR22891595     SRS16280669     Trastuzumab-Sensitive
# SRR22891596     SRS16280668     Trastuzumab-Sensitive
# SRR22891597     SRS16280667     Trastuzumab-Sensitive
# SRR22891598     SRS16280666     Trastuzumab-Sensitive
```

### Find publications

Find articles on SARS-CoV-2 XBB.

```console
esearch -db pubmed -query "SARS-CoV-2 XBB" \
   | efetch -format xml \
   | xtract -pattern PubmedArticle -element MedlineCitation \
      -block MedlineCitation -element PMID \
      -block Article -element ArticleTitle \
      -block Journal -element Title \
      -block PubDate -element Year,Month,Day \
   | sed 's/^/https:\/\/pubmed.ncbi.nlm.nih.gov\//' > xbb.tsv

head -3 xbb.tsv
# https://pubmed.ncbi.nlm.nih.gov/37640233	Modeling the XBB strain of SARS-CoV-2: Competition between variants and impact of reinfection.	Journal of theoretical biology	2023	Aug	26
# https://pubmed.ncbi.nlm.nih.gov/37635002	Recombinant spike protein vaccines coupled with adjuvants that have different modes of action induce protective immunity against SARS-CoV-2.	Vaccine	2023	Aug	25
# https://pubmed.ncbi.nlm.nih.gov/37633965	Characterizing SARS-CoV-2 neutralization profiles after bivalent boosting using antigenic cartography.	Nature communications	2023	Aug	26
```
