#!/bin/sh

# This script is used to download and reformat example RNA-Seq data
# from NCBI GEO. For more information about the data set visit
# http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE49829
# and 
# http://www.cell.com/cell-host-microbe/abstract/S1931-3128%2813%2900411-3

main(){
    INPUT_FOLDER=input
    OUTPUT_FOLDER=output
    create_folders
    get_fastx
    install_sra_toolkit
    download_sra_files
    convert_to_fastq
    convert_and_trimm
    generate_subsample_of_reads
    
}

create_folders(){
    mkdir -p \
        bin \
        $INPUT_FOLDER \
        $OUTPUT_FOLDER
}

get_fastx(){
    wget http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
    mkdir tmp
    mv fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 tmp
    cd tmp ; tar xfj fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 && mv bin/fastq_to_fasta ../bin && mv bin/fastq_quality_trimmer ../bin && cd ..
    rm -rf tmp
}

install_sra_toolkit(){
    wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.4.1/sratoolkit.2.4.1-ubuntu64.tar.gz
    tar xzf sratoolkit.2.4.1-ubuntu64.tar.gz
    mv ./sratoolkit.2.4.1-ubuntu64/bin/fastq-dump.2.4.1 bin
    rm -rf sratoolkit.2.4.1-ubuntu64.tar.gz sratoolkit.2.4.1-ubuntu64
}

download_sra_files(){
    ## See http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE49829
    ## and http://www.cell.com/cell-host-microbe/abstract/S1931-3128%2813%2900411-3

    wget -c \
	-O $INPUT_FOLDER/LSP_R1.sra \
	ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX%2FSRX334%2FSRX334192/SRR951038/SRR951038.sra

    wget -c \
	-O $INPUT_FOLDER/LSP_R2.sra \
	ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX%2FSRX334%2FSRX334193/SRR951039/SRR951039.sra

    wget -c \
	-O $INPUT_FOLDER/InSPI2_R1.sra \
	ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX%2FSRX334%2FSRX334208/SRR951054/SRR951054.sra

    wget -c \
	-O $INPUT_FOLDER/InSPI2_R2.sra \
	ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX%2FSRX334%2FSRX334209/SRR951055/SRR951055.sra
}

convert_to_fastq(){
    mkdir -p $OUTPUT_FOLDER/fastq
    for FILE in $(ls $INPUT_FOLDER | grep sra$) 
    do
	bin/fastq-dump.2.4.1 -O $OUTPUT_FOLDER/fastq --bzip2 $INPUT_FOLDER/$FILE &
    done
    wait
}

convert_and_trimm(){
    mkdir -p $OUTPUT_FOLDER/fasta
    for FILE in $(ls $OUTPUT_FOLDER/fastq | grep fastq.bz2)
    do
	bzcat $OUTPUT_FOLDER/fastq/${FILE} \
	    | ./bin/fastq_quality_trimmer -t 20 -Q33 -l 1 \
	    | ./bin/fastq_to_fasta -Q33 \
	    | bzip2 -c - > ${OUTPUT_FOLDER}/fasta/$(echo $FILE | sed "s/fastq.bz2/fa.bz2/") &
    done
    wait
}

generate_subsample_of_reads(){
    mkdir -p $OUTPUT_FOLDER/fasta_subsampled 
    for FILE in $(ls $OUTPUT_FOLDER/fasta/)
    do
	bzcat $OUTPUT_FOLDER/fasta/$FILE \
	    | head -n 2000000 \
	    | bzip2 -c - > $OUTPUT_FOLDER/fasta_subsampled/$FILE &
    done
    wait
}

main
