
normal=$1
tumor=$2
work_dir=$3
input=$4
thread=$5

refPre=/var/pipeline/Ref/GATK_bundle/hg38/Homo_sapiens_assembly38.fasta


msi_dir=/opt/bin/msisensor-pro

mkdir -p $work_dir/msi
mkdir -p $work_dir/msi/$tumor

output=$work_dir/msi/$tumor

## step-1. scan : scan the reference genome to get microsatellites information
#msisensor-pro scan -d $refPre -o $work_dir/msi/reference.site

ref=/var/pipeline/Ref/reference.hg38.site
## step-2. msi : evaluate MSI using paired tumor-normal sequencing data
$msi_dir msi -d $ref -n $input/${normal}.sorted.dedup.bam -t $input/${tumor}.sorted.dedup.bam -o $output/${tumor}
