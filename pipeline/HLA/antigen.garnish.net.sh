
sample=$1
input_dir=$2
output_dir=$3
export PATH=/root/anaconda3/bin/:/root/anaconda3/lib/python3.7/site-packages:$PATH
  python --version
  echo $PATH
  which python
#/opt/ncbiblast
export AG_DATA_DIR=/opt/antigen.garnish

R CMD BATCH '--args sample="'$sample'" input="'$input_dir'" output="'$output_dir'"' /var/pipeline/pipeline/HLA/ag5.r $output_dir/$sample.Rout

sed 's/"//g' $output_dir/${sample}.dissimilarity.tsv>$output_dir/${sample}.features.tsv

rm $output_dir/${sample}.dissimilarity.tsv

input_dir=$output_dir/${sample}.features.tsv

R CMD BATCH '--args sample="'$sample'" infile="'$input_dir'" outfile="'$output_dir'"' /var/pipeline/pipeline/HLA/netctlpan.r $output_dir/$sample.net.Rout
