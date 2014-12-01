#!/bin/sh

# This script perform the actual RNA-Seq analysis with READemption.

main(){
	READEMPTION_FOLDER=READemption_analysis
	FTP_SOURCE=ftp://ftp.ncbi.nih.gov/genomes/Bacteria/Salmonella_enterica_serovar_Typhimurium_SL1344_uid86645/
	SEQ_FOLDER=$READEMPTION_FOLDER/input/reference_sequences/

	set_up_analysis_folder
	get_genome_fasta_files
	get_gff_files
	add_read_libraries
	run_read_alignment
	build_coverage_files
	run_gene_quanti
	run_deseq_analysis
	run_viz_align
	run_viz_gene_quanti
	run_viz_deseq
}

set_up_analysis_folder(){
    reademption create $READEMPTION_FOLDER
}

get_genome_fasta_files(){

    cat <<EOF > bin/mod_fasta_head.py
import sys
import shutil

input_fh = open(sys.argv[1])
header = input_fh.readline()
if len(header.split()[0].split("|")) != 5:
    sys.stderr.write("Unexprected fasta header: \"%s\"\n" % header[:-1])
    sys.exit(2)
tmp_file_path = sys.argv[1] + "_TMP"
output_fh = open(tmp_file_path, "w")
genome_accession = header.split("|")[3]
new_header = ">%s %s" % (genome_accession, header[1:-1]) 
output_fh.write(new_header + "\n")
output_fh.write("".join(input_fh.readlines()))
shutil.move(tmp_file_path, sys.argv[1])
EOF


    wget -cP $SEQ_FOLDER $FTP_SOURCE/*fna
    for FILE in $(ls $SEQ_FOLDER/* | grep fna)
    do
        NEW_FILE_NAME=$(echo $FILE | sed "s/.fna/.fa/")
        mv $FILE $NEW_FILE_NAME
        python bin/mod_fasta_head.py $NEW_FILE_NAME
    done
}

get_gff_files(){
    wget -cP $READEMPTION_FOLDER/input/annotations/ \
        $FTP_SOURCE/*gff
}

add_read_libraries(){
    SOURCE=RNA_Seq_data/output/fasta_subsampled/
    for SAMPLE in \
	InSPI2_R1.fa.bz2 \
	InSPI2_R2.fa.bz2 \
	LSP_R1.fa.bz2 \
	LSP_R2.fa.bz2
    do
        ln -sf ../../../$SOURCE/${SAMPLE} $READEMPTION_FOLDER/input/reads/${SAMPLE}
    done
}

run_read_alignment(){
    reademption \
        align \
        -p 16 \
        -a 95 \
        -l 12 \
	--poly_a_clipping \
        $READEMPTION_FOLDER
}

build_coverage_files(){
    reademption \
        coverage \
        -p 16 \
        $READEMPTION_FOLDER
}

run_gene_quanti(){
    reademption \
	gene_quanti \
	-p 16 \
	-a \
	--features gene \
	$READEMPTION_FOLDER
}

run_deseq_analysis(){
    reademption \
	deseq \
	-l InSPI2_R1.fa.bz2,InSPI2_R2.fa.bz2,LSP_R1.fa.bz2,LSP_R2.fa.bz2 \
	-c InSPI2,InSPI2,LSP,LSP \
	$READEMPTION_FOLDER
}

run_viz_align(){
    reademption \
        viz_align \
        $READEMPTION_FOLDER
}

run_viz_gene_quanti(){
    reademption \
        viz_gene_quanti \
        $READEMPTION_FOLDER
}

run_viz_deseq(){
    reademption \
        viz_deseq \
        $READEMPTION_FOLDER
}

main
