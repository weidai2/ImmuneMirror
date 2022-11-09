
work_dir=$1
data_dir=$2
thread=$3
sample=$4
ID=$5



salmon=/opt/salmon-latest_linux_x86_64/bin/salmon

ref_dir=/var/pipeline/Ref/v27

mkdir -p $work_dir/salmon

output=$work_dir/salmon
mkdir -p $output/${ID}

## cd $work_dir/RNA_Seq/salmon/{$sample}

#$salmon index -t $ref_dir/gencode.v27.transcripts.fa -i $ref_dir/gencode.v27.transcripts_index --type quasi -k 31

## $salmon index -t $ref_dir/gencode.v27.transcripts.fa -i $ref_dir/gencode.v27.transcripts_index_salmon quasi -k 31

$salmon quant -i $ref_dir/gencode.v27.transcripts_index_salmon --libType A -o $output/$ID -1 $data_dir/${sample}_R1.fq.gz -2 $data_dir/${sample}_R2.fq.gz -p $thread

cd $output/$ID
exp=quant.sf
less -S $exp|awk '{print substr($1,1,17)}' >id
cut -f4 $exp >tmp
paste id tmp >quant.id.sf
rm tmp id
