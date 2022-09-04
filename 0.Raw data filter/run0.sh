# 0.Check data quality
fastqc -o 00.fastqc -t 56 ./data/*.gz

# 1.Integrating multiple reports
multiqc -q -o 01.multiqc 00.fastqc/*.zip

# 2.Quality Control
java -jar trimmomatic-0.39.jar \
PE \
-threads 10 \
./data/A_1.fq.gz ./data/A_2.fq.gz \
02.trimmo/A_1_paired.fq.gz 02.trimmo/A_1_unpaired.fq.gz \
02.trimmo/A_2_paired.fq.gz 02.trimmo/A_2_unpaired.fq.gz \
ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 \
SLIDINGWINDOW:4:20 \
LEADING:20 \
TRAILING:20 \
MINLEN:50

# 3.Check data quality again
rm -f 02.trimmo/*unpaired.fq.gz
fastqc -t 56 -o 00.fastqc ./02.trimmo/*.gz
multiqc -q -o 01.multiqc ./00.fastqc

# 4.Build index
samtools faidx reference.dna.fa
bwa index reference.dna.fa
gatk CreateSequenceDictionary -R reference.dna.fa