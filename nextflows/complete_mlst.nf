// detect the isolates by exgtensions to be cleaned
params.reads = "${projectDir}/../raw_fastq/*_{1,2}{.fastq.gz,.fastq,.fq.gz,.fq}"
params.outdir = "${projectDir}/../results"

workflow {
    // create an input channel for trimmomatic
    read_pairs_ch = Channel.fromFilePairs(params.reads, checkIfExists: true)

    // step1: Trim the reads
    TRIM_READS(read_pairs_ch)

    // step2: Assemble the cleaned reads from the trimmed & run FastQC in paralele
    ASSEMBLE_SKESA(TRIM_READS.out.cleaned_pairs)
    CHECK_QUALITY(TRIM_READS.out.cleaned_pairs)

    // step3: MLST over each assembly
    RUN_MLST(ASSEMBLE_SKESA.out.contigs)
}

process TRIM_READS {
    tag "Trimming ${sample_id}"
    publishDir "${params.outdir}", mode: 'copy'
    
    conda 'bioconda::trimmomatic=0.39'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_R{1,2}_trimmed.fq.gz"), emit: cleaned_pairs
    path "${sample_id}_R*_unpaired.fq.gz", emit: unpaired

    script:
    """
    trimmomatic PE -threads ${task.cpus} \
    ${reads[0]} ${reads[1]} \
    ${sample_id}_R1_trimmed.fq.gz ${sample_id}_R1_unpaired.fq.gz \
    ${sample_id}_R2_trimmed.fq.gz ${sample_id}_R2_unpaired.fq.gz \
    LEADING:25 TRAILING:25 SLIDINGWINDOW:5:30 MINLEN:40
    """
}
    
process ASSEMBLE_SKESA {
    tag "Assembling ${sample_id}"
    publishDir "${params.outdir}/assemblies", mode: 'copy'
    conda 'bioconda::skesa=2.3.0'

    input:
    tuple val(sample_id), path(cleaned_reads)

    output:
    tuple val(sample_id), path("${sample_id}_assembly.fasta"), emit: contigs

    script:
    """
    skesa --fastq ${cleaned_reads[0]},${cleaned_reads[1]} \
          --cores ${task.cpus} \
          --use_paired_ends \
          > ${sample_id}_assembly.fasta
    """
}

process CHECK_QUALITY {
    tag "QC ${sample_id}"
    publishDir "${params.outdir}/reports", mode: 'copy'
    conda 'bioconda::fastqc=0.12.1'

    input:
    tuple val(sample_id), path(cleaned_reads)

    output:
    path "*.html"

    script:
    """
    fastqc ${cleaned_reads[0]} ${cleaned_reads[1]}
    """
}

process RUN_MLST {
    tag "Genotyping ${sample_id}"
    publishDir "${params.outdir}/genotyping", mode: 'copy'
    
    input:
    tuple val(sample_id), path(assembly)

    output:
    path "${sample_id}_mlst.tsv"

    script:
    """
    mlst ${assembly} > ${sample_id}_mlst.tsv
    """
}