# 0.Mapping and sort
bwa mem -t 30 -R '@RG\tID:A\tSM:A\tPL:illumina' reference.dna.fa ./02.trimmo/A_1_paired.fq.gz ./02.trimmo/A_2_paired.fq.gz | samtools sort -@ 4 -m 2G -o 03.mapping/A.sort.bam -

# 1.Stat the information of mapping
samtools flagstat -@ 30 ./03.mapping/A.sort.bam > ./03.mapping/flagstat/A.flagstat

# 2.Stat depth and coverage
samtools coverage ./03.mapping/A.sort.bam > ./03.mapping/coverage/A.cov

# 3.Keep unique mapped reads
samtools view -@ 30 -q 1 -F 4 -F 256 -O BAM -o ./03.mapping/A.filter.bam ./03.mapping/A.sort.bam

# 4.Remove duplicates
gatk \
--java-options '-Xmx30g -Djava.io.tmpdir=./tmp -XX:ParallelGCThreads=30' \
MarkDuplicates \
-I ./03.mapping/A.filter.bam \
-O ./04.bam/A.bam \
-M ./04.bam/A.metrics \
--REMOVE_DUPLICATES true \
--CREATE_INDEX true 1>./04.bam/A.mark.log 2>&1

