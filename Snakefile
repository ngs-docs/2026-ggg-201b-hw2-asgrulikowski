rule all:
    input:
        "SRR2584857_quast.8000000", # 8m lines
        "SRR2584857_annot.8000000",
        "SRR2584857_quast.6000000", # 6m lines
        "SRR2584857_annot.6000000",
        "SRR2584857_quast.5000000", # 5m lines
        "SRR2584857_annot.5000000",

rule subset_reads:
    input:
        "{sample}.fastq.gz",
    output:
        "{sample}.{subset,\d+}.fastq.gz"
    shell: """
        gunzip -c {input} | head -{wildcards.subset} | gzip -9c > {output} || true
    """

rule annotate:
    input:
        "SRR2584857-assembly.{subset}.fa"
    output:
        directory("SRR2584857_annot.{subset}")
    threads: 8
    conda: "prokka"
    shell: """
       prokka --prefix {output} {input}                                       
    """

rule assemble:
    input:
        r1 = "SRR2584857_1.{subset}.fastq.gz",
        r2 = "SRR2584857_2.{subset}.fastq.gz"
    output:
        dir = directory("SRR2584857_assembly.{subset}"),
        assembly = "SRR2584857-assembly.{subset}.fa"
    threads: 8
    conda: "megahit"
    shell: """
       megahit -1 {input.r1} -2 {input.r2} -f -m 5e9 -t 4 -o {output.dir}     
       cp {output.dir}/final.contigs.fa {output.assembly}                     
    """

rule quast:
    input:
        "SRR2584857-assembly.{subset}.fa"
    output:
        directory("SRR2584857_quast.{subset}")
    threads: 8
    conda: "megahit"
    shell: """                                                                
       quast {input} -o {output}                                              
    """


