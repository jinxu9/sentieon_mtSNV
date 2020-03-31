#!/bin/sh

###reference information
fasta=/public/home/tangzj/hg19/hg19_all.fa
dbsnp=/public/home/tangzj/hg19/SNP/dbsnp_138.hg19.vcf
known_1000G_indels=/public/home/tangzj/hg19/SNP/1000G_phase1.snps.high_confidence.hg19.sites.vcf
known_Mills_indels=/public/home/tangzj/hg19/SNP/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf

# Set SENTIEON_LICENSE if it is not set in the environment
export SENTIEON_LICENSE=/public/home/tangzj/test/sentieon-genomics-201911/LICENSE_DIR/Sun_Yet-sen_University_eval.lic
#exec /public/home/tangzj/test/sentieon-genomics-201911/bin/sentieon licsrvr --start /public/home/tangzj/test/sentieon-genomics-201911/LICENSE_DIR/LICENSE_FILE.lic
# Update with the location of the Sentieon software package
SENTIEON_INSTALL_DIR=/public/home/tangzj/test/sentieon-genomics-201911

# resource 
nt=36 #number of threads to use in computation

# ******************************************
# 0. Setup
# ******************************************

#Sentieon proprietary compression
bam_option="--bam_compression 1"
# speed up memory allocation malloc in bwa
export LD_PRELOAD=$SENTIEON_INSTALL_DIR/lib/libjemalloc.so
export MALLOC_CONF=lg_dirty_mult:-1

# ******************************************
# 2.Input
# ******************************************
sample="tumor"
group="1"
platform="ILLUMINA"
fastq_1="GSE122577_R1.fastq.gz"
fastq_2="GSE122577_R2.fastq.gz"
# ******************************************
# 3. Alignment
# ******************************************

( $SENTIEON_INSTALL_DIR/bin/sentieon bwa mem -M -R "@RG\tID:$sample\tSM:$sample\tPL:$platform" -t $nt -K 10000000 $fasta  $fastq_1 $fastq_2 || echo -n 'error' ) | $SENTIEON_INSTALL_D
IR/bin/sentieon util sort $bam_option -r $fasta -o sorted.bam -t $nt --sam2bam -i -

# ******************************************
# 4. dedup
# ******************************************

$SENTIEON_INSTALL_DIR/bin/sentieon driver -t $nt -i sorted.bam --algo LocusCollector --fun score_info score.txt 
$SENTIEON_INSTALL_DIR/bin/sentieon driver -t $nt -i sorted.bam --algo Dedup --rmdup --score_info score.txt --metrics dedup_metrics.txt $bam_option deduped.bam

# ******************************************
# 5. Indel Realigner
# ******************************************

$SENTIEON_INSTALL_DIR/bin/sentieon driver -r $fasta -t $nt -i deduped.bam --algo Realigner -k $known_Mills_indels -k $known_1000G_indels $bam_option realigned.bam

# ******************************************
# 6. Base recalibration
# ******************************************
#$SENTIEON_INSTALL_DIR/bin/sentieon driver -r $fasta -t $nt -i realigned.bam --algo QualCal -k $dbsnp -k $known_Mills_indels -k $known_1000G_indels recal_data.table


# ******************************************
# 7. # Matching GATK 3.7, 3.8, 4.0 
# SNV calling 
# ******************************************


#$SENTIEON_INSTALL_DIR/bin/sentieon driver  -r $fasta  -t $nt   -i  deduped.bam --algo TNscope --filter_t_alt_frac 0.005  output-TNscope.vcf.gz 
#$SENTIEON_INSTALL_DIR/bin/sentieon driver  -r $fasta  -t $nt   -i  deduped.bam --algo TNscope  --tumor_sample $sample --min_tumor_allele_frac 0.01  --interval chrM:0-16024  output-TNscope.vcf.gz 
$SENTIEON_INSTALL_DIR/bin/sentieon driver  -r $fasta  -t $nt   -i  deduped.bam --algo TNscope  --tumor_sample $sample --min_tumor_allele_frac 0.01  output-TNscope.vcf.gz 




