#!/bin/bash

ENV_NAME="sra_tools_env"
ACCESSION="SRR38066332"

#check conda installation and env existiance 
if ! command -v conda &> /dev/null; then
    echo "Error: Conda is not installed"
    exit 1
fi

if conda info --envs | grep -q "$ENV_NAME"; then
    echo "Environment '$ENV_NAME' already exists, moving on..."
else
    echo "Creating environment '$ENV_NAME' with sra-tools..."
    conda create -n "$ENV_NAME" -c bioconda -c conda-forge sra-tools -y
fi

#find the conda on the machine and activate the env
CONDA_BASE=$(conda info --base)
source "$CONDA_BASE/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

#download data from ncbi
echo "Starting download for $ACCESSION..."

prefetch "$ACCESSION"


echo "Converting to FASTQ..."
fasterq-dump "$ACCESSION" --progress --split-files

echo "Download complete for $ACCESSION"