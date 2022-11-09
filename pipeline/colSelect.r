
library(pracma)

args=(commandArgs(TRUE))
for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
    }
    
cat(input,'\n')
cat(output,'\n')

reslt2 <-read.table(paste(input,"/tmp.tsv", sep=""), 
              sep="\t", header = TRUE)

colnames(reslt2)[73]<- "ID" # change column name to ID
colnames(reslt2)[101]<- "Prediction_score" # change column name to Prediction_score

reslt3 <- reslt2[,c(1:9,
                11:24,
                27:35,
                40:41,
                47:49,
                73,
                86:92,
                94:97,
                99,
                101
                )]
                
write.table(reslt3, paste(output,"/","sample2.tsv", sep=""), row.names=F, sep = "\t")
