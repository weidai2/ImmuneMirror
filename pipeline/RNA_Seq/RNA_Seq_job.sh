 
 #!/bin/bash
 
  work_dir=$1
  data_dir=$2
  sample=$3
  ID=$4
  thread=$5
  
  mkdir -p $work_dir/logs
  logs=$work_dir/logs

  processDay=`date +%Y%m%d`
  
  currentTime=`date`
  echo ${currentTime}"\tStart Alignment by STAR tool ....................................."
  
  #*** ========================================= STAR ==============================================
  
  pipeline=/var/pipeline/pipeline/RNA_Seq/star_2.7.5c.sh
  bash $pipeline $work_dir $data_dir $thread $sample $ID 1>$logs/${processDay}_${ID}.STAR.log 2>&1
 
  echo "STAR Alignment is done!" 
  currentTime=`date`
  echo ${currentTime}"\tStart Quantification by Salmon tool ....................................."
  #*** ====================================== Salmon ================================================
  pipeline=/var/pipeline/pipeline/RNA_Seq/salmon.sh
  bash $pipeline $work_dir $data_dir $thread $sample $ID 1>$logs/${processDay}_${ID}.salmon.log 2>&1
  
  ## 0 for unstrand; 1 for reverse, and 2 for forward strand;
file=$work_dir/salmon/$sample/lib_format_counts.json

isr_exp=$(jq -r '.expected_format' $file)

if [ $isr_exp == "ISF" ] 
 then
	strand=2
elif [ $isr_exp == "ISR" ]
 then
	strand=1
else 
	strand=0
fi

  echo "Quantification is done!" 
  currentTime=`date`
  echo ${currentTime}"\tStart QC ... ....................................."
  #*** ###########################===================================== QC ==================================================
  pipeline=/var/pipeline/pipeline/RNA_Seq/RNA_SeqQc.sh
  bash $pipeline $work_dir $thread $ID $strand 1>$logs/${processDay}_${ID}.QC.log 2>&1
  
  echo "QC is done!" 
  currentTime=`date`
  echo ${currentTime}"\tStart read-count by HTSeq ... ....................................."
  #*** ===================================== HTSeq ==================================================
  bam_dir=$work_dir/star/$ID/pass1
 
  pipeline=/var/pipeline/pipeline/RNA_Seq/HTSeq_new.sh
  bash $pipeline $work_dir $bam_dir $thread $ID $strand 1>$logs/${processDay}_${ID}.HTSeq.log 2>&1
  #***==========================================================================
  
  currentTime=`date`
  echo ${currentTime}"\tRNA-Seq Processing has been completed!!"
   
