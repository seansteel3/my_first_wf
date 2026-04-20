
# Isolate-ID: Automated Genomic Assembly & Genotyping

This project is a Nextflow-based workflow designed to automate the process of downloading SRA data, cleaning reads, performing parallel assembly and quality control, and finally genotyping the isolate using MLST.

## Workflow Architecture

---

## Prerequisites

Before running the pipeline, ensure your system (Linux, macOS, or WSL2) has the following installed:

* **Nextflow:** For workflow management.
* **Conda / Mamba:** For environment and software management (Trimmomatic, SKESA, FastQC).
* **Docker:** **Must be running** to execute the MLST genotyping step.
* **Java 17+:** Required to run Nextflow.

---

## Getting Started

### 1. Prepare the Data
You have two options to provide input data for the pipeline.

#### Option A: Use your own data
Place your paired-end FastQ files directly into the `raw_fastq/` folder. The pipeline recognizes `.fq`, `.fq.gz`, `.fastq`, and `.fastq.gz` extensions.
*Files must follow the `*_1` and `*_2` (or `_R1`/`_R2`) naming convention.*

#### Option B: Use the download script
Run the provided Bash script to fetch data from the NCBI SRA. This script defaults to a test isolate if no accession is provided.
```bash
# To download the default test data (SRR36396747)
bash ./scripts/data_download.sh

# To download a specific accession
bash ./scripts/data_download.sh YOUR_ACCESSION_HERE
