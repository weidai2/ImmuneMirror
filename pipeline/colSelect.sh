#!/bin/bash
  
  sample=$1
  input_dir=$2
  output_dir=$3
  
  echo "Sample:" $sample
  
  out_file_tmp=$output_dir/${sample}.MHC_ClassI.final.prediction.tsv
  if test -f "$out_file_tmp"; then
      rm $out_file_tmp
  fi
  
  
  if test -f "$input_dir"; then # if exist
    if [[ -s "$input_dir" ]]; then # if not empty
 R CMD BATCH '--args input="'$input_dir'" output="'$output_dir'"' /var/pipeline/pipeline/summary_I.r $output_dir/${sample}.ColAdd.Rout
  filename2=$output_dir/sample.tsv
  
  # add a new column "Sample_ID" as first column
 awk -v var="$sample" 'BEGIN{FS=OFS="\t"} {print (NR>1?var:"Sample_ID"), $0}' $filename2 >$output_dir/tmp.tsv
  
   rm $filename2 # need to delete this file
  
  # select columns
R CMD BATCH '--args input="'$output_dir'" output="'$output_dir'"' /var/pipeline/pipeline/colSelect.r $output_dir/${sample}.colSelect.Rout
  
   rm $output_dir/tmp.tsv

mv $output_dir/sample2.tsv $output_dir/${sample}.MHC_ClassI.final.prediction.tsv

echo "Final Output MHC Class I:" "$output_dir/${sample}.MHC_ClassI.final.prediction.tsv"
         
        else
            echo "MHC class I Prediction file is empty!">$output_dir/${sample}.MHC_ClassI.final.prediction.tsv
        fi
     
   else
       echo "No output for MHC class I Prediction!">$output_dir/${sample}.MHC_ClassI.final.prediction.tsv
   fi 
   
echo "Columns selection is done!"


#========= copy MHC class II result file
mhcii_out=$output_dir/${sample}.MHC_ClassII.final.tsv
if test -f "$mhcii_out"; then
      rm $mhcii_out
  fi

work_dir=/var/pipeline/results
mhcii=$work_dir/pvac_phlat_output/${sample}/MHC_Class_II/${sample}.features.tsv

if test -f "$mhcii"; then # if exist
    if [[ -s "$mhcii" ]]; then # if not empty
      cp $mhcii $output_dir/${sample}.MHC_ClassII.final.tsv
      echo "Final Output MHC Class II:" "$output_dir/${sample}.MHC_ClassII.final.tsv"
         
        else
            echo "MHC class II result file is empty!">$output_dir/${sample}.MHC_ClassII.final.tsv
        fi
     
   else
       echo "No output for MHC class II!">$output_dir/${sample}.MHC_ClassII.final.tsv
   fi 

