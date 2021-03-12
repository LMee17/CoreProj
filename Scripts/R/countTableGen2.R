#11th March 2021
#A quick script to remove the top non-gene rows from the count tables and save them
#as fresh files for use in degust

setwd("output/")
filelist <- list.files(pattern ="*_counts.tsv")

data.tab <- lapply(filelist, function(x){
  read.table(x, header = T, sep = "\t")
})

library("stringr")

for (i in 1:length(data.tab)){
  data.tab[[i]] <- data.tab[[i]][-c(1:4),]
  data.tab[[i]]$GeneInfo <- str_remove(data.tab[[i]]$GeneInfo, "rna-")
}


library(dplyr)
for (i in 1:length(filelist)){
  one <- strsplit(filelist[i], "_", fixed =T)
  species <- one[[1]][1]
  write.table(data.tab[[i]], file = paste(species, "counts.v2.csv", sep = "_"),
              col.names = T, row.names = F, quote = F, sep =",")
}


setwd("../")