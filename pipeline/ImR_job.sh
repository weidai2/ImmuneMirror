#!/bin/bash

 disease_type=$1
 thread=$2

echo "Your job has been Started....."

StartTime=`date`

echo "Job Start Time: $StartTime"
echo "======================================================"
printf "\n"

echo "Disease type: $disease_type"
echo "Thread: $thread"

printf "\n"

dir=/var/pipeline
data_dir=$dir/WES
filename=$dir/sample.list # list of samples
RNA_data_dir=$dir/RNASeq

work_dir=$dir/results

mkdir -p $work_dir/logs
logs=$work_dir/logs

mkdir -p $work_dir/bqr_output
mkdir -p $work_dir/bamfiles

mkdir -p $work_dir/mutect2_output
output=$work_dir/mutect2_output

#########v1.2#####################
mkdir -p $work_dir/RNASeq_output
RNASeq_output=$work_dir/RNASeq_output
##################################

mkdir -p $work_dir/data
data_dir2=$work_dir/data

mkdir -p $RNASeq_output/data
data_dir3=$RNASeq_output/data

mkdir -p $work_dir/tmp

bam_dir=$work_dir/bqr_output
design_stat=$dir/Ref/all.merge.sort.hg38.header.bed
design=$dir/Ref/all.merge.sort.hg38.bed
input=$work_dir/bamfiles  ###final bam files after processing

pon=0
sample_type=1 ###1 for WES; 2 for RNASeq
processDay=`date +%Y%m%d`

declare -a patient
	
while read -r pID sID gID pirID RNA remainder; do
	patient=("${patient[@]}" $pID)
	sample=$sID
	ID=$pID$gID
	
	RNA_sample=$RNA
  
  RNA_dir=$RNA_data_dir
  
	echo "sample is " $sample
	echo "RNA sample is " $RNA_sample
  echo "RNA samples dir: " $RNA_dir
	
  ###########################################################################################################
	ln -s $data_dir/${sample}_R1.fq.gz $data_dir2/${ID}_R1.fq.gz
 	ln -s $data_dir/${sample}_R2.fq.gz $data_dir2/${ID}_R2.fq.gz
	
  ###########################################################################################################
        currentTime=`date`
        echo ${currentTime}"\tstart pre-process....................................."
 	pipeline=$dir/pipeline/process.WES.final.sh
	bash $pipeline $sample $ID $work_dir $data_dir $thread $input 1>$logs/${processDay}_${ID}.process 2>&1
  
 #---------------------------------------------------------------------- QC -----------------------------------------
  currentTime=`date`
  
  echo ${currentTime}"\tstart QC bamfile....................................."
  pipeline=$dir/pipeline/mutation/bam.stat.final.sh
  bash $pipeline $ID $bam_dir $work_dir $thread $design_stat 1>$logs/${processDay}_${ID}.QC 2>&1
 
                                         # checking the coverage .......
p=`echo -n $ID | tail -c 1`
if [ $p == 'N' ] 
then
  coverage_val=30
else
  coverage_val=40
 fi 

file_hs=$work_dir/stat/$ID.hs

mean_cov=$(awk 'NR==8 {print $22}' $file_hs)

b=${mean_cov%.*} # rounded down , e.g., 50.5 = 50
if [ $b -lt $coverage_val ]
 then
 	printf "------------------------\n\n"
	echo "**************** Processing has been stopped because of the low coverage for the sample:" $ID
	printf "----------------------\n\n"
  continue
fi
 
 	####################---------------------------  RNA Seq processing ---------------------- ###############################################
	if [ $RNA_sample == "YES" ]
	then
     {
     echo echo ${currentTime}"\tstart RNA Seq processing ....................................."

     ln -s $RNA_dir/${sample}_R1.fq.gz $data_dir3/${ID}_R1.fq.gz
     ln -s $RNA_dir/${sample}_R2.fq.gz $data_dir3/${ID}_R2.fq.gz
   
	  pipeline=$dir/pipeline/RNA_Seq/RNA_Seq_job.sh
  
	 bash $pipeline $RNASeq_output $RNA_dir $sample $ID $thread 1>$logs/${processDay}_${ID}.RNAseq.process 2>&1
	}
  fi
 
 ### ----------------------------------- Germline Variant Calling ------------------------

	#######################################################################
	echo [$currentTime]\\ Goodluck! HaplotypeCaller started
	pipeline=$dir/pipeline/germline_variant_calling.sh
  bash $pipeline $ID $work_dir $bam_dir $thread $design 1>$logs/${processDay}_${ID}.gvcf 2>&1
  
	# ------ ANNOVAR
  p1=`echo -n $ID | tail -c 1`
  if [ $p == 'N' ] 
  then
  echo ${currentTime}"\t Start runing ANNOVAR....................................."
  vcf_dir=$work_dir/germline_output
  pipeline=$dir/pipeline/annovar.vcf.sh
  bash $pipeline $pID $work_dir $vcf_dir 1>$logs/${processDay}_${pID}N.anno 2>&1
  fi
  
	echo ${currentTime}"\tstart calling HLA subtype for CLASS I....................................."
	mkdir -p $work_dir/OptiType_result
	output_hla=$work_dir/OptiType_result
  pipeline=$dir/pipeline/HLA/OptiType.sh
  bash $pipeline $ID $work_dir $data_dir2 $output_hla $sample_type 1>$logs/${processDay}_${ID}.OptiTYPE 2>&1
	
	echo ${currentTime}"\tstart calling HLA subtype for CLASS II....................................."
	pipeline=/opt/PHLAT/phlat-1.0/phlat.sh
	tag=${ID}
	mkdir -p $work_dir/phlat_result
	if test -f "$work_dir/phlat_result/${tag}"; then
	echo "remove existing folder $work_dir/phlat_result/${tag}"
		rm -r $work_dir/phlat_result/${tag}
	fi
	mkdir -p $work_dir/phlat_result/${tag}
	output_phlat=$work_dir/phlat_result/${tag}
	read1=${tag}_R1.fq.gz
	read2=${tag}_R2.fq.gz
  	echo "data dir2:$data_dir2"
	echo "output_phlat:$output_phlat"
	echo "tag:$tag"
	echo "read1: $read1"
	echo "read2: $read2"
	bash $pipeline $data_dir2 $output_phlat $tag $read1 $read2 1>$logs/${processDay}_${ID}.phlat 2>&1
done < $filename

# ------------------------------------------------------------------------------------------------ paired (N & T) samples ------------

	sorted_pIDs=($(echo "${patient[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
	echo "${sorted_pIDs[@]}"
 #### ---------------
  mkdir -p $work_dir/pvac_OptiType_output
  mkdir -p $work_dir/pvac_phlat_output
  script_pvac=$dir/pipeline/HLA
  #*****************************************

for val in ${sorted_pIDs[@]}; do
	normal=${val}N
	tumor=${val}T
	lymph=${val}L
	
mkdir -p $dir/results/germline_output
qc_dir=$dir/results/germline_output

 if [ ! -d  $qc_dir/$normal ];
then
    echo "Processing has been stopped for $normal vs $tumor pair because of the low data quality for $normal!"
    echo "Processing has been stopped for $normal vs $lymph pair because of the low data quality for $normal!"
    continue
 fi
    
 if [ ! -d  $qc_dir/$tumor ];
   then
   echo "Processing has been stopped for $normal vs $tumor pair because of the low data quality for $tumor! or you have no $tumor sample!"
 else 
	echo "Processing is started for the $normal vs $tumor pair.........."
	
	file1=$bam_dir/${normal}.recal.bam
	file2=$bam_dir/${tumor}.recal.bam
	if test -f "$file1"; then
		if test -f "$file2"; then
	echo ${currentTime}"\tstart calling mutations by mutect2....................................."
	pipeline=$dir/pipeline/mutation/mutect2.sh
	bash $pipeline $normal $tumor $work_dir $bam_dir $thread $design $pon 1>$logs/${processDay}_${tumor}.mutect2 2>&1
	echo ${currentTime}"\tstart filtering mutations....................................."
	pipeline=$dir/pipeline/mutation/mutect2.vcf.filter.sh
	bash $pipeline $tumor $work_dir $output/$tumor $output/$tumor 1>$logs/${processDay}_${tumor}.mutect2.filter 2>&1
	echo ${currentTime}"\tstart annotating the mutations by funcotator....................................."
	pipeline=$dir/pipeline/mutation/funcotator_script.sh
	bash $pipeline $tumor $work_dir $output $thread 1>$logs/${processDay}_${tumor}.funcotator 2>&1
   
   #--------------------------- VEP -------------------------------------------------------- 
   echo ${currentTime}"\tstart VEP......................................."
      type=$disease_type
        RNA_on=$RNASeq_output/salmon/${tumor}/quant.id.sf
        if test -f "${RNA_on}"; then
        pipeline=$dir/pipeline/HLA/vcf.vep2.RNA.sh
        bash $pipeline $tumor $output/$tumor $output/$tumor $RNA_on 1>$logs/${processDay}_${tumor}.VEP 2>&1
        else
        echo $RNA_on "is not exist!!!!........"
        pipeline=$dir/pipeline/HLA/vcf.vep2.RNA.sh
        RNA_id=$dir/Ref/RNA_data/${type}.quant.id.sf
        bash $pipeline $tumor $output/$tumor $output/$tumor $RNA_id 1>$logs/${processDay}_${tumor}.VEP 2>&1
         fi
  
  #### ============================== PVAC ====================================== **********
  input_pvac=$work_dir/mutect2_output/${tumor}
  mkdir -p $work_dir/pvac_OptiType_output/${tumor}
  output_pvac=$work_dir/pvac_OptiType_output/${tumor}
  hlas=`sed 1d $work_dir/OptiType_result/${tumor}/${tumor}_result.tsv|cut -f 2-7|awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}'|tr ' ' ','|sed 's/.$//; s/A/HLA-A/g;s/B/HLA-B/g;s/C/HLA-C/g'`
  pipeline=$dir/pipeline/HLA/pvacseq.RNA.sh 
  bash $pipeline $tumor $hlas $input_pvac $output_pvac $thread 1>$logs/${processDay}_${tumor}.pvacseq_ClassI 2>&1
  hlas2=`perl $dir/pipeline/HLA/hla.pl $work_dir/phlat_result/${tumor}/${tumor}_HLA.sum`
  mkdir -p $work_dir/pvac_phlat_output/${tumor}
  output2_pvac=$work_dir/pvac_phlat_output/${tumor}
  bash $pipeline $tumor $hlas2 $input_pvac $output2_pvac $thread 1>$logs/${processDay}_${tumor}.pvacseq_ClassII 2>&1

  pipeline=$dir/pipeline/HLA/antigen.garnish.net.sh
  bash $pipeline $tumor $output_pvac/MHC_Class_I/${tumor}.filtered.tsv $output_pvac/MHC_Class_I 1>$logs/${processDay}_${tumor}.pvacseq_ClassI.ag 2>&1
  
  pipeline=$dir/pipeline/HLA/antigen.garnish.sh
  bash $pipeline $tumor $output2_pvac/MHC_Class_II/${tumor}.filtered.tsv $output2_pvac/MHC_Class_II 1>$logs/${processDay}_${tumor}.pvacseq_ClassII.ag 2>&1
  
   # Prediction by our ML method
  pipeline=$dir/pipeline/HLA/predict.sh
  bash $pipeline $tumor $output_pvac/MHC_Class_I $output_pvac/MHC_Class_I 1>$logs/${processDay}_${tumor}.predict_ClassI.ag 2>&1
 
 
 # ====================================================== Columns selection================
 
   mkdir -p $work_dir/final_outputs
   
   pipeline=$dir/pipeline/colSelect.sh
   
bash $pipeline $tumor $output_pvac/MHC_Class_I/${tumor}.features.netctlpan.predict.tsv $work_dir/final_outputs 1>$logs/${processDay}_${tumor}.ColumnsSelection.ag 2>&1
 
 
 ##==================================================================== MSIsensor-pro: for Microsatellite Instability detection ==================
 SN1=$input/${normal}.sorted.dedup.bam
 ST1=$input/${tumor}.sorted.dedup.bam
 
 if test -f "$SN1"; then
		if test -f "$ST1"; then
 echo ${currentTime}"\tStart calling MSIsensor-pro....................................."
 pipeline=$dir/pipeline/msi_pro_script.sh
 bash $pipeline $normal $tumor $work_dir $input $thread 1>$logs/${processDay}_${tumor}.msi.log 2>&1
 echo ${currentTime}"\tMicrosatellite Instability process has been completed by MSIsensor-pro....................................."
 echo ${currentTime}"\tHMRF pipeline complete....................................."
 
 
#########################################################################################################
##
## ---------------------------------------- Analysis report generation -----------------------------------------
   
  pipeline=$dir/pipeline/analysis_report.sh
   
  bash $pipeline $normal $tumor $work_dir $disease_type 1>$logs/${processDay}_${tumor}.analysis_report.ag 2>&1

############################################################################################################
 
		else 
		echo ${currentTime}"\t$SN1 does not exist"
	       	fi
	else
	echo ${currentTime}"\t$ST1 does not exist"
	fi

 else 
		echo ${currentTime}"\t$file1 does not exist"
	       	fi
else
	echo ${currentTime}"\t$file2 does not exist"
	fi
 
	# *************************************************************************************************************
  # *************************************************************** ----- Lymph Node ---- ***********************
  # **************************************************************************************************************
  
   if [ ! -d  $qc_dir/$lymph ];
   then
   echo "Processing has been stopped for $normal vs $lymph pair because of the low data quality for $lymph or or you have no $lymph sample!!"
   continue
   fi
  
  echo "Processing is started for the $normal vs $lymph pair.........."
  
  file3=$bam_dir/${lymph}.recal.bam
	if test -f "$file1"; then
		if test -f "$file3"; then
	echo ${currentTime}"\tstart calling mutations by mutect2....................................."
	pipeline=$dir/pipeline/mutation/mutect2.sh
	bash $pipeline $normal $lymph $work_dir $bam_dir $thread $design $pon 1>$logs/${processDay}_${lymph}.mutect2 2>&1
	echo ${currentTime}"\tstart filtering mutations....................................."
	pipeline=$dir/pipeline/mutation/mutect2.vcf.filter.sh
	bash $pipeline $lymph $work_dir $output/$lymph $output/$lymph 1>$logs/${processDay}_${lymph}.mutect2.filter 2>&1
	echo ${currentTime}"\tstart annotating the mutations by funcotator....................................."
	pipeline=$dir/pipeline/mutation/funcotator_script.sh
	bash $pipeline $lymph $work_dir $output $thread 1>$logs/${processDay}_${lymph}.funcotator 2>&1
 
 echo ${currentTime}"\tstart VEP......................................."
   type=$disease_type       
        RNA_on=$RNASeq_output/salmon/${lymph}/quant.id.sf
        if test -f "${RNA_on}"; then
        pipeline=$dir/pipeline/HLA/vcf.vep2.RNA.sh
        bash $pipeline $lymph $output/$lymph $output/$lymph $RNA_on 1>$logs/${processDay}_${lymph}.VEP 2>&1
        else
        echo $RNASeq_output "is not exist....."
        pipeline=$dir/pipeline/HLA/vcf.vep2.RNA.sh
        RNA_id=$dir/Ref/RNA_data/${type}.quant.id.sf
        bash $pipeline $lymph $output/$lymph $output/$lymph $RNA_id 1>$logs/${processDay}_${lymph}.VEP 2>&1
         fi
 
  #### ============================== PVAC ====================================== **********
  input_pvac=$work_dir/mutect2_output/${lymph}
  mkdir -p $work_dir/pvac_OptiType_output/${lymph}
  output_pvac=$work_dir/pvac_OptiType_output/${lymph}
  hlas=`sed 1d $work_dir/OptiType_result/${lymph}/${lymph}_result.tsv|cut -f 2-7|awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}'|tr ' ' ','|sed 's/.$//; s/A/HLA-A/g;s/B/HLA-B/g;s/C/HLA-C/g'`
  pipeline=$dir/pipeline/HLA/pvacseq.RNA.sh
  bash $pipeline $lymph $hlas $input_pvac $output_pvac $thread 1>$logs/${processDay}_${lymph}.pvacseq_ClassI 2>&1

  hlas2=`perl $dir/pipeline/HLA/hla.pl $work_dir/phlat_result/${lymph}/${lymph}_HLA.sum`
   mkdir -p $work_dir/pvac_phlat_output/${lymph}
   output2_pvac=$work_dir/pvac_phlat_output/${lymph}
  bash $pipeline $lymph $hlas2 $input_pvac $output2_pvac $thread 1>$logs/${processDay}_${lymph}.pvacseq_ClassII 2>&1 

   pipeline=$dir/pipeline/HLA/antigen.garnish.net.sh
  bash $pipeline $lymph $output_pvac/MHC_Class_I/${lymph}.filtered.tsv $output_pvac/MHC_Class_I 1>$logs/${processDay}_${lymph}.pvacseq_ClassI.ag 2>&1
   
   pipeline=$dir/pipeline/HLA/antigen.garnish.sh
  bash $pipeline $lymph $output2_pvac/MHC_Class_II/${lymph}.filtered.tsv $output2_pvac/MHC_Class_II 1>$logs/${processDay}_${lymph}.pvacseq_ClassII.ag 2>&1
   
   # Prediction by our ML method
  pipeline=$dir/pipeline/HLA/predict.sh
 bash $pipeline $lymph $output_pvac/MHC_Class_I $output_pvac/MHC_Class_I 1>$logs/${processDay}_${lymph}.predict_ClassI.ag 2>&1
 
 
 # ====================================================== Columns selection================
 
   mkdir -p $work_dir/final_outputs
   
   pipeline=$dir/pipeline/colSelect.sh
   
bash $pipeline $lymph $output_pvac/MHC_Class_I/${lymph}.features.netctlpan.predict.tsv $work_dir/final_outputs 1>$logs/${processDay}_${lymph}.ColumnsSelection.ag 2>&1
 
 ##==================================================================== MSIsensor-pro: for Microsatellite Instability detection ==================  
 SL1=$input/${lymph}.sorted.dedup.bam
 
 if test -f "$SN1"; then
		if test -f "$SL1"; then
 echo ${currentTime}"\tStart calling MSIsensor-pro....................................."
 pipeline=$dir/pipeline/msi_pro_script.sh
 bash $pipeline $normal $lymph $work_dir $input $thread 1>$logs/${processDay}_${lymph}.msi.log 2>&1
 echo ${currentTime}"\tMicrosatellite Instability process has been completed by MSIsensor-pro....................................."
 echo ${currentTime}"\tHMRF pipeline complete....................................."
 
 #########################################################################################################
##
## ---------------------------------------- Analysis report generation -----------------------------------------
   
  pipeline=$dir/pipeline/analysis_report.sh
   
  bash $pipeline $normal $lymph $work_dir $disease_type 1>$logs/${processDay}_${lymph}.analysis_report.ag 2>&1

############################################################################################################

		else 
		echo ${currentTime}"\t$SN1 does not exist"
	       	fi
	else
	echo ${currentTime}"\t$SL1 does not exist"
	fi

 else 
		echo ${currentTime}"\t$file1 does not exist"
	       	fi
else
	echo ${currentTime}"\t$file3 does not exist"
	fi
fi
 
done

printf "\n"


echo "================================================================================="
echo "Your job has been completed!"

EndTime=`date`

echo "Job Completion Time: $EndTime"
