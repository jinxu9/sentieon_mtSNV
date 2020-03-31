#  False positive 

When using TNscope, we got 302 SNVs on chrM. 138 of 302 markered as PASS. 

Any suggestions for SNV filter ? 

# Calling for each individual cell

Now we used merged fastq files from individual cell and call SNV on bulk.

The utilmate goal is identify SNVs in each sinlge cell and compare the comman and specific SNVs. 

We don't want to process each cell separatedly at the mapping Step, which may generated too many intermedian files. 

We can add cell barcode or cell name in the mapping step(in the final bam file). 

Is there any efficient way to do the SNV calling for each single cell?  

This maybe similar with SNV calling for multiple individuals, but for somatic SNV, not genotype.

Further more, the number of cells will be around 10000, farther more than individuals. 

# Small bug with "--interval"

As we only interested in mtDNA SNVs,  it will be efficeint to call SNVs only on chrM.
while I can't make " --interval " work.

The command and error message are copied :
CMD: 

$SENTIEON_INSTALL_DIR/bin/sentieon driver  -r $fasta  -t $nt   -i  deduped.bam --algo TNscope  --tumor_sample $sample --interval "chrM:0-16024"  --filter_t_alt_frac 0.005  output-TNscope.vcf.gz 

ERROR:

TNscope: unrecognized option '--interval' 
TNscope: unknown option 

