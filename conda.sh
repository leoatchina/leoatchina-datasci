conda create -p /jupyter/bioinfo python=2 
conda install -p /jupyter/bioinfo -y bamtools bbmap bcftools bedtools bioawk bowtie bowtie2 bwa cutadapt datamash emboss entrez-direct fastqc freebayes hisat2 htslib parallel=20180922 perl-list-moreutils picard samtools seqtk snpeff sra-tools subread trimmomatic trim-galore sambamba homer meme
# make a local path to /opt/anaconda3/pkgs for beneath install
conda install -p /jupyter/bioinfo -y deeptools blast multiqc macs2
