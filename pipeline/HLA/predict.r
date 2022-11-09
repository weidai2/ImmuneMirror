args=(commandArgs(TRUE))
for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
    }
cat(sample,'\n')
cat(input,'\n')
cat(output,'\n')

library(dplyr)
library(pROC)
library(caret)
library(randomForest)
library(data.table)
library(magrittr)
library(stringr)

in.data<-read.table(paste(input,"/",sample,".features.netctlpan.tsv",sep=""), header = TRUE, sep="\t")

pred.neo <- function(file.name){
  pep <- read.table("/var/pipeline/Ref/ML/final_all.tsv",sep="\t",header = T) %>% 
    as.data.frame() %>% 
    .[,-c(5,17)]
  set.seed(80)
  ctrl <- trainControl(method = "cv",classProbs = TRUE,
                       summaryFunction = twoClassSummary)
  training <- pep[,-c(1,2,4,6:12)]
  training$T_cell <- ifelse(training$T_cell==0,'No','Yes') %>% 
    as.factor()
  rfDownsampled <- train(T_cell~., data = training,
                         method = "rf",
                         ntree = 95,
                         tuneLength = 5,
                         metric = "ROC",
                         trControl = ctrl,
                         strata = pep$T_cell,
                         sampsize = rep(80, 2))
  test <- read.table(file.name,sep="\t",header = T) %>% 
    as.data.frame() %>% 
    .[,c("mhc_prediction"
    ,"tap_prediction_score"
    ,"cleavage_prediction_score"
    ,"combined_prediction_score"
    ,"X._rank"
    ,"AGRETOPICITY"
    , "FOREIGNNESS.dissimilarity"
    ,"HYDROPHOBICITY"
    ,"Median.MT.Score"
    ,"cterm_7mer_gravy_score"
    ,"Predicted.Stability"
    ,"Half.Life"
    ,"Stability.Rank")]
    
  res <- predict(rfDownsampled,test, type = "prob")
  return(res)
}

if(nrow(in.data)>0){
# calling function..........

rst<- pred.neo(paste(input,"/",sample,".features.netctlpan.tsv",sep=""))

#in.data<-read.table(paste(input,"/",sample,".features.netctlpan.tsv",sep=""), header = TRUE, sep="\t")

data2<-cbind(in.data[as.numeric(rownames(rst)),],rst)

data2$index<-1:nrow(rst)
write.table(data2, paste(output,"/",sample,".features.netctlpan.predict.tsv",sep=""),sep="\t",row.names=F)
}
if(nrow(in.data)==0){
data2="no good candidate"
writeLines(data2, paste(output,"/",sample,".features.netctlpan.predict.empty.tsv",sep=""))
}
# ========================================================================================  