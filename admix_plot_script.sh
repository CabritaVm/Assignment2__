#!/usr/bin/bash

# ID list of 14 sequences (taken out the outgroup ones Sc. and S.)
list_ids=("1653996" "1658693" "1658690" "1658682" "1658671" "1658645" "1658634" "1658632" "1658630" "1658618" "1658617" "1658556" "1658323" "1658322")

# Function that will create the .indfile that we need for the admixture plot (structure_threader)
indfile() {

for id in ${list_ids[@]}; # Variable id will represent each member of the list_ids
do # Starts o loop

        # The variable country will have the purpose to store the country from each sequence/especies in the country.txt,  and will abbreviate each one of them and add the order for the admixture plot
        country=$(efetch -db sra -id $id -mode txt | grep -o "<TAG>.*<TAG>" | grep -o "<VALUE>.*</VALUE>" | grep -o "<SAMPLE_ATTRIBUTE>.*" | sed 's/.*_name//' | grep -o "<VALUE>.*</VALUE>" | sed 's/<\VALUE>\.*//' | sed 's/<.*//' | tr -d ":" | cut -d ' ' -f 1 | sed 's/China/CHI 1/' | sed 's/Russia/RUS 3/' | sed 's/Japan/JAP 2/' | sed 's/Greenland/GRE 5/' | sed 's/Norway/NOR 6/' | sed 's/USA/USA 4/' >> country.txt)
        # The variable seq_name will store each sequence name from the respective id in the seq_name.txt
        seq_name=$(efetch -db sra -id $id -mode txt | grep -o '<Alternatives url="s3.*.fastq" free' | sed 's/q".*/q"/' | sed 's/.*src//' | sed 's/.fastq.*//' | sed 's/.*-8//' | sed "s/^.//" | sed 's/^.*\///' | sed 's/_/./' | sed 's/Diapensia/D/' >> seq_name.txt)
        # This command will combine both txt files in different columns and then the output redirected to assignment2.indfile
        paste seq_name.txt country.txt | column -s $'\t' -t > assignment2.indfile

done # Ends o loop

}
# Running function above
indfile

# Function that will filter our .vcf file and then create the name_fileCenterSNP.vcf file for the structure_threader program
vcf() {

        # Copys the .vcf file to the ~/str_analyses
        cp ~/ipyrad-assembly/assignment2_outfiles/assignment2.vcf ~/str_analyses
        # Compresses the .vcf file to .vcf.gz file
        gzip assignment2.vcf
        # Here we remove all the "outgroup" species that the autor's didn't use for geographic analysis
        # --remove-indv Individual_name to remove the individual name from the file --gzvcf or --vcf
        # last two parameters will say the name of the output file in this case "name_file.recode.vcf"
        vcftools --remove-indv "S.uniflora_56090" --gzvcf assignment2.vcf.gz --out assignment2_filtered3 --recode
        vcftools --remove-indv "S.uniflora_56091" --vcf assignment2_filtered3.recode.vcf --out assignment2_filtered2 --recode
        vcftools --remove-indv "Sc.soldanelloides_56079" --vcf assignment2_filtered2.recode.vcf --out assignment2_filtered1 --recode
        vcftools --remove-indv "Sc.soldanelloides_56080" --vcf assignment2_filtered1.recode.vcf --out assignment2_filtered --recode
        mv assignment2_filtered.recode.vcf assignment2_filtered.vcf # Replacement of the .recode.vcf to only .vcf
        # Deletion of all files created to get the last filtered vcf file
        rm assignment2_filtered1.recode.vcf assignment2_filtered2.recode.vcf assignment2_filtered3.recode.vcf assignment2_filtered1.log assignment2_filtered2.log assignment2_filtered3.log
        # This command will run vcf_parser.py script with python (it's a .py file) and create the name_fileCenterSNP.vcf that we need
        python3 vcf_parser.py --center-snp -vcf assignment2_filtered.vcf

}
# Running function above
vcf

# Here's the last command that we need to get the admixture plot. So, here we use structure_threader program to run and get the input (-i) name_fileCenterSNP.vcf file created in the previous function.
# Then we say the directory that will be created and stored all files on. Next we get the R script packeges to get the plots done, the number of K, the number of cores that your machine has and finnaly the .indfile
structure_threader run -i assignment2_filteredCenterSNP.vcf -o ./results_assignment2CenterSNP -als ~/miniconda3/envs/structure/bin/alstructure_wrapper.R -K 10 -t 2 --ind assignment2.indfile







