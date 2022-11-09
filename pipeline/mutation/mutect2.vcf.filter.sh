############################################################################
#########filter mutect2 output to get the high-confidence mutations ########
############################################################################

sample=$1
work_dir=$2
input=$3
output=$4

gatk=/opt/gatk-4.1.8.0/gatk

$gatk --java-options "-Xmx20g" SelectVariants \
	--tmp-dir $work_dir/tmp \
	-V $input/${sample}.filtered.vcf \
	-O $output/${sample}.biAllelic.vcf.gz \
	--restrict-alleles-to BIALLELIC  

$gatk --java-options "-Xmx20g" SelectVariants \
	--tmp-dir $work_dir/tmp \
	-V $input/${sample}.filtered.vcf \
	-O $output/${sample}.multiAllelic.vcf.gz \
	--restrict-alleles-to MULTIALLELIC 

vcftools --gzvcf $output/${sample}.biAllelic.vcf.gz --out $output --remove-filtered-all --recode  --stdout | bgzip -c > ${output}/${sample}.biAllelic.PASS.vcf.gz
tabix -p vcf ${output}/${sample}.biAllelic.PASS.vcf.gz

vcftools --gzvcf $output/${sample}.multiAllelic.vcf.gz --out $output --remove-filtered-all --recode  --stdout | bgzip -c > ${output}/${sample}.multiAllelic.PASS.vcf.gz
tabix -p vcf ${output}/${sample}.multiAllelic.PASS.vcf.gz
