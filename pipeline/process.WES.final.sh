sample=$1 # sample name
ID=$2 # unique sample ID for per run
work_dir=$3
data_dir=$4 # samples directory
thread=$5
input=$6 # directory for BAM files 
###############################################################################
platform="Illumina"
refPre=/var/pipeline/Ref/GATK_bundle/hg38/Homo_sapiens_assembly38.fasta
dbsnp=/var/pipeline/Ref/GATK_bundle/hg38/dbsnp_138.hg38.vcf.gz
g1000=/var/pipeline/Ref/GATK_bundle/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz
mills=/var/pipeline/Ref/GATK_bundle/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
######BWA mapping###########
bwa_dir=/opt/bwa-0.7.17
#sam_dir=/usr/local/bin/samtools
#java_dir=/usr/bin/java
gatk=/opt/gatk-4.1.8.0/gatk
picard=/opt/picard-2.17.4

processDay=`date +%Y%m%d`

#read1=$data_dir/${sample}/${sample}_R1.fq.gz
#read2=$data_dir/${sample}/${sample}_R2.fq.gz

read1=$data_dir/${sample}_R1.fq.gz
read2=$data_dir/${sample}_R2.fq.gz

#id="1"
file=$read1
header=`zcat $file|head -n1|awk '{print substr($0,2,3)}'`

if [ $header = "SRR" ]
then
	        id=`zcat $file|head -n1|awk -F"." '{print $1}'|sed 's/@//g'`
else
		id=`zcat $file|head -n1|awk -F":" '{print $1":"$2":"$3":"$4}'|sed 's/@//g'`
fi

echo $work_dir
#mkdir -p $work_dir/data/bamfiles
cd ${work_dir}/bamfiles
##########################################################################
	echo "we are processing the $sample"
	currentTime=`date`
	echo [$currentTime]\\tStart data alignment and sorting
	$bwa_dir/bwa mem -M -t $thread -R "@RG\tID:$ID\tPL:$platform\tPU:"${ID}"_$processDay\tSM:${ID}" $refPre $read1 $read2 | samtools view -uShq 15 -|samtools sort - -o ${ID}.sorted.bam> ${ID}"_"$processDay"_"align.log 2>&1
	samtools index ${ID}.sorted.bam> ${ID}"_"$processDay"_"index.log 2>&1
	
	currentTime=`date`
	echo [$currentTime]\\tFinished indexing starting mark duplication

####  Mark Duplicates using picard
	java -Xmx15g -Djava.io.tmpdir=$work_dir/tmp -XX:ParallelGCThreads=$thread \
        -jar $picard/picard.jar MarkDuplicates \
        INPUT= ${ID}.sorted.bam \
        OUTPUT= ${ID}.sorted.dedup.bam \
        METRICS_FILE= ${ID}.dedupped.metrics \
	ASSUME_SORTED=true\
        CREATE_INDEX=true \
       	VALIDATION_STRINGENCY=LENIENT > ${ID}"_"$processDay"_"dedup.log 2>&1
	currentTime=`date`
	echo [$currentTime]\\tFinished mark duplication


	if test -f "${ID}.sorted.dedup.bam"; then
    echo "${ID}.sorted.dedup.bam exists."
	rm ${ID}.dedupped.metrics
	rm ${ID}.sorted.ba*	
	fi

        currentTime=`date`
        echo [$currentTime]\\deduplication is done!  
		

################################################################################
mkdir -p $work_dir/others
other_dir=$work_dir/others
### Base quality recalibration
echo "Goodluck! BaseRecalibrator started on `date`"
	$gatk --java-options "-Xmx15g" BaseRecalibrator \
	--tmp-dir $work_dir/tmp \
	-I ${ID}.sorted.dedup.bam \
	-R $refPre \
	-known-sites $dbsnp \
	-known-sites $g1000 \
	-known-sites $mills \
	-O $other_dir/${ID}.recal.grp

### Generate recalibrated bam file
mkdir -p $work_dir/bqr_output
bqr_dir=$work_dir/bqr_output
echo "Goodluck! PrintReads started on `date`"
	$gatk --java-options "-Xmx15g" ApplyBQSR \
	--tmp-dir $work_dir/tmp \
	-I ${ID}.sorted.dedup.bam \
	-bqsr $other_dir/${ID}.recal.grp \
	-O $bqr_dir/${ID}.recal.bam
		

currentTime=`date`
echo [$currentTime]\\pre-processing of your sample $sample is done!
