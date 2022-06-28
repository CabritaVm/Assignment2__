#!/usr/bin/bash

# ID list of all 18 sequences
list_ids=("1653996" "1658697" "1658696" "1658695" "1658694" "1658693" "1658690" "1658682" "1658671" "1658645" "1658634" "1658632" "1658630" "1658618" "1658617" "1658556" "1658323" "1658322")

# This function will get the run accession and the sequence name and append the output in the respective files
accn_name() {

for id in ${lista_ids[@]}; # Variable id will represent each member of the list_ids
do # Starts loop

	# The variable run_accn will have the purpose to stor each run accession in the file run_accn.txt
	run_accn=$(efetch -db sra -id $id -mode txt | grep -o 'accession="SRR.* ' | sed 's/ .*//' | sed 's/accession=//' | tr -d '"' >> run_accn.txt)
	# The variable seq_name will store each sequence name from the respective id in the seq_name.txt
	seq_name=$(efetch -db sra -id $id -mode txt | grep -o '<Alternatives url="s3.*.fastq" free' | sed 's/q".*/q"/' | sed 's/.*src//' | sed 's/.fastq.*//' | sed 's/.*-8//' | sed "s/^.//" | sed 's/^.*\///' | sed 's/_/./' | sed 's/Diapensia/D/' | sed 's/Schizocodon/Sc/' | sed 's/Shortia/S/' >> seq_name.txt)

done # Ends loop

}
# Running function above
accn_name

# Function that will read each line of two file simultaneously and then use the program fasterq-dump to get the .fastq from each sequence/especies
fasterq() {

run_accn=$(wc -l run_accn.txt | cut -d\  -f 1 ) # Defines the run_accn variable
seq_name=$(wc -l seq_name.txt | cut -d\  -f 1 ) # Defines the seq_name variable
i=1 j=1 # Variables that will be used to represent each line of both files
while [ $i -le $run_accn -a $j -le $seq_name ]; # Defines the condition of the while loop that is, for example, if i=2 and j=2 it will be reading the 2nd line of both files
do # Starts loop
        name=$(sed -n -e "${j}p" seq_name.txt) # Variable that will define and get each line from seq_name.txt file
        accn=$(sed -n -e "${i}p" run_accn.txt) # Variable that will define and get each line from run_accn.txt file
        echo "seq_name = " $name # Prints the sequence name that the program is running
        echo "run_accn = " $accn # Prints the run accession that the program is running
        fasterq-dump --outfile $name'.fastq' $accn # Runs fasterq-dump with the respective accn and defines the name that the output file will get
        i=$(( i + 1 )); j=$(( j + 1 )) # Variable that raises i and j variables (the lines) while it's in the loop
done # Ends loop

}
# Running function above
fasterq

# This function will compress/zip the .fastq files so that they can be used next in ipyrad
gzips() {

for seq_name in $(cat seq_name.txt); # The variable seq_name represents each line in the seq_name.txt
do # Starts loop
        gzip $seq_name'.fastq' # Runs gzip program so that each sequence file is compressed (sequence_name.fastq -> sequence_name.fastq.gz)
done # Ends loop

}
# Running function above
gzips



