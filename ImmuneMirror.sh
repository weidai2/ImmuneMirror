#!/bin/bash

 disease_type=$1
 thread=$2

printf "ImmuneMirror (version 1.0),\n Developed by Dr. Wei's Research Team\n Department of Clinical Oncology,\n The University of Hong Kong.\n"

StartTime=`date`
printf "Job Start Time: $StartTime\n"
printf "Your job is running....... please wait for the results!\n"

mkdir -p /var/pipeline/results
mkdir -p /var/pipeline/results/tmp
mkdir -p /var/pipeline/results/logs

processDay=`date +%Y%m%d`
bash /var/pipeline/pipeline/ImR_job.sh $disease_type $thread 1>/var/pipeline/results/logs/submit_${processDay}.log 2>&1

printf "Your job has been finished!\n"
printf "Browse the results located in {your working directory}/results/ \n"

EndTime=`date`
printf "Job Completion Time: $EndTime\n"
