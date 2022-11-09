
work_dir=$1
thread=$2
ID=$3
strand=$4

bam=$work_dir/star/${ID}/pass1/Aligned.sortedByCoord.out.bam
mkdir -p $work_dir/QC
output=$work_dir/QC

#############Software#############
picard=/opt/picard-2.17.4

################################## 

################ Generate rRNA interval for QC ####################
gtf=/var/pipeline/Ref/v27/gencode.v27.annotation.gtf

interval_dir=/var/pipeline/Ref/v27
samtools view -H $bam > $interval_dir/gencodev27.hg38.rRNA.interval
grep rRNA $gtf|awk 'BEGIN{OFS="\t"}{if($3="gene")print $1,$4,$5,$7,$10}' >> $interval_dir/gencodev27.hg38.rRNA.interval

############ Picard QC ##############
samtools index $bam
rRNA=$interval_dir/gencodev27.hg38.rRNA.interval

refPre=/var/pipeline/Ref/v27/gencode.v27.ref_flat.txt

#### Strand = 1 indicates that is a reverse-strand library
if [ $strand -eq 1 ]
then
	java -jar $picard/picard.jar CollectRnaSeqMetrics \
		STRAND=SECOND_READ_TRANSCRIPTION_STRAND \
		I=$bam \
		O=$output/${ID}.RNA_Metrics \
		REF_FLAT=$refPre\
		RIBOSOMAL_INTERVALS=$rRNA \
		VALIDATION_STRINGENCY=LENIENT

#### Strand = 2 indicates that is a forward-strand library
elif [ $strand -eq 2 ]
then
	java -jar $picard/picard.jar CollectRnaSeqMetrics \
		STRAND=FIRST_READ_TRANSCRIPTION_STRAND \
		I=$bam \
		O=$output/${ID}.RNA_Metrics \
		REF_FLAT=$refPre \
		RIBOSOMAL_INTERVALS=$rRNA \
		VALIDATION_STRINGENCY=LENIENT 

#### Strand = 0 indicates this is an unstranded library
elif [ $strand -eq 0 ]
then
	java -jar $picard/picard.jar CollectRnaSeqMetrics \
		STRAND=NONE \
		I=$bam \
		O=$output/${ID}.RNA_Metrics \
		REF_FLAT=$refPre \
		RIBOSOMAL_INTERVALS=$rRNA \
		VALIDATION_STRINGENCY=LENIENT
fi


#### Alignment Metrics
java -jar $picard/picard.jar CollectAlignmentSummaryMetrics \
        INPUT=$bam \
        OUTPUT=$output/${ID}.alignmentmetrics \
	R=$interval_dir/GRCh38.p10.genome.fa \
	VALIDATION_STRINGENCY=LENIENT

################################
