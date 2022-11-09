
library(pracma)

args=(commandArgs(TRUE))
for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
    }
    
cat(input,'\n')
cat(output,'\n')

f1<-read.table("/var/pipeline/pipeline/MHC_I_colnames.txt", header=T, sep ='\t')
f1nlist<-colnames(f1)
tcol<-length(f1nlist)

f2<-read.table(input, header=T, sep ='\t')
f2nlist<-colnames(f2)

  #print("not same order!")
  matched_index<-match(f1nlist,f2nlist)
  sub_data<-subset(matched_index, !is.na(matched_index))
  new_f2<-f2[sub_data]
  f2nlist<-colnames(new_f2)
  tcol2<-length(f2nlist)
  
f2e<-new_f2

for (pos.col in 1:tcol)
  {
  if(is.na(f2nlist[pos.col])){
    print(f1nlist[pos.col])
    f2e<-as.data.frame(append(f2e, list(C = NA), after = pos.col-1))
    colnames(f2e)[pos.col] <-f1nlist[pos.col]
  }
  else if(!strcmp(f1nlist[pos.col],f2nlist[pos.col])){
   #print(f1nlist[pos.col])
    f2e<-as.data.frame(append(f2e, list(C = NA), after = pos.col-1))
    colnames(f2e)[pos.col] <-f1nlist[pos.col]
  }
f2nlist<-colnames(f2e)
tcol2<-length(f2nlist)
  if (tcol==tcol2)
    break
}

write.table(f2e, paste(output,"/","sample.tsv", sep=""), row.names=F, sep = "\t")