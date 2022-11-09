normal=$1
tumor=$2
work_dir=$3
bam_dir=$4
thread=$5
design=$6
pon=$7

refPre=/var/pipeline/Ref/GATK_bundle/hg38/Homo_sapiens_assembly38.fasta

gatk=/opt/gatk-4.1.8.0/gatk

cd $work_dir
mkdir -p $work_dir/mutect2_output/
mkdir -p $work_dir/mutect2_output/$tumor

output=$work_dir/mutect2_output/$tumor

if [ $pon -eq 1 ]
	then

$gatk --java-options "-Xmx20g -XX:ParallelGCThreads=$thread" Mutect2 \
	-R $refPre \
	-I $bam_dir/${tumor}.recal.bam \
	-tumor $tumor \
	-I $bam_dir/${normal}.recal.bam \
	-normal $normal \
	--tmp-dir $work_dir/tmp \
	-germline-resource /var/pipeline/Ref/GATK_bundle/Mutect2/af-only-gnomad.hg38.vcf.gz \
	-pon $bam_dir/normal/pon.vcf.gz   \
	--f1r2-tar-gz $output/${tumor}.f1r2.tar.gz \
	-L $design \
	-O $output/${tumor}.vcf.gz 
fi


if [ $pon -eq 0 ]
	then

$gatk --java-options "-Xmx20g -XX:ParallelGCThreads=$thread" Mutect2 \
	-R $refPre \
	-I $bam_dir/${tumor}.recal.bam \
	-tumor $tumor \
	-I $bam_dir/${normal}.recal.bam \
	-normal $normal \
	--tmp-dir $work_dir/tmp \
	-germline-resource /var/pipeline/Ref/GATK_bundle/Mutect2/af-only-gnomad.hg38.vcf.gz \
	--f1r2-tar-gz $output/${tumor}.f1r2.tar.gz \
	-L $design \
	-O $output/${tumor}.vcf.gz
														
fi

$gatk LearnReadOrientationModel -I $output/${tumor}.f1r2.tar.gz \
	--tmp-dir $work_dir/tmp \
	-O $output/${tumor}.read-orientation-model.tar.gz

exac=/var/pipeline/Ref/GATK_bundle/Mutect2/GetPileupSummaries/small_exac_common_3.hg38.vcf.gz

$gatk GetPileupSummaries \
	--tmp-dir $work_dir/tmp \
	-I $bam_dir/${tumor}.recal.bam \
	-V $exac \
	-L $exac \
	-O $output/${tumor}.getpileupsummaries.table

$gatk CalculateContamination \
	--tmp-dir $work_dir/tmp \
	-I $output/${tumor}.getpileupsummaries.table \
	-tumor-segmentation $output/${tumor}.segments.table \
	-O $output/${tumor}.contamination.table

$gatk FilterMutectCalls -V $output/${tumor}.vcf.gz \
	-R $refPre \
	--tmp-dir $work_dir/tmp \
	--tumor-segmentation $output/${tumor}.segments.table \
	--contamination-table $output/${tumor}.contamination.table \
	--ob-priors $output/${tumor}.read-orientation-model.tar.gz \
	-O $output/${tumor}.filtered.vcf

currentTime=`date`
echo [$currentTime]\\Finish calling mutations by Mutect2!
