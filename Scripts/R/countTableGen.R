#10th November 2020
#Script to read in raw count reads and put them into species-specific tables (12 samples per
#species)

#required
library(dplyr)
library(stringr)

##Read input files
setwd("input/Counts_Raw/")

#Make a function which reads in the files per species, extract SampleID from the filename,
#extract just the genes and first count column per sample, and then combine all dataframes
#into one list per species. To do this, the gene column becomes the row.names of the final
#table, but this will need ot be reversed afterwards
count.gen <- function(x){
  setwd(file.path("~/Documents/Projects/Core_Project/CoreProj_Analysis/input/Counts_Raw/", paste(x)))
  filelist <- list.files(pattern = "*.out.tab")
  one <- lapply(filelist, function(x){
    read.table(x, header = F, sep = "\t")
  })
  sampleID <- lapply(filelist, function(x){
    sam <- str_match(x, "output_\\s*(.*?)\\s*ReadsPerGene")
    return(sam[2])
  })
  for (i in 1:length(filelist)){
    one[[i]] <- as.data.frame(one[[i]][,1:2])
  }
  for (i in 1:length(filelist)){
    colnames(one[[i]]) <- c("RNA", paste(sampleID)[i]) 
    rownames(one[[i]]) <- one[[i]][,1]
    one[[i]][,1] <- NULL
  }
  two <- bind_cols(one)
  return(two)
}

#Designate the species involved
#Create an empty list the same size as the number of species ready to fill with the
#count.gen's output
species <- c("Amel", "Bter", "Ccal", "Pcan")
data <- vector(mode = "list", length = 4)

for (i in 1:length(species)){
  data[[i]] <- count.gen(species[i])
}

#Return the gene info into a separate column as opposed to rownames
for (i in 1:length(data)){
  data[[i]]$GeneInfo <- rownames(data[[i]])
  data[[i]] <- data[[i]][, c(13, 1:12)]
}


#Write up 

setwd("~/Documents/Projects/Core_Project/CoreProj_Analysis/output/")

for (i in 1:length(species)){
  filename  <- paste(species[i],"_counts.tsv", sep="")
  write.table(data[i], filename, col.names = T, row.names = F, quote = F, sep = "\t")
}

setwd("~/Documents/Projects/Core_Project/CoreProj_Analysis/")
