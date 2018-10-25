conda create -p /jupyter/bioinfo python=2
curl http://data.biostarhandbook.com/install/conda.txt | xargs conda install -p /jupyter/bioinfo -y
conda install -p /jupyter/bioinfo trim-galore deeptools homer meme macs2 bowtie sambamba multiqc
