sample=$1
work_dir=$2
data_dir=$3
output=$4
sample_type=$5

 razers3=/opt/razers3
 opt_dir=/usr/local/bin/OptiType/OptiTypePipeline.py
 
 export PATH=/root/anaconda3/bin/:/root/anaconda3/lib/python3.7/site-packages:$PATH
  python --version
  echo $PATH
  which python

mkdir -p $output/${sample}
out=$output/${sample}

if [ $sample_type -eq 1 ]
then
	hla_refPre=/var/pipeline/Ref/hla_reference_dna.fasta
	echo "sample type is DNA\n"
	$razers3 -i 95 -m 1 -dr 0 -o $out/${sample}_fished_1.bam $hla_refPre $data_dir/${sample}_R1.fq.gz
	$razers3 -i 95 -m 1 -dr 0 -o $out/${sample}_fished_2.bam $hla_refPre $data_dir/${sample}_R2.fq.gz
	samtools bam2fq $out/${sample}_fished_1.bam > $out/${sample}_fished_1.fastq
	samtools bam2fq $out/${sample}_fished_2.bam > $out/${sample}_fished_2.fastq
	python $opt_dir -i $out/${sample}_fished_1.fastq $out/${sample}_fished_2.fastq --dna -o $out -p ${sample} --config /var/pipeline/pipeline/HLA/config.ini.example
fi
if [ $sample_type -eq 2 ]
then

	hla_refPre=/var/pipeline/Ref/hla_reference_rna.fasta
	echo "sample type is RNA\n"

	$razers3 -i 95 -m 1 -dr 0 -o $out/${sample}_fished_1.bam $hla_refPre $data_dir/${sample}_R1.fq.gz
	$razers3 -i 95 -m 1 -dr 0 -o $out/${sample}_fished_2.bam $hla_refPre $data_dir/${sample}_R2.fq.gz
	samtools bam2fq $out/${sample}_fished_1.bam > $out/${sample}_fished_1.fastq
	samtools bam2fq $out/${sample}_fished_2.bam > $out/${sample}_fished_2.fastq
	python $opt_dir -i $out/${sample}_fished_1.fastq $out/${sample}_fished_2.fastq --rna -o $out -p ${sample} --config /var/pipeline/pipeline/HLA/config.ini.example

fi
