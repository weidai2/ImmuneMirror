#sample=ESCC-D10T
#input=/disk3/users/weidai/HMRF/mutect2_output
#output=/disk3/users/weidai/HMRF/mutect2_output

export PATH=/root/anaconda3/bin/:/root/anaconda3/lib/python3.7/site-packages:$PATH
  python --version
  which python
  
export PERL5LIB=/opt/vep-102:${PERL5LIB}

export PATH=/opt/vep-102/htslib:$PATH
echo $PATH

sample=$1
input=$2
output=$3
exprs=$4

dir=/var/pipeline

#mkdir -p $output/$sample
echo $output
file1=${output}/input.vcf
echo $file1

if test -f $file1; then
	rm $file1
fi
file2=${output}/input.vcf_summary.html	
if test -f $file2; then
	rm $file2
fi

refpre=$dir/Ref/v27/vep/GRCh38.p10.genome.fa.gz
gtf=$dir/Ref/v27/vep/gencode.v27.annotation.gtf.gz

vep_path=/opt/vep-102

$vep_path/./vep \
		--input_file $input/${sample}.biAllelic.PASS.vcf.gz --output_file $output/input.vcf \
		--format vcf --vcf --symbol --terms SO --tsl \
		--hgvs --fasta $refpre \
		--gtf $gtf \
		--plugin Downstream --plugin Wildtype --plugin Frameshift \
		-dir_plugins /opt/vep-102/VEP_plugins

/root/anaconda3/bin/vcf-expression-annotator $output/input.vcf $exprs --id-column Name --expression-column TPM -s ${sample} custom transcript -o $output/input.tx.vcf
#cp input.vcf input.raw.vcf
#cp input.exprs.vcf input.vcf
