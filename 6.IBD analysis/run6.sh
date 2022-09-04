# Beagle4 software https://faculty.washington.edu/browning/beagle/b4_1.html
# hap-ibd software https://github.com/browning-lab/hap-ibd

# 0.pedigree phasing
java -jar -Xmx30g \
beagle4.jar \
gtgl=./07.filterVCF/A01_A40.snp.vcf.gz \
ped=data/pedigree.info \
excludesamples=data/cultivar.list \
window=400 \
overlap=200 \
niterations=10 \
nthreads=40 \
out=10.phasing/ped_phase

# 1.ibd detection
java -Xmx10g -jar hapibd,jar \
gt=10.phasing/10.phasing/ped_phase.vcf.gz \
map=data/pedigree.map \
out=11.ibd/ped \
min-seed=0.03 \ 
max-gap=10000 \ 
min-extend=0.015 \ 
min-output=0.03 \ 
min-markers=50 \ 
min-mac=2 \
nthreads=10

# 2.extract the ibd from the specified sample
zcat ped.ibd.gz | grep sample_name  > sample_name.ibd

# 3.Separate hap1 and hap2
awk '$2=="1"' A01.ibd > A01.hap1
awk '$2=="2"' A01.ibd > A01.hap2

# 4.sort
mkdir hap1 hap2
sort -t $'\t' -k5,5 -k6,6n A01.hap1 > ./hap1/hap1.sort
sort -t $'\t' -k5,5 -k6,6n A01.hap2 > ./hap2/hap2.sort

# 5.Split each sample into a file
cd hap1
awk 'BEGIN{OFS="\t"} {print $5,$6,$7 > $3}' hap1.sort
cd hap2
awk 'BEGIN{OFS="\t"} {print $5,$6,$7 > $3}' hap2.sort

# 6.detection of overlaped IBD
cd hap1
bedtools multiinter -header -i `ls A*` > hap1.result
cd hap2
bedtools multiinter -header -i `ls A*` > hap2.result


