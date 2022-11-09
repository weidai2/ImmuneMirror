# ImmuneMirror: Integrative Multi-Omics Data Analysis Pipeline for Idetifying Key Features For Cancer

## Overview
The ImmuneMirror, a multi-omics data analysis bioinformatics pipeline for identifying the key genomic and transcriptomic features associated with response of cancer immunotherapy. We developed the ImmuneMirror as a Docker (http://www.docker.com) container image, a platform-independent tool that can be run on any Docker supported machines including Linux, Mac, and Windows OS platforms. The analysis pipeline incorporates the benchmark tools for identifying the germline and somatic mutations, evaluation of microsatellite instability (MSI), HLA typing, and neoantigen prediction for HLA Class I and II based on the whole-exome sequencing (WES) and RNA-Seq data.

## Abstract

## System Requirements

    * Docker version: Platform of your choice.
    - Bash version: Linux, we run this pipeline under Ubuntu 20.04 LTS.
    - Hardware:
        Minimum: 8-core processor, 32 GB RAM
    - Disk space:
        Reference files: 328 GB
        Results: 
       

## How to use:

1. Download and install [Docker](https://www.docker.com/products/docker-desktop)

2. Download the Docker image from this link:
   [http://immunemirror.hku.hk](http://immunemirror.hku.hk)
   
   Now, you need to load the docker image to your docker environment (local machine) by executing the following command:
   ```
   docker load < immunemirror-1.0.tar
   ```
3. Download and unzip the pipeline's repository from Github:
  
  #### Way 1: 
  Copy [im_install.sh](https://github.com/weidai2/ImmuneMirror/blob/master/im_install.sh) to your local computer and set you working directory's path inside the im_install.sh script by editing the following line:
  ```
  working_directory=/Porvide/PATH/TO/YOUR_WORKING_DIRECTORY 
  ```
  Now, run the script below (im_install.sh):
  
  ```
  chmod +x im_install.sh\ 
  && ./im_install.sh
  ```
  
  #### Way 2:
  You may directly clone the master repository from the [GitHub](https://github.com/weidai2/ImmuneMirror/), unzip it and rename as ImmuneMirror
  
  Now your working environment is ready!

4. Download the reference files and example samples from the link below, and unzip them:
   [http://immunemirror.hku.hk](http://immunemirror.hku.hk)
   
5. Test the pipeline using example samples. It will take approximately 24 hours, Depending on the available CPU and RAM.

   You need to map the local directories to the Docker container as follows:
   ```
   WES_directory=/PATH/TO/YOUR/WES_Seq_DIRECTORY
   RNASeq_directory=/PATH/TO/YOUR/RNASeq_DIRECTOR
   Reference_files_directory=/PATH/TO/Reference_file_directory
   ```
   Now, run the commands below to process the example samples:
   ```
   sudo docker run \
    -v {your_working_directory}/ImmuneMirror/:/var/pipeline/ \
    -v {WES_directory}:/var/pipeline/WES \
    -v {RNASeq_directory}:/var/pipeline/RNASeq \
    -v {Reference_files_directory}/:/var/pipeline/Ref/ \
     immunemirror:1.0
     ```
6. Now run the pipeline using "real-life" samples.
    
   Firstly, you need to edit the {working_directory}/ImmuneMirror/sample.list file by replacing with your own sample list.
   Inside the 'sample.list' file, "YES" indicates the sample has both WES and RANSeq files, and "NO" indicates the sample has only WES sequecing data file.
   
   Now, run the following commnads to process you samples:
   
   ```
    sudo docker run \
    -v {your_working_directory}/ImmuneMirror/:/var/pipeline/ \
    -v {WES_directory}:/var/pipeline/WES \
    -v {RNASeq_directory}:/var/pipeline/RNASeq \
    -v {Reference_files_directory}/:/var/pipeline/Ref/ \
     immunemirror:1.0
   ```
# Pipeline Outputs
 Output directories descriptions: [download link](http://immunemirror.hku.hk/doc/outputs.pdf)

# Bug reports
Please send comments and bug reports to: sarwar2@hku.hk

# Citation
Please cite 

# License
The program is distributed under the GPL-3.0 license.
