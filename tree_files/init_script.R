library(tidyverse)
library(treeio)
library(ggtree)
library(ape)
library(lubridate)
library(stringr)
library(readr)


tree <- read.newick("core_gene_alignment_filtered.aln.treefile")
meta <- read_csv("IsolateMetadata_CHOP_NTM.csv")
