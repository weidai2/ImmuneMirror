#!/bin/bash

sample=$1
input_dir=$2
output_dir=$3

R CMD BATCH '--args sample="'$sample'" input="'$input_dir'" output="'$output_dir'"' /var/pipeline/pipeline/HLA/predict.r $output_dir/$sample.predict.Rout

echo "Prediction is done!" 

echo "Output file:" "$output_dir/${sample}.features.netctlpan.predict.tsv"
