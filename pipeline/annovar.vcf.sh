#!/bin/bash

pID=$1
work_dir=$2 # work_dir=$dir/results
vcf_dir=$3 # $work_dir/germline_output

anno_dir=/var/pipeline/Ref/annovar

file=$vcf_dir/${pID}N/${pID}N

anno_db=$anno_dir/humandb

# mkdir -p $vcf_dir/AnnoVar

# cd $vcf_dir/AnnoVar

perl $anno_dir/convert2annovar.pl  -allsample -withfreq -include -comment -format vcf4 ${file}.vcf.gz --outfile ${file}.input 

grep -v "#" ${file}.input>${file}.input2


# snp138 - not available for hg38

# https://annovar.openbioinformatics.org/en/latest/user-guide/region/

# http://hgdownload.cse.ucsc.edu/goldenpath/hg38/database/
# perl annotate_variation.pl -build hg38 -downdb phastConsElements30way humandb/
# perl annotate_variation.pl -build hg38 -downdb snp151 humandb/


# https://annovar.openbioinformatics.org/en/latest/user-guide/download/#additional-databases

perl $anno_dir/table_annovar.pl ${file}.input2 $anno_db -buildver hg38 -protocol refGene,knowngene,phastConsElements30way,genomicSuperDups,esp6500siv2_all,1000g2015aug_all,1000g2015aug_eas,exac03,snp151,ljb26_all,cosmic70,clinvar_20170905 -operation g,g,r,r,f,f,f,f,f,f,f,f -nastring NA -otherinfo -outfile $file.anno

cut -f1-64,68- ${file}.anno.hg38_multianno.txt>${file}_tmp.txt
head -n1 ${file}_tmp.txt>header.anno
zcat $file|grep "#CHROM" >header.vcf
paste header.anno header.vcf>header
sed 1d ${file}_tmp.txt > ${file}_tmp2.txt 
cat header ${file}_tmp2.txt >${file}_anno.txt


rm ${file}.anno.* ${file}.input* header* ${file}_tmp*
