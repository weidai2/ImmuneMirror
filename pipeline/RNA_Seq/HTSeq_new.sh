  
  work_dir=$1
  input=$2 ## BAM files 
  thread=$3
  ID=$4
  strand=$5
  #export PYTHONPATH=/root/anaconda3/bin/python
  export PATH=/root/anaconda3/bin/:/root/anaconda3/lib/python3.7/site-packages:$PATH
  python --version
  echo $PATH
  which python


  mkdir -p $work_dir/HTSeq
  mkdir -p $work_dir/HTSeq/$ID
  
  output=$work_dir/HTSeq/$ID

  #htseq_path=/usr/local/bin
  
  htseq_path=/root/anaconda3/bin
 
  
  refPre=/var/pipeline/Ref/v27/gencode.v27.annotation.gtf
  
  processDay=`date +%Y%m%d`

  currentTime=`date`
	echo [$currentTime]\\tStart data alignment

 if [ $strand == 0 ]
  then
  echo "unstranded method\n"
  samtools view -F 4 $input/Aligned.sortedByCoord.out.bam|$htseq_path/htseq-count \
  -m intersection-nonempty \
  -i gene_id \
  --additional-attr gene_name \
  -r pos \
  -s no \
  - $refPre > $output/${ID}.count.txt
fi

  if [ $strand == 1 ]
    then 
  echo "reverse strand method\n"
  samtools view -F 4 $input/Aligned.sortedByCoord.out.bam|$htseq_path/htseq-count \
  -m intersection-nonempty \
  -i gene_id \
  --additional-attr gene_name \
  -r pos \
  -s reverse \
  - $refPre > $output/${ID}.count.txt
fi

  if [ $strand == 2 ]
    then
  echo "forward strand method\n"
  samtools view -F 4 $input/Aligned.sortedByCoord.out.bam -|$htseq_path/htseq-count \
  -m intersection-nonempty \
  -i gene_id \
  --additional-attr gene_name \
  -r pos \
  -s yes \
  - $refPre > $output/${ID}.count.txt
fi
