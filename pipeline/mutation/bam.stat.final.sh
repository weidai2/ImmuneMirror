sample=$1
bam_dir=$2
work_dir=$3
thread=$4
design=$5

##cd $work_dir  
mkdir -p $work_dir/stat
stat_dir=$work_dir/stat

refPre=/var/pipeline/Ref/GATK_bundle/hg38/Homo_sapiens_assembly38.fasta

currentTime=`date`
echo [$currentTime]\\t Start to collect QC matrix

picard=/opt/picard-2.17.4

        java -Xmx20g -XX:ParallelGCThreads=$thread \
	-jar $picard/picard.jar CollectHsMetrics \
	INPUT= $bam_dir/$sample.recal.bam \
	OUTPUT= $stat_dir/$sample.hs \
	BAIT_INTERVALS=$design \
	TARGET_INTERVALS=$design \
	REFERENCE_SEQUENCE=$refPre

currentTime=`date`
echo [$currentTime]\\t QC done!
