if [ ! -f genome/Hwer_EXF-562.fasta ]; then
	pushd genome
	curl -o Hwer_EXF-562.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/003/704/675/GCA_003704675.1_ASM370467v1/GCA_003704675.1_ASM370467v1_genomic.fna.gz
	curl -o Hwer_EXF-562.gff.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/003/704/675/GCA_003704675.1_ASM370467v1/GCA_003704675.1_ASM370467v1_genomic.gff.gz
	gunzip *.gz
	popd
fi

if [ ! -f genome/Hwer_EXF-2788.fasta ]; then
	pushd genome
	curl -o Hwer_EXF-2788.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/003/704/645/GCA_003704645.1_ASM370464v1/GCA_003704645.1_ASM370464v1_genomic.fna.gz
	curl -o Hwer_EXF-2788.gff.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/003/704/645/GCA_003704645.1_ASM370464v1/GCA_003704645.1_ASM370464v1_genomic.gff.gz
	gunzip *.gz
	popd
fi

