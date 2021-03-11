#!usr/bin/bash

#USAGE bash TrimLoop.sh <directory containing raw data directories> <output>

#A script designed to go through the raw_data directories of Novogene transcript reads and trim adapter
#sequences
#Assumed that each set of raw data files are within their own folders and follow the directory pattern
#provided by Novogene
#ie I would save the zip file provided within my own directory (say SetA), the zip file would contain
#two first directories, one of which contains the raw data under the name "raw_data"
#Thus this script would be directed to a master directory (ie Raw) which contains directories that 
#then contain the zip file and its corresponding unzipped directory, which in turn contains a 
#"raw_data" directory which (finally) contains the directories of each fq.gz file per sample.

#setting the path to trim_galore. Add your own directory
trim="/pub37/lmee/bin/TrimGalore-0.6.6/trim_galore"

#the date function records the time. The '+%c' specifies that it show the day of the week, date and time
#it is stored in a variable called "now". 
#when you put variables into an echo command it prints what is stored in the variable (in this case the date and time)
#the double ">>" function means "add to", rather than overwrite. In this command it begins a text file
#The $2 refers to the second argument. As above, this means the report will be named after whatever you named your output folder (ie Exp2trim.report)
now=$(date '+%c')
echo "Trimming began at $now" >> $2trim.report

#d is just what each iteration will be refered to. You could use any letter but I've used d for directory.
#the "*/" means find anything (*) that has a / at the end, which is how directories are presented in terminals (ie Input/) 
for d in $1*/; do
	#here I'm setting a variable (set) which keeps a note of the set of transcriptome libraries (as provided by NovoGene)
	#print$NF-1 tells awk to print the secod to last "column" after breaking up the string
	set=$(echo $d | awk -F "/" '{print$(NF-1)}')
	#both of these echos are just for the user to be able to see that the script is running / where it is up to
	echo $set
	echo "Preparing to trim read files from $set"
	#again I'm setting a time variable, this time called "clock" to keep track of progress in your report
	clock=$(date '+%c')
	echo "$set began at $clock" >> $2trim.report
	#here I'm telling the script to go through all the ds (as set above) and then go into the subdirectory "raw_data"
	#for here I want it to iterate through all the directories (which should all be directories of samples)
	#"s" is setting the iteration for each of those sample folders
	for s in $d*/raw_data/*/; do
		#again, setting a time to keep track of progress in your report (which can be viewed while the script runs in a screen)
		tic=$(date '+%c')
		#this is a variable that takes the name of the sample. "awk" breaks down the name of the sample directory by "/" (-F flag allows for you to determine how to break up the string)
		sample=$(echo $s | awk -F "/" '{print$(NF-1)}')
		#these two echos are for the user to be able to see the script is progressing either by checking the screen the script is running in or looking at the report file
		echo "Trimming $sample ..."
		echo "$sample trim began at $tic" >> $2trim.report
		#here we're using the trim galore executive. The path has been set in the variable "trim" which we call on at the beginning of the command
		#the rest are commands that specify where the output will be going ("-o $2", user defined variable as assigned by the second argument when running the script in the first place),
		#--paired means these were paired reads, which we then name using the set and sample variables we have already extracted from the directory tree.
		$trim --fastqc -o $2 --paired "$s$sample""_1.fq.gz" "$s$sample""_2.fq.gz"
		#record the time as this function finishes and add it to the report
		tok=$(date '+%c')
		echo "$sample trim completed at $tok" >> $2trim.report
		#from here the script starts again, and will continue to go through all the samples within the current directory we're in until they run out
	done
	#we're back to the main loop here. All samples in the directory are expended and so we wrap up by recording the time that it was finished
	time=$(date '+%c')
	echo "$set complete at $time" >> $2trim.report
	#we now loop back to the beginning and continue going through the different set directories until they too run out, and the loop is exited entirely.
done

#clean up the intermediate files by putting them into another folder
mkdir $2Reports/
mv $2*report.txt

#let the user see the script is complete
echo "Read trims are complete. Please refer to your output directory to view results."


#Lauren Mee
#University of Liverpool
#l.mee@liverpool.ac.uk