#!/usr/bin/Rscript --vanilla

args <- commandArgs(trailingOnly = TRUE)

#Created by Marc Niebel Mar 2021
#Purpose: Uncorrected p-distance for an alignment
#Input is a nucleotide alignment e.g. from MAFFT
#Output is a tab delimited file in three column format with uncorrected p-distance in percentage

#Libraries needed
library(ape)
suppressPackageStartupMessages(library(dplyr))

#Alignment using the read.FASTA function from ape package
alignment <- read.FASTA(args[1])

#Name of file
filename <- basename(args[1])

#Remove ending of file e.g. fasta
removed_extension_filename <- sub("\\..*","",filename)

#Uncorrected p-distance using pairwise deletion in ape package
ape_dist <- dist.dna(alignment,pairwise.deletion = TRUE, model="raw")

#Produce a matrix of class dist
matrix_dist <- as.matrix(ape_dist)

#Produces a three column dataframe of all uncorrected p-distances
dataframe_dist <- as.data.frame.table(matrix_dist,responseName = "p.distance")

#Changing column names
names(dataframe_dist)[names(dataframe_dist) == "Var1"] <- "Sample 1"
names(dataframe_dist)[names(dataframe_dist) == "Var2"] <- "Sample 2"

#Filter out samples against themselves i.e. 0.00
dataframe_dist_filtered <- dataframe_dist %>% 
    filter(p.distance !="0")

#Convert p.distance to percentage
convert_p_dist_percentage <- dataframe_dist_filtered %>% 
    mutate("p.distance(%)"=round(p.distance *100,digits = 2)) %>%
    select(-p.distance)


#write to tab delimited file
write.table(convert_p_dist_percentage,paste0(removed_extension_filename,"_p_dist.txt"),sep="\t",row.names = FALSE)
