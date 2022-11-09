sample=$1
hlas=$2
input=$3
output=$4
thread=$5

#export TMPDIR=/var/tmp
export TMPDIR=/var/pipeline/results/tmp

export PATH=/root/anaconda3/bin/:/root/anaconda3/lib/python3.7/site-packages:$PATH
  python --version
  echo $PATH
  which python

pvacseq run \
	$input/input.tx.vcf \
	$sample \
	$hlas \
	all \
	$output \
	-t $thread \
	-e1 8,9,10,11 \
	-e2 15,16,17 \
	--iedb-install-directory /opt/IEDB-3 \
	--netmhc-stab
