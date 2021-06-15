#12th March 2021
#A script to add gene information to the counts tables

#required
library("stringr")

#read in the gene information per species
genefiles <- list.files(path = "input/Gene_Info/", pattern = "*.txt")
mapSpecies <- vector(length = 3)

for (i in 1:length(mapSpecies)){
  one <- str_split(genefiles, pattern = "_")
  mapSpecies[i] <- one[[i]][1]
}

#prepare to read in the counts files
#remove caus
filelist <- list.files(path = "output/", pattern ="counts.v2.tsv")
filelist <- filelist[-3]
species <- vector(length = 3)

for (i in 1:length(species)){
  one <- str_split(filelist, pattern = "_")
  species[i] <- one[[i]][1]
}

#set up a key to use to annotate mapped genome species information to the sample species
key <- as.data.frame(cbind(mapSpecies, species))

#read in the counts files
data.tab <- lapply(filelist, function(x){
  read.table(paste("output/", x, sep =""), header = T, sep = "\t")
})


#read in the gene information
data.gene <- lapply(genefiles, function(x){
  read.table(paste("input/Gene_Info/", x, sep =""), header = F, sep = "\t", quote = "")
})

for (i in 1:length(mapSpecies)){
  names(data.gene[[i]]) <- c("TranscriptID", "Gene_Desc", "GeneID")
}


#merge by transcripts
data.ann <- vector(mode = "list", length = 3)

for (i in 1:length(mapSpecies)){
  data.ann[[i]] <- merge(data.tab[[i]], data.gene[[i]], by.x = "GeneInfo", 
                         by.y = "TranscriptID", all.x = T)
}

for (i in 1:length(data.ann)){
  data.ann[[i]] <- data.ann[[i]][,c(1,15,14,2:13)]
}

#write tables
#can't do csv as the gene descriptions have commas peppered throughout
for (i in 1:length(mapSpecies)){
  write.table(data.ann[[i]], paste("output/", species[[i]], "_counts_annotated.tsv", 
                                   sep = ""),
              col.names = T, row.names = F, quote = F, sep = "\t")
}
