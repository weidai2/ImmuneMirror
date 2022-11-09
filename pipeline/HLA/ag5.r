args=(commandArgs(TRUE))
for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
    }
cat(sample,'\n')
cat(input,'\n')
cat(output,'\n')

library(magrittr)
library(data.table)
library(antigen.garnish)
library(stringr)

data<-read.table(input,sep='\t',header=T)
aa<-as.character(data[,19])
agretopicity<-round(as.numeric(data[,36])/as.numeric(data[,37]),2)

hydrophobicity<-round((str_count(aa,"V")+str_count(aa,"I")+str_count(aa,"L")+str_count(aa,"M")+str_count(aa,"W")+str_count(aa,"C"))/nchar(aa),2)

# calculate foreignness score
#foreigness<-foreignness_score(aa,db = "human")
#cat(foreigness,'\n')
# calculate dissimilarity
for (i in 1:10){
dis_score<-dissimilarity_score(aa, db = "human")
j<-ncol(dis_score)
  if (j==2)
    break
}
aa2<-unlist(dis_score[,1])


for_score=foreignness_score(aa,db = "human")
aa3<-unlist(for_score[,1])

write.table(data.frame(AGRETOPICITY=agretopicity,FOREIGNNESS=dis_score[match(aa,aa2),],HYDROPHOBICITY=hydrophobicity,data,foreign_score=for_score[match(aa,aa3),c(1:2)]),paste(output,"/",sample,".dissimilarity.tsv",sep=""),sep='\t',row.names=F)

