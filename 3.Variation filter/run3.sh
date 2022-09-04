# 0.SelectVariants
# SNP
gatk \
--java-options "-Xmx50G -Djava.io.tmpdir=./tmp" \
SelectVariants \
-R ${GENOME} \
-V 06.rawVCFs/A01_A40.vcf.gz \
--select-type-to-include SNP \
-O 06.rawVCFs/A01_A40.snp.vcf.gz

# indel
gatk \
--java-options "-Xmx50G -Djava.io.tmpdir=./tmp" \
SelectVariants \
-R ${GENOME} \
-V 06.rawVCFs/A01_A40.vcf.gz \
--select-type-to-include INDEL \
-O 06.rawVCFs/A01_A40.indel.vcf.gz


# 1.Hard filter
# snp
gatk \
--java-options "-Xmx50G -Djava.io.tmpdir=./tmp" \
VariantFiltration \
-R ${GENOME} \
-V 06.rawVCFs/A01_A40.snp.vcf.gz \
--filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || SOR > 3.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
--filter-name "SNP_FILTER" \
-O 06.rawVCFs/A01_A40.snp.hard_filter.vcf.gz

# indel
gatk \
--java-options "-Xmx50G -Djava.io.tmpdir=./tmp" \
VariantFiltration \
-R ${GENOME} \
-V 06.rawVCFs/A01_A40.indel.vcf.gz \
--filter-expression "QD < 2.0 || FS > 200.0 || SOR > 10.0 || MQRankSum < -12.5 || ReadPosRankSum < -20.0" \
--filter-name "INDEL_FILTER" \
-O 06.rawVCFs/A01_A40.indel.hard_filter.vcf.gz

# 2.Extract pass variation
gatk \
--java-options "-Xmx50G -Djava.io.tmpdir=./tmp" \
SelectVariants \
-R ${GENOME} \
-V 06.rawVCFs/A01_A40.snp.hard_filter.vcf.gz \
--exclude-filtered \
-O 06.rawVCFs/A01_A40.snp.pass.vcf.gz

gatk \
--java-options "-Xmx50G -Djava.io.tmpdir=./tmp" \
SelectVariants \
-R ${GENOME} \
-V 06.rawVCFs/A01_A40.indel.hard_filter.vcf.gz \
--exclude-filtered \
-O 06.rawVCFs/A01_A40.indel.pass.vcf.gz

# 3.filter missing depth et al
VCF_IN=./06.rawVCFs/A01_A40.snp.pass.vcf.gz
VCF_OUT=./07.filterVCF/A01_A40.snp.vcf.gz

# set filter
MAF=0.1
MISS=0.9
QUAL=30
MIN_DEPTH=10
MAX_DEPTH=70

vcftools \
--gzvcf ./06.rawVCFs/A01_A40.snp.pass.vcf.gz \
--min-alleles 2 --max-alleles 2 \
--maf $MAF --max-missing $MISS --minQ $QUAL \
--min-meanDP $MIN_DEPTH --max-meanDP $MAX_DEPTH \
--minDP $MIN_DEPTH --maxDP $MAX_DEPTH \
--recode --stdout | bgzip > ./07.filterVCF/A01_A40.snp.vcf.gz