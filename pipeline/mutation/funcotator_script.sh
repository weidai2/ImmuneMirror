
sample=$1 # sample name
work_dir=$2
mutect2_dir=$3 # samples directory
thread=$4

refPre=/var/pipeline/Ref/GATK_bundle/hg38/Homo_sapiens_assembly38.fasta

gatk=/opt/gatk-4.1.8.0/gatk

cd $work_dir
mkdir -p $work_dir/funcotator_output
mkdir -p $work_dir/funcotator_output/$sample

input=$mutect2_dir/$sample

output=$work_dir/funcotator_output/$sample

### A VCF instantiation of the Funcotator tool
 $gatk --java-options "-Xmx20g -XX:ParallelGCThreads=$thread" Funcotator \
     --variant $input/${sample}.biAllelic.PASS.vcf.gz \
     --reference $refPre \
     --ref-version hg38 \
     --tmp-dir $work_dir/tmp \
     --data-sources-path /var/pipeline/Ref/GATK_bundle/funcotator_bundle/funcotator_dataSources.v1.2.20180329 \
     --output $output/${sample}.variants.funcotated.maf \
     --output-file-format MAF
     
currentTime=`date`
echo [$currentTime]\\Analysis finised by GATK Funcotator!
