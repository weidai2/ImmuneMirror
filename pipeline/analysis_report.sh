#!/bin/bash

  normal=$1
  tumor=$2
  work_dir=$3 # work_dir=$dir/results
  disease_type=$4
  
  echo "Disease type: $disease_type"
  
  dir=/var/pipeline
  out_dir=$work_dir/final_outputs
  
  mload_file=$work_dir/mutect2_output/${tumor}/input.tx.vcf
  if test -f "$mload_file"; then
  mutation_load=$(grep -v "#" $work_dir/mutect2_output/${tumor}/input.tx.vcf | cut -f1|wc -l)
  echo "Mutation Load:" $mutation_load
  else
  mutation_load='N'
  echo "Mutation Load: output is not available"
  fi
  
  
  hla_I_file=$work_dir/OptiType_result/${tumor}/${tumor}_result.tsv
  if test -f "$hla_I_file"; then
  hla_I=`sed 1d $work_dir/OptiType_result/${tumor}/${tumor}_result.tsv|cut -f 2-7|awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}'|tr ' ' ','|sed 's/.$//; s/A/HLA-A/g;s/B/HLA-B/g;s/C/HLA-C/g'`
  echo "HLA-I:" $hla_I
  else
  hla_I='N'
  echo "HLA-I type: output is not available"
  fi
  
  
  
  hla_II_file=$work_dir/phlat_result/${tumor}/${tumor}_HLA.sum
  if test -f "$hla_II_file"; then
  hla_II=`perl $dir/pipeline/HLA/hla.pl $work_dir/phlat_result/${tumor}/${tumor}_HLA.sum`
  echo "HLA-II:" $hla_II
  else
  hla_II='N'
  echo "HLA-II type: output is not available"
  fi
  
  
  neo_classI_file=$work_dir/pvac_OptiType_output/${tumor}/MHC_Class_I/${tumor}.features.netctlpan.predict.tsv
  if test -f "$neo_classI_file"; then
      if [[ -s "$neo_classI_file" ]]; then
        neo_classI=$work_dir/pvac_OptiType_output/${tumor}/MHC_Class_I/${tumor}.features.netctlpan.predict.tsv # nrow
      else 
        neo_classI='N'
        echo "HLA Class I file: output file is empty!"
      fi
  else
    neo_classI='N'
    echo "HLA Class I file: output is not available."
  fi
  
  
  
  neo_classII_file=$work_dir/pvac_phlat_output/${tumor}/MHC_Class_II/${tumor}.features.tsv
  if test -f "$neo_classII_file"; then
      if [[ -s "$neo_classII_file" ]]; then
        neo_classII=$work_dir/pvac_phlat_output/${tumor}/MHC_Class_II/${tumor}.features.tsv # nrow
      else
        neo_classII='N'
        echo "HLA Class II file: output file is empty!"
      fi 
  else
    neo_classII='N'
    echo "HLA Class II file: output is not available"
  fi
  
  
  
  msi_val_file=$work_dir/msi/${tumor}/${tumor}_somatic
  if test -f "$msi_val_file"; then
  msi_val=$work_dir/msi/${tumor}/${tumor}_somatic # nrow
  else
  msi_val='N'
  echo "MSI file: output is not available"
  fi
  
  
  
  somatic_file_dir=$work_dir/funcotator_output/${tumor}/${tumor}.variants.funcotated.maf
  if test -f "$somatic_file_dir"; then
  somatic_file=$work_dir/funcotator_output/${tumor}/${tumor}.variants.funcotated.maf
  else
  somatic_file='N'
  echo "Somatic file: output is not available"
  fi
  
  
  #germ_file=$work_dir/germline_output/funcotator_output/${normal}/${normal}.variants.funcotated.maf
  
  
rna_file_dir=$work_dir/RNASeq_output/HTSeq/${tumor}/${tumor}.count.txt
  if test -f "$rna_file_dir"; then
    if [[ -s "$rna_file_dir" ]]; then
      rna_file=$work_dir/RNASeq_output/HTSeq/${tumor}/${tumor}.count.txt
      else 
        rna_file='N'
        echo "RNA file: HTSeq output file is empty!"
      fi
  else
    rna_file='N'
    echo "RNA file: output is not available."
  fi
  
  
  anno_file_dir=$work_dir/germline_output/${normal}/${normal}_anno.txt
  if test -f "$anno_file_dir"; then
  anno_file=$work_dir/germline_output/${normal}/${normal}_anno.txt
  else
  anno_file='N'
  echo "Germline file: output is not available"
  fi
  
  
  R CMD BATCH '--args normal="'$normal'" tumor="'$tumor'" mload="'$mutation_load'" hla_I="'$hla_I'" hla_II="'$hla_II'" nclassI="'$neo_classI'" nclassII="'$neo_classII'" msi="'$msi_val'" output="'$out_dir'" in_somatic="'$somatic_file'" in_rna="'$rna_file'" in_anno="'$anno_file'" d_type="'$disease_type'"' /var/pipeline/pipeline/analysis_report.r $out_dir/$tumor.analysis_report.Rout
  
  
fig1=$out_dir/neo.I.raw.bar.png
if test -f "$fig1"; then
rm $out_dir/neo.I.raw.bar.png
fi

fig2=$out_dir/neo.I.filtered.bar.png 
if test -f "$fig2"; then
rm $out_dir/neo.I.filtered.bar.png
fi


fig3=$out_dir/neo.II.raw.bar.png 
if test -f "$fig3"; then
rm $out_dir/neo.II.raw.bar.png
fi


fig4=$out_dir/MMR_status_plot.png 
if test -f "$fig4"; then
rm $fig4
fi


fig5=$out_dir/Mload.png 
if test -f "$fig5"; then
rm $fig5
fi


fig6=$out_dir/IPRES_Hmap.png
if test -f "$fig6"; then
rm $fig6
fi


fig7=$out_dir/Rplots.pdf
if test -f "$fig7"; then
rm $fig7
fi

echo " "
echo " "

EndTime=`date`

echo $EndTime

echo "Final analysis report has been produced in the following directory: "
echo $out_dir
