#usr/bin/bash

#usage bash MapperLoop.sh <directory containing reads> <directory containing genome gffs> <output directory> <sample key>

#A batch file designed for mapping paired reads against genomes of multiple species

#Requirements
#Each gff file should have a prefix which corresponds to its species, ie "Amel" corresponds to Apis mellifera
#Each species genome indices should be within an individual species folder of this name (ie Amel) within the genome / gffs
#directory (ie Core_GFF/Amel/). This is how mapping output will be sorted
#All reads should be in one directory as input as $1 above
#Sample key should be text file with full sample ID as it appears in the read file (ie AM.N.056 appears as AM_N_056 after Novogene
#processing) with the species of each sample separated by a tab. The species id should match that you have used as the corresponding
#GFF file's prefix, (for example, Apis mellifera becomes Amel). Each line is a new sample, ie
#AM_N_056	Amel
#BT_N_019	Bter

echo "Beginning to Map using STAR"
now=$(date '+%c')
tot=$(wc -l $4 | awk '{print$1}')

prog=1
while read s; do
	sample=$(echo $s | awk '{print $1}')
	species=$(echo $s | awk '{print $2}')
	if [ -e $3/$species ];	then
		echo "..."
	else
		mkdir $3/$species/
	fi
	echo "Mapping $sample paired reads to $species genome"
	tik=$(date '+%c')
	echo "Sample $prog/$tot: $sample began at $tik" >> map.report
	mkdir $3/$species/$sample
	STAR --genomeDir $2/$species --sjdbGTFfile $2/$species/"$species"*.gff --quantMode GeneCounts --sjdbGTFfeatureExon exon --sjdbGTFtagExonParentTranscript ID --sjdbGTFtagExonParentGene Parent --runThreadN 20 --readFilesCommand zcat --readFilesIn $1/"$sample"*_1.fq.gz $1/"$sample"*_2.fq.gz --outFileNamePrefix $3/$species/$sample/output_$sample --outSAMtype BAM SortedByCoordinate --limitBAMsortRAM 8049792128 --outReadsUnmapped Fastx
	tok=$(date '+%c')
        echo "Completed: $tok" >> map.report
        let prog=prog+1
done < $4

rm *tmp

