# Note: VEP software version should be consistent with the annotated database version.
# 0.install VEP
conda create -n vep
conda activate vep
conda install ensemble-vep

# 1.check installed VEP
vep --help

# 2.annotate
vep \
-i ./07.filterVCF/A01_A40.snp.vcf.gz \
-o 07.filterVCF/H01_R40.anno \
--offline \
--cache \
--cache_version 51 \
--dir ~/.vep/  \
--fasta ${GENOME} \
--species vitis_vinifera