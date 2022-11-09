args=(commandArgs(TRUE))
for(i in 1:length(args)){
	    eval(parse(text=args[[i]]))
	        }
	cat(sample,'\n')
	cat(infile,'\n')
	cat(outfile,'\n')
	setwd(outfile)
data<-read.table(infile,sep='\t',header=T)	
data<-data[!is.na(data[,2]),]
out.all<-NULL
for(i in 1:nrow(data)){
		line1<-paste(data[i,2],"-",i,sep="")
	        output<-paste(line1,".fasta",sep="")
		line2<-paste(">",line1,sep="")
		writeLines(line2,output)
		write(as.character(data[i,2]),output,append=T)
		l<-nchar(as.character(data[i,2]))
		output2<-paste(line1,".result",sep="")
		myline=paste("python /opt/NetChop/3.0/netchop/predict.py --method netctlpan --length",l,output,"|sed 1d|sed 1d|head -n1>",output2,sep=" ")

		system(myline)
	  	input<-read.table(output2,sep='\t',header=F)
	        colnames(input)<-c("index","peptide","mhc_prediction","tap_prediction_score","cleavage_prediction_score","combined_prediction_score","%_rank")
	        out.all<-rbind(out.all,input)
	}
	
	result<-cbind(out.all,data)
	result.out<-result[!is.na(result[,"AGRETOPICITY"]),]
	result.filter<-result[is.na(result[,"AGRETOPICITY"]),]
	#write.table(cbind(out.all,data),"features.netctlpan.tmp.tsv",sep='\t',row.names=F)
	write.table(result.out,"features.netctlpan.tmp.tsv",sep='\t',row.names=F)
	write.table(result.filter,"features.reject.tsv",sep='\t',row.names=F)
	myfile=paste("sed 's/\"//g' features.netctlpan.tmp.tsv >",sample,".features.netctlpan.tsv",sep="")
	system(myfile)
	system("rm features.netctlpan.tmp.tsv")

