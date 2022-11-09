
work_dir=$1
data_dir=$2
thread=$3
sample=$4
ID=$5

star_dir=/opt/STAR-2.7.5c

 #STAR --runMode genomeGenerate \
  #--genomeDir /disk3/database/gencode/v27 \
  #--genomeFastaFiles /disk3/database/gencode/v27/GRCh38.p10.genome.fa \
  #--sjdbOverhang 100 \
  #--sjdbGTFfile /disk3/database/gencode/v27/gencode.v27.annotation.gtf \
  #--runThreadN 8
 
  gencode_dir=/var/pipeline/Ref/v27
  
  mkdir -p $work_dir/star
  mkdir -p $work_dir/star/${ID}
  mkdir -p $work_dir/star/${ID}/pass1

  cd $work_dir/star/${ID}/pass1

  processDay=`date +%Y%m%d`

  currentTime=`date`
	echo [$currentTime]\\tStart data alignment

$star_dir/STAR --genomeDir $gencode_dir \
--readFilesIn $data_dir/${sample}_R1.fq.gz $data_dir/${sample}_R2.fq.gz \
--runThreadN $thread \
--outFilterMultimapScoreRange 1 \
--outFilterMultimapNmax 20 \
--outFilterMismatchNmax 10 \
--alignIntronMax 500000 \
--alignMatesGapMax 1000000 \
--sjdbScore 2 \
--alignSJDBoverhangMin 1 \
--genomeLoad NoSharedMemory \
--limitBAMsortRAM 77000000000 \
--readFilesCommand zcat \
--outFilterMatchNminOverLread 0.33 \
--outFilterScoreMinOverLread 0.33 \
--sjdbOverhang 100 \
--outSAMstrandField intronMotif \
--outSAMattributes NH HI NM MD AS XS \
--sjdbGTFfile $gencode_dir/gencode.v27.annotation.gtf \
--limitSjdbInsertNsj 2000000 \
--outSAMunmapped None \
--outSAMtype BAM SortedByCoordinate \
--outSAMheaderHD @HD VN:1.4 \
--outSAMattrRGline "ID:${ID}  PL:Illumina  PU:$ID_$processDay  SM:${ID}" \
--twopassMode Basic \
--outSAMmultNmax 1

currentTime=`date`
echo [$currentTime]\\Alignment by STAR for your RNA_Seq sample $ID is done!
