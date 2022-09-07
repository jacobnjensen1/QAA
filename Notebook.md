# QAA

My samples are 3_2B_control_S3_L008 and 17_3E_fox_S13_L008.

Fastqc ran without issues, finishing in 196.62 seconds for all four input files.

My script used 142.54 seconds to do a single file. It's slow. It used even more for 17_*.

My plots have a bar for each base, fastqc plots start binning positions after the first 10.

To find adapter sequences, I first looked at overrepresented sequences in the fastqc report.

3\*_R1 didn't have any and didn't show any adapters either, but 3\*_R2 had two sequences but no adapters listed. Grepping for those two sequences showed that they were at the begining of the line, so they could not be adapters. Blasting for the two sequences showed that they were 18S RNA.

17\*_R1 showed a TruSeq adapter with the sequence GATCGGAAGAGCACACGTCTGAACTCCAGTCACTATGGCACATCTCGTAT, and 17\*_R2 showed an Illumina primer with the sequence GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTGTGCCATAGTGTAGATCT as well as two sequences which were 18S RNA.

I grepped for both of those sequences in each 3\* fastq file and found nothing interesting:
```
(base) jjensen7@n278:/projects/bgmp/shared/2017_sequencing/demultiplexed$ zcat 3_2B_control_S3_L008_R2_001.fastq.gz | grep GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTGTGCCATAGTGTAGATCT
TTTGACACATGAGAGGAATATTAACGTGGATCGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTGTGCCATAGTGTAGATCTCGGTGGTCGCCGTATCATT
(base) jjensen7@n278:/projects/bgmp/shared/2017_sequencing/demultiplexed$ zcat 3_2B_control_S3_L008_R2_001.fastq.gz | grep GATCGGAAGAGCACACGTCTGAACTCCAGTCACTATGGCACATCTCGTAT
(base) jjensen7@n278:/projects/bgmp/shared/2017_sequencing/demultiplexed$ zcat 3_2B_control_S3_L008_R1_001.fastq.gz | grep GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTGTGCCATAGTGTAGATCT
(base) jjensen7@n278:/projects/bgmp/shared/2017_sequencing/demultiplexed$ zcat 3_2B_control_S3_L008_R1_001.fastq.gz | grep GATCGGAAGAGCACACGTCTGAACTCCAGTCACTATGGCACATCTCGTAT
```

The one result matched in the middle, which isn't an adapter. This isn't too surprising, as fastqc didn't report any adapters.

The results for 17\*_R1 were all at the beginning and middle of the reads, which seems bad. I looked at the "Illumina TruSeq" section in the cutadapt docs, because that was the adapter listed in the fastqc report, and saw substrings of those sequences listed: AGATCGGAAGAGCACACGTCTGAACTCCAGTCA and AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT.

Switching to those sequences as the potential adapters, there were actual results. 
```
(base) jjensen7@n278:/projects/bgmp/shared/2017_sequencing/demultiplexed$ zcat 3_2B_control_S3_L008_R1_001.fastq.gz | grep -c AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
7659
(base) jjensen7@n278:/projects/bgmp/shared/2017_sequencing/demultiplexed$ zcat 3_2B_control_S3_L008_R2_001.fastq.gz | grep -c AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
8157
(base) jjensen7@n278:/projects/bgmp/shared/2017_sequencing/demultiplexed$ zcat 17_3E_fox_S13_L008_R1_001.fastq.gz | grep -c AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
131503
(base) jjensen7@n278:/projects/bgmp/shared/2017_sequencing/demultiplexed$ zcat 17_3E_fox_S13_L008_R001.fastq.gz | grep -c AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
133008
```
Grepping without `-c` showed these sequences towards the end of the reads. I think I can trust these sequences.

cutadapting with `cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o /projects/bgmp/jjensen7/bioinfo/Bi623/QAA/3_2B_control_S3_L008_R1_001_fastq.gz -p /projects/bgmp/jjensen7/bioinfo/Bi623/QAA/3_2B_control_S3_L008_R2_001_fastq.gz 3_2B_control_S3_L008_R1_001.fastq.gz 3_2B_control_S3_L008_R2_001.fastq.gz` 
and `cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o /projects/bgmp/jjensen7/bioinfo/Bi623/QAA/17_3E_fox_S13_L008_R1_001_fastq.gz -p /projects/bgmp/jjensen7/bioinfo/Bi623/QAA/17_3E_fox_S13_L008_R2_001_fastq.gz 17_3E_fox_S13_L008_R1_001.fastq.gz 17_3E_fox_S13_L008_R2_001.fastq.gz`

summary output for 3\*:
```
=== Summary ===

Total read pairs processed:          6,873,509
  Read 1 with adapter:                 219,477 (3.2%)
  Read 2 with adapter:                 268,119 (3.9%)
Pairs written (passing filters):     6,873,509 (100.0%)

Total basepairs processed: 1,388,448,818 bp
  Read 1:   694,224,409 bp
  Read 2:   694,224,409 bp
Total written (filtered):  1,384,906,999 bp (99.7%)
  Read 1:   692,563,098 bp
  Read 2:   692,343,901 bp
```

summary output for 17\*:
```
=== Summary ===

Total read pairs processed:         11,784,410
  Read 1 with adapter:               1,024,588 (8.7%)
  Read 2 with adapter:               1,104,503 (9.4%)
Pairs written (passing filters):    11,784,410 (100.0%)

Total basepairs processed: 2,380,450,820 bp
  Read 1: 1,190,225,410 bp
  Read 2: 1,190,225,410 bp
Total written (filtered):  2,335,751,295 bp (98.1%)
  Read 1: 1,168,027,279 bp
  Read 2: 1,167,724,016 bp
```

trimmomatic ran with `trimmomatic PE 3_2B_control_S3_L008_R1_001_fastq.gz 3_2B_control_S3_L008_R2_001_fastq.gz -baseout 3_filtered.fastq.gz LEADING:3 TRAILING:3 SLIDINGWINDOW:5:15 MINLEN:35` and `trimmomatic PE 17_3E_fox_S13_L008_R1_001_fastq.gz 17_3E_fox_S13_L008_R2_001_fastq.gz -baseout 17_filtered.fastq.gz LEADING:3 TRAILING:3 SLIDINGWINDOW:5:15 MINLEN:35`

len distributions found with variations of `zcat 3_filtered_1P.fastq.gz | sed -n 2~4p | awk '{print length}' | sort -n | uniq -c > 3_filtered_1P_lengths.txt`

Mouse chromosome sequences were retrieved with `wget http://ftp.ensembl.org/pub/release-107/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.primary_assembly.fa.gz`

Mouse GTF retrieved with `wget http://ftp.ensembl.org/pub/release-107/gtf/mus_musculus/Mus_musculus.GRCm39.107.gtf.gz`

Star was run with scripts in the ens107.star_2.7.10a directory. The scripts were mostly copied from PS8 in Bi621.

The summary for the alignments was
```
(QAA) jjensen7@n278:/projects/bgmp/jjensen7/bioinfo/Bi623/QAA$ ./samStats.py -s ens107.star_2.7.10a/alignment_3/Aligned.out.sam 
Primary alignment: mapped: 12359958, unmapped: 496080
(QAA) jjensen7@n278:/projects/bgmp/jjensen7/bioinfo/Bi623/QAA$ ./samStats.py -s ens107.star_2.7.10a/alignment_17/Aligned.out.sam 
Primary alignment: mapped: 21532824, unmapped: 948708
```

htseq-count was run with `htseq-count --stranded=yes Aligned.out.sam ../../Mus_musculus.GRCm39.107.gtf` in the alignment_17 directory, producing this summary: 
```
__no_feature	9765828
__ambiguous	9607
__too_low_aQual	16499
__not_aligned	465454
```

I still need to run htseq-count a bunch more times.

I realized that the output I left above was the less useful part of the output, so I started piping stdout to files for each run of `htseq-count`. I summed the counts with `grep -v "^_" reverse_stranded.out | cut -f 2 | awk '{s+=$1} END {print s}'`.

The final counts were:
```
(QAA) jjensen7@n278:/projects/bgmp/jjensen7/bioinfo/Bi623/QAA/ens107.star_2.7.10a/alignment_3$ grep -v "^_" yes_stranded.out | cut -f 2 | awk '{s+=$1} END {print s}'
245058
(QAA) jjensen7@n278:/projects/bgmp/jjensen7/bioinfo/Bi623/QAA/ens107.star_2.7.10a/alignment_3$ grep -v "^_" reverse_stranded.out | cut -f 2 | awk '{s+=$1} END {print s}'
5260739
(QAA) jjensen7@n278:/projects/bgmp/jjensen7/bioinfo/Bi623/QAA/ens107.star_2.7.10a/alignment_17$ grep -v "^_" yes_stranded.out | cut -f 2 | awk '{s+=$1} END {print s}'
443307
(QAA) jjensen7@n278:/projects/bgmp/jjensen7/bioinfo/Bi623/QAA/ens107.star_2.7.10a/alignment_17$ grep -v "^_" reverse_stranded.out | cut -f 2 | awk '{s+=$1} END {print s}'
8952669
```

Because the numbers are different between `yes` and `reverse`, we know that the libraries were stranded. Because the `reverse` queries show more counts, we know that R2 has the sequence of features in the mouse genome.