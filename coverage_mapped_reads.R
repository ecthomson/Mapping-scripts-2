#!/usr/bin/env Rscript
#R script to generate plot of coverage and mapped reads for data extracted from "samstats" file produced by tanoti batch script
#input(args) file must be tab delimited file without headers:
#column 1: sample ID
#column 2: genome coverage (%)
#column 3: mapped reads (n)

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
# default output file
}

#get args file name
input <- commandArgs(trailingOnly = TRUE)
#print input file
input
#create object to name savefile
savefile<-paste0(input,".pdf")
#print savefile name
savefile

#load packages
library(scales)
library(ggplot2)
library(dplyr)
library(grid)

#import dataframe
samstats=read.table(args[1], sep="\t", header=F)

#ggplot to create the plots...
plot1 <-
  ggplot(samstats, aes(x=as.factor(samstats$V1), y=samstats$V2, group="ID")) + geom_line(colour="blue", alpha=0.75, size = 1) +
  #geom_point(aes(x = as.factor(samstats$V1), y = samstats$V2), size = 2, alpha = 0.75, colour = "blue") +
  ggtitle(input) +
  scale_x_discrete() +
  ylab("Coverage(%)") +
  theme_minimal() +
  theme(axis.title.x=element_blank(), axis.text.x=element_blank(),
        axis.ticks.x=element_blank())
plot2 <-
  ggplot(data = samstats, mapping = aes(x=as.factor(samstats$V1), y=samstats$V3)) +
  geom_col() +
  ylab("Mapped reads") +
  theme_minimal() +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#combine the plots  
grid.newpage()
grid.draw(rbind(ggplotGrob(plot1), ggplotGrob(plot2), size = "last"))

#save the plots
ggsave(savefile,plot=grid.draw(rbind(ggplotGrob(plot1), ggplotGrob(plot2), size = "last")))

#check whether the unwanted pdf file exists and remove it
file.exists("Rplots.pdf")
file.remove("Rplots.pdf")
#pdf(file=args[2],width=8.3, height=11.7)
#dev.off()
