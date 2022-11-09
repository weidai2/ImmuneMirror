
################ ----------------- Germline Variant Calling ----------------------
sample=$1
work_dir=$2
bam_dir=$3
thread=$4
design=$5

refPre=/var/pipeline/Ref/GATK_bundle/hg38/Homo_sapiens_assembly38.fasta

gatk=/opt/gatk-4.1.8.0/gatk

cd $work_dir
mkdir -p $work_dir/germline_output
mkdir -p $work_dir/germline_output/$sample

output=$work_dir/germline_output/$sample

$gatk --java-options "-Xmx20g -XX:ParallelGCThreads=$thread" HaplotypeCaller \
        -R $refPre \
        -I $bam_dir/${sample}.recal.bam \
        --tmp-dir $work_dir/tmp \
        -O $output/${sample}.g.vcf.gz \
        -ERC GVCF
        -L $design

echo [$currentTime]\\tJob done!

processDay=`date +%Y%m%d`
echo [$currentTime]\\tStart variant calling
$gatk --java-options "-Xmx20g -XX:ParallelGCThreads=$thread" GenotypeGVCFs \
       -R $refPre \
       -V $output/${sample}.g.vcf.gz \
       -L $design \
       --tmp-dir $work_dir/tmp \
       -O $output/${sample}.vcf.gz

echo [$currentTime]\\tJob done!

### -------------------Funcotator tool-------------
mkdir -p $work_dir/germline_output/funcotator_output
mkdir -p $work_dir/germline_output/funcotator_output/$sample

input_fn=$work_dir/germline_output/$sample

output_fn=$work_dir/germline_output/funcotator_output/$sample

  echo ${currentTime}"\tstart annotating the mutations for germline variannt calling by Funcotator....................................."

 $gatk --java-options "-Xmx20g -XX:ParallelGCThreads=$thread" Funcotator \
     --variant $input_fn/${sample}.vcf.gz \
     --reference $refPre \
     --ref-version hg38 \
     --tmp-dir $work_dir/tmp \
     --data-sources-path /var/pipeline/Ref/GATK_bundle/funcotator_bundle/funcotator_dataSources.v1.2.20180329 \
     --output $output_fn/${sample}.variants.funcotated.maf \
     --output-file-format MAF
 
 currentTime=`date`
 echo [$currentTime]\\Analysis finised by GATK Funcotator for Germline Variant Calling Samples!
 
