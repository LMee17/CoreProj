#15th June 2021
#Script to annotate C.aus counts table with the provided annotations from Sandra

#between this step and the previous script run that produced Caus_counts.v2.tsv, I 
#manually removed extra RNA names from the first column in such isntacnes as they occurred. 

#read in counts table 
caus <- read.table("output/Caus_counts.v2.edit.tsv", header = T, sep = "\t")
head(caus)

#read in gene annotations file
caus.gene <- read.table("input/Gene_Info/Caus_CAUST.v1_maker.b2gAnnot_merged_IPR.annot", 
                        sep = "\t", header = F, quote = "")
#remove GO terms so I can remove duplicates
caus.gene <- caus.gene[,-2]
names(caus.gene) <- c("GeneID", "Gene_Desc")
caus.gene <- caus.gene[!duplicated(caus.gene$GeneID),]

head(caus.gene)

#the transcript ids in the Caus is the same as the gene IDs, with an added "-RA/B" etc
#I can simply add a column that removes the prefix as it's gene column
get.id <- function(x){
  one <- strsplit(x, "-", fixed = T)
  id <- one[[1]][1]
  return(id)
}

for (i in 1:nrow(caus)){
  caus$GeneID[i] <- get.id(caus$GeneInfo[i])
}

caus.ann <- merge(caus, caus.gene, by = "GeneID", all.x = T)
head(caus.ann)

#arrange for degust
caus.ann <- caus.ann[,c(2, 1, 15, 3:14)]
head(caus.ann)


#write
write.table(caus.ann2, "output/Caus_counts_annotated.tsv", col.names = T, 
            row.names = F, quote = F, sep = "\t")
