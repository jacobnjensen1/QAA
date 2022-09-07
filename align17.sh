#!/bin/bash
#SBATCH --partition=bgmp        ### Partition (like a queue in PBS)
#SBATCH --job-name=STARAlign17      ### Job Name
#SBATCH --time=0-00:30:00       ### Wall clock time limit in Days-HH:MM:SS
#SBATCH --nodes=1               ### Number of nodes needed for the job
#SBATCH --ntasks-per-node=1     ### Number of tasks to be launched per Node
#SBATCH --cpus-per-task=8  ### Number of threads per task (OMP threads)
#SBATCH --account=bgmp      ### Account used for job submission

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

/usr/bin/time -v STAR --runThreadN 8 --runMode alignReads \
--outFilterMultimapNmax 3 \
--outSAMunmapped Within KeepPairs \
--alignIntronMax 1000000 --alignMatesGapMax 1000000 \
--readFilesCommand zcat \
--readFilesIn /projects/bgmp/jjensen7/bioinfo/Bi623/QAA/17_filtered_1P.fastq.gz /projects/bgmp/jjensen7/bioinfo/Bi623/QAA/17_filtered_2P.fastq.gz \
--genomeDir . \
--outFileNamePrefix alignment_17/
