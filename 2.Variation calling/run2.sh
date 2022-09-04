GENOME='path/reference.dna.fa'

# 0.run HaplotypeCaller
gatk \
--java-options '-Xmx10G -Djava.io.tmpdir=./tmp -XX:ParallelGCThreads=3' \
HaplotypeCaller \
-R ${GENOME} \
-I 04.bam/A.bam  \
-ERC GVCF \
-O 05.GVCFs/A.g.vcf.gz 1>05.GVCFs/A.HC.log 2>&1

# 1.build genomicDB
# obtain chr list from gff file
grep -v '^#' reference.gff3 | cut -f1 | uniq > chr.list
# build
gatk \
--java-options "-Xmx50G -Djava.io.tmpdir=./tmp" GenomicsDBImport \
$(ls 05.GVCFs/*g.vcf.gz | awk '{print "-V "$0" "}') \
-L chr.list \
--genomicsdb-workspace-path ./05.GVCFs/gvcfs_db 1>./05.GVCFs/GenomicsDBImport.log 2>&1

# 2.run GenotypeGVCFs
gatk --java-options "-Xmx50G -Djava.io.tmpdir=./tmp" GenotypeGVCFs \
-R ${GENOME} \
-V gendb://05.GVCFs/gvcfs_db \
-O ./05.GVCFs/A01_A40.vcf.gz \
1>./05.GVCFs/GenotypeGVCFs.log 2>&1
