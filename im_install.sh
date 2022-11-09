  #!/bin/bash
  
  # Create the working directory
  
  working_directory=/PATH/TO/YOUR_WORKING_DIRECTORY # you need to provide the location of your working directory 
  mkdir -p ${working_directory}
  
  # Download and unzip the pipeline's repository from Github:
  cd ${working_directory}
  wget https://github.com/weidai2/ImmuneMirror/archive/master.zip
  unzip master.zip
  rm master.zip
  mv ImmuneMirror-master ${working_directory}/ImmuneMirror
