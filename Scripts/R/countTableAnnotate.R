#12th March 2021
#A script to add gene information to the counts tables

#read in the gene information per species
genefiles <- list.files(path = "input/Gene_Info/", pattern = "*.tsv")
mapSpecies <- vector(length = 4)

for (i in 1:length(mapSpecies)){
  one <- str_split(genefiles, pattern = "_")
  mapSpecies[i] <- one[[i]][1]
}

#prepare to read in the counts files
filelist <- list.files(path = "output/", pattern ="*csv")
species <- vector(length = 4)

for (i in 1:length(species)){
  one <- str_split(filelist, pattern = "_")
  species[i] <- one[[i]][1]
}

#set up a key to use to annotate mapped genome species information to the sample species
key <- as.data.frame(cbind(mapSpecies, species))

#read in the counts files
data.tab <- lapply(filelist, function(x){
  read.table(paste("output/", x, sep =""), header = T, sep = ",")
})


#read in the gene information
data.gene <- lapply(genefiles, function(x){
  read.table(paste("input/Gene_Info/", x, sep =""), header = T, sep = "\t")
})

#merge by transcripts

test <- merge(data.tab[[3]], data.gene[[3]], by.x = "GeneInfo", by.y = "TranscriptID",
              all = T)
test <- test[,c(1,14,2:13)]
head(test)
test[test$GeneID=="<NA>",]
