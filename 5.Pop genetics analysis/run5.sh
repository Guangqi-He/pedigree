# ANGSD software http://www.popgen.dk/angsd/index.php/ANGSD
# VCF2Dis https://github.com/BGI-shenzhen/VCF2Dis
# PopLDdecay https://github.com/BGI-shenzhen/PopLDdecay
# XPCLR https://github.com/hardingnj/xpclr

# bam2beagle
angsd \
-bam bam.list \
-GL 1 -doGlf 2 \
-minMapQ 30 -only_proper_pairs 1 -remove_bads 1 -uniqueOnly 1 -minQ 30 \
-doMaf 1 -doMajorMinor 1 \
-SNP_pval 1e-6 -minMaf 0.1 -minInd 21 \
-nThreads 30 \
-out 08.SNP/A01_A40

# 0.NJ Tree
VCF2Dis -InPut 07.filterVCF/A01_A40.snp.vcf.gz -OutPut p_dis.mat

# 1.LD decay
# pedigree
PopLDdecay -InVCF 07.filterVCF/A01_A40.snp.vcf.gz -OutStat 09.PopStr/2.ld/ped -SubPop ./data/pedigree.list -MaxDist 300 -OutType 1
# cultivar
PopLDdecay -InVCF 07.filterVCF/A01_A40.snp.vcf.gz -OutStat 09.PopStr/2.ld/cul -SubPop ./data/cultivar.list -MaxDist 300 -OutType 1
# all（ped+cul）
PopLDdecay -InVCF 07.filterVCF/A01_A40.snp.vcf.gz -OutStat 09.PopStr/2.ld/all -MaxDist 300 -OutType 1

# 2.PCA
pcangsd.py -beagle 08.SNPstat/A01_A40.beagle.gz -o 09.PopStr/1.pca/pca -threads 20

# 3.Heterozygosity
angsd -i 04.bam/A.bam -anc ${GENOME} -dosaf 1 -GL 1 -minMapQ 30 -only_proper_pairs 1 -remove_bads 1 -uniqueOnly 1 -minQ 30 -nThreads 30 -out 09.PopStr/5.Het/A
realSFS -fold 1 -P 30 09.PopStr/5.Het/A.saf.idx > 09.PopStr/5.Het/A.ml

# 4.Hardy–Weinberg test
vcftools --gzvcf 07.filterVCF/A01_A40.snp.vcf.gz --keep data/pedigree.list --hardy --out 09.PopStr/6.HWE/ped
vcftools --gzvcf 07.filterVCF/A01_A40.snp.vcf.gz --keep data/cultivar.list --hardy --out 09.PopStr/6.HWE/cul

# 5.Admixture
for i in {2..8}
do
NGSadmix -likes 08.SNPstat/A01_A40.beagle.gz -K ${i} -P 10 -o 09.PopStr/0.admix/str_${i} -maxiter 10000
done


# 6.Nucleotide diversity
# SFS
angsd -bam data/late_bam.list -doSaf 1 -out late -anc ${GENOME} -GL 1 -P 40 -minMapQ 30 -only_proper_pairs 1 -remove_bads 1 -uniqueOnly 1 -minQ 30 -minInd 28
# folded SFS
realSFS -fold 1 -P 24 12.sweeps/late.saf.idx > 12.sweeps/late.sfs
# caculate theta
realSFS saf2theta 12.sweeps/late.saf.idx -sfs 12.sweeps/late.sfs -outname 12.sweeps/01.Pi/late
# slide-windown
thetaStat do_stat 12.sweeps/01.Pi/late.thetas.idx -win 20000 -step 20000 -outnames 12.sweeps/01.Pi/late.win

# 7.Fst
# 2D SFS
realSFS -fold 1 09.PopStr/4.diversity/early.saf.idx 09.PopStr/4.diversity/late.saf.idx -P 24 > 12.sweeps/early.late.ml
# caculate Fst
realSFS fst index 09.PopStr/4.diversity/early.saf.idx 09.PopStr/4.diversity/late.saf.idx -sfs 12.sweeps/early.late.ml -fstout 12.sweeps/result
# slide-windown
realSFS fst stats2 12.sweeps/result.fst.idx -win 20000 -step 20000 > 12.sweeps/fst.win

# 8.XPLCR
for i in {1..19}
do
xpclr \
--out 12.sweeps/xpclr/${i}.xpclr \
--input 07.filterVCF/A01_A40.snp.vcf.gz \
--map genetic.map \
--samplesA data/early.list \
--samplesB data/late.list \
--maxsnps 200 \
--minsnps 20 \
--size 20000 \
--step 20000 \
--chr ${i}

