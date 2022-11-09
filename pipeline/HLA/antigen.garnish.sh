
sample=$1
input_dir=$2
output_dir=$3

#/opt/ncbiblast
export AG_DATA_DIR=/opt/antigen.garnish

R CMD BATCH '--args sample="'$sample'" input="'$input_dir'" output="'$output_dir'"' /var/pipeline/pipeline/HLA/ag3.r $output_dir/$sample.Rout

sed 's/"//g' $output_dir/${sample}.dissimilarity.tsv>$output_dir/${sample}.features.tsv

rm $output_dir/${sample}.dissimilarity.tsv
