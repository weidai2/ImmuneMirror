library(pheatmap)
library(DESeq2)
library(ggplot2)
library(gridExtra)
library(RColorBrewer)
library(ggpubr)
#library(tidyverse)
library(dplyr)
library(circlize)
library(ComplexHeatmap)
library(png)
library(grid)
library("ggplotify")
library(pracma)
library(gplots)

require(data.table)

args=(commandArgs(TRUE))
for(i in 1:length(args)){
  eval(parse(text=args[[i]]))
}   

cat(normal,'\n')
cat(tumor,'\n')
cat(mload,'\n')
cat(hla_I,'\n')
cat(hla_II,'\n')
cat(nclassI,'\n')
cat(nclassII,'\n')
cat(msi,'\n')
cat(output,'\n')
cat(in_somatic,'\n')
cat(in_rna,'\n')
cat(in_anno,'\n')
cat(d_type,'\n')

setwd(output)

print("normal:")
print(normal)
print("\ntumor:")
print(tumor)
print("\nmload:")
print(mload)
print("\nhla_I:")
print(hla_I)
print("\nhla_II:")
print(hla_II)
print("\n nclassI:")
print(nclassI)
print("\n nclassII:")
print(nclassII)
print("\n MSI:")
print(msi)
print("\noutput:")
print(output)
print("\nSomatic:")
print(in_somatic)
print("\nRNA:")
print(in_rna)
print("\nAnno:")
print(in_anno)
print("\nDisease type:")
print(d_type)

sample_name=tumor # "input_sample", 

# null results' figure

no_fig <- as.ggplot(rasterGrob(readPNG("/var/pipeline/Ref/IM_DB/No.png",
                                       native = FALSE),
                               interpolate = FALSE))


# =================================================================================== common input data
if(d_type!='No')
{
  crc.info <- read.csv(paste("/var/pipeline/Ref/IM_DB/",d_type,"_Info.csv", sep=""),
                       header=T)
  #dim(crc.info)
  
  #View(crc.info)
  
  # --------------------------- load Neoantigen list
  crc.neo <- read.table(paste("/var/pipeline/Ref/IM_DB/",d_type,"_Neo.txt", sep=""),
                        sep="\t",
                        header=TRUE)
  
  #crc.neo$Yes <- round(crc.neo$Yes,1)# round up
  
  
  crc.info2 <- crc.info[order(crc.info$Mutation_load,
                              decreasing = TRUE),]
}

par("mar")
par(mar=c(1,1,1,1))

# ======================= plot- mutation load =======================================================================================
if(d_type=='No')
{
  
  Mut_load1 <- no_fig +
    theme(plot.title=element_text(size =8 ,
                                  face="bold"))
  
} else if(mload=='N'){
  
  Mut_load1 <- no_fig +
    theme(plot.title=element_text(size =8 ,
                                  face="bold"))
  
} else {
  
  crc.info2['Mutation_load']<- round(crc.info2$Mutation_load/66.63)
  
  min_mu= min(crc.info2$Mutation_load)
  max_mu= max(crc.info2$Mutation_load)
  sam_mu=round(as.numeric(mload)/66.63)
  
  Mut_load1 <- ggplot(crc.info2,aes(x=1:nrow(crc.info2),
                                    y=Mutation_load))+
    geom_point(size=1.5,color="blue") +
    #scale_y_continuous(breaks = seq(min_mu, max_mu, by=30), 
    #       limits=c(min_mu,max_mu)) +
    theme_classic()+
    theme(axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title = element_text(size = 7),
          plot.title = element_text(size = 8, face="bold"))+
    xlab("Hypermutation") +
    ylab("Number of Mutation per Mb")+
    geom_point(data=crc.info,
               size=3, aes(x=1,
                           y=sam_mu),
               color="purple") 
}


Mut_load <- Mut_load1 + 
  geom_hline(yintercept=10, linetype="dashed", 
             color="red", size=0.5)+
  labs(title="A. Mutation Load")

# ===================================================  plot - HLA typing 

if(hla_I=='N')
{
  hla.I.p <- no_fig
  
} else {
  hla.I <- hla_I 
  #View(hla.I[1]) 
  hla.I.2 <- unlist(strsplit(as.character(hla.I), ","))
  hla.I.2<- data.frame(hla.I.2)
  #View(hla.I.2)
  colnames(hla.I.2)<- 'HLA Type I'
  
  hla.I.p <- ggtexttable(hla.I.2, rows = NULL, 
                         cols = colnames(hla.I.2),
                         theme = ttheme(base_size = 6,
                                        base_style= "mBlue",
                                        padding = unit(c(3, 1.5), "mm")))
  #hla.I.p
  
  
} # end hla I type


# === hla II type

if(hla_II=='N')
{
  
  hla.II.p <- no_fig
  
} else {
  
  hla.II <- hla_II
  #View(hla.II[1]) 
  hla.II.2 <- unlist(strsplit(as.character(hla.II), ","))
  hla.II.2 <- data.frame(hla.II.2)
  #View(hla.II.2)
  colnames(hla.II.2)<- 'HLA Type II'
  
  hla.II.p <- ggtexttable(hla.II.2,rows = NULL, 
                          cols = colnames(hla.II.2),
                          theme = ttheme(base_size = 6,
                                         base_style= "mBlue",
                                         padding = unit(c(3, 1.5), "mm")))
  #hla.II.p
  
} # end hla II typing


hla.types.p <- ggpubr::ggarrange(
  hla.I.p,
  hla.II.p,
  ncol=3,
  nrow=1)

hla.types.p2 <- as.ggplot(hla.types.p)+
  labs(title = "B. HLA types")+
  theme(plot.title = element_text(size=8,
                                  face="bold"))



# ================================================ neoantigen box and bar plots

if(d_type=='No')
{
  
  neo.I.raw.all <- no_fig +
    labs(title="C. Tumor neoantigen load for class I (without filtering)")+
    theme(plot.title=element_text(size =8 ,
                                  face="bold"))
  
  neo.I.filtered.all <- no_fig +
    labs(title="D. Tumor neoantigen load for class I (filtered)")+
    theme(plot.title=element_text(size =8 ,
                                  face="bold"))
  
  # =============== MI score 
  
  MI.score.plot <- no_fig +
    labs(title="I. ImmuneMirror prediction score")+
    theme(plot.title=element_text(size =8 ,
                                  face="bold"))
  
  
} else if(nclassI=='N')
{
  
  neo.I.raw.all <- no_fig +
    labs(title="C. Tumor neoantigen load for class I (without filtering)")+
    theme(plot.title=element_text(size =8 ,
                                  face="bold"))
  
  neo.I.filtered.all <- no_fig +
    labs(title="D. Tumor neoantigen load for class I (filtered)")+
    theme(plot.title=element_text(size =8 ,
                                  face="bold"))
  
  # ====================================================================================  MI score 
  
  MI.score.plot <- no_fig +
    labs(title="I. ImmuneMirror prediction score")+
    theme(plot.title=element_text(size =8 ,
                                  face="bold"))
  
  
} else {
  
  neo_I.data <- read.table(nclassI,header=T, sep ='\t')
  neo_I.data2 <- neo_I.data # input for IM score box plot, without rounding score.
  
  in.neo.I <- nrow(neo_I.data)
  
  print("\nin.neo.I:")
  print(in.neo.I)
  
  neo_I.data$Yes <- round(neo_I.data$Yes,1) # round up
  
  sub.neo_I.data <- dplyr::filter(neo_I.data,
                                  Yes>=0.5)
  
  in.neo.I.filter<- nrow(sub.neo_I.data)
  print("\nin.neo.I.filter:")
  print(in.neo.I.filter)
  
  neo.I.raw.p <- ggplot(crc.info2,aes(
    y=Neoantigen_load_ClassI
  )) + xlim(-0.5, 0.5) +
    geom_boxplot(fill="orange", outlier.colour="grey",
                 outlier.shape=19,
                 outlier.size=1)+
    geom_point(data = crc.info2, 
               aes(y=in.neo.I,
                   x = 0),
               color="purple", size=2, pch=19)+ 
    coord_flip()
  
  
  neo.I.raw.p <- neo.I.raw.p + theme(axis.title.x=element_blank(),
                                     axis.title.y=element_blank(),
                                     axis.text.y=element_blank(),
                                     axis.ticks.y=element_blank(),
                                     panel.background = element_blank(),
                                     panel.border = element_rect(colour = "black", 
                                                                 fill=NA, 
                                                                 size=0.25,
                                     ),
                                     plot.title = element_text(size=8, face="bold")
  )+ labs(title="C. Tumor neoantigen load for class I (without filtering)")
  
  
  
  png("neo.I.raw.bar.png", res=200,
      height = 500,
      width= 1000)
  
  
  Neo.I.raw.sample_val=in.neo.I
  
  Neo.I.raw_min_val=0# it was zero 
  #Neo.I.raw_cut_off=75 # fixed value
  Neo.I.raw_max_val= max(crc.info2$Neoantigen_load_ClassI)# 583
  
  if(Neo.I.raw.sample_val>Neo.I.raw_max_val)
    Neo.I.raw.sample_val=Neo.I.raw_max_val
  
  col_fun = colorRamp2(breaks=c(Neo.I.raw_min_val,
                                Neo.I.raw_max_val), 
                       colors=c("blue","red"),
                       transparency=0)
  
  lgd = Legend(col_fun = col_fun,
               legend_height = unit(6, "cm"),
               at = c(Neo.I.raw_min_val,
                      Neo.I.raw.sample_val,
                      Neo.I.raw_max_val
               ), 
               
               labels = c("Low", 
                          sample_name,
                          "High"),
               
               direction = "horizontal",
               labels_rot = 45,
               border = 1,
               title_gp = gpar(fontsize =8, 
                               fontface = "bold"),
               title_gap = unit(3, "mm"))
  draw(lgd)
  dev.off()
  
  neo.I.raw.bar.p <- rasterGrob(readPNG("neo.I.raw.bar.png",
                                        native = FALSE),
                                interpolate = FALSE)
  
  
  #----------------------------------------------------------- Neoantigen class I filtered
  neo.I.filtered.p <- ggplot(crc.info2,aes(
    y= Neoantigen_load_ClassI_filtered
  )) + xlim(-0.5, 0.5) +
    geom_boxplot(fill="orange", outlier.colour="grey",
                 outlier.shape=19,
                 outlier.size=1)+
    geom_point(data = crc.info2, 
               aes(y=in.neo.I.filter, 
                   x = 0),
               color="purple", size=2, pch=19)+ 
    coord_flip()
  neo.I.filtered.p<- neo.I.filtered.p + theme(axis.title.x=element_blank(),
                                              axis.title.y=element_blank(),
                                              axis.text.y=element_blank(),
                                              axis.ticks.y=element_blank(),
                                              panel.background = element_blank(),
                                              panel.border = element_rect(colour = "black", 
                                                                          fill=NA, 
                                                                          size=0.25,
                                              ),
                                              plot.title = element_text(size=8, 
                                                                        face="bold")
  )  + labs(title="D. Tumor neoantigen load for class I (filtered)")
  
  #neo.I.filtered.p
  
  png("neo.I.filtered.bar.png", 
      res=200,
      height = 500,
      width= 1000)    
  
  
  Neo.I.filtered.sample_val=in.neo.I.filter 
  Neo.I.filtered_min_val=0# it was zero 
  #Neo.I.filtered_cut_off=75 # fixed value
  Neo.I.filtered_max_val= max(crc.info2$Neoantigen_load_ClassI_filtered)# 170
  
  if(Neo.I.filtered.sample_val>Neo.I.filtered_max_val)
    Neo.I.filtered.sample_val=Neo.I.filtered_max_val
  
  col_fun = colorRamp2(breaks=c(Neo.I.filtered_min_val,
                                Neo.I.filtered_max_val), 
                       colors=c("blue","red"),
                       transparency=0)
  rm(lgd)
  gc()
  lgd = Legend(col_fun = col_fun,
               legend_height = unit(6, "cm"),
               at = c(Neo.I.filtered_min_val,
                      Neo.I.filtered.sample_val,
                      Neo.I.filtered_max_val
               ), 
               
               labels = c("Low", 
                          sample_name,
                          "High"),
               
               direction = "horizontal",
               labels_rot = 45,
               border = 1,
               title_gp = gpar(fontsize =8, 
                               fontface = "bold"),
               title_gap = unit(3, "mm"))
  draw(lgd)
  dev.off()
  neo.I.raw.filtered.bar.p <- rasterGrob(readPNG("neo.I.filtered.bar.png",
                                                 native = FALSE),
                                         interpolate = FALSE)
  
  neo.I.raw.all <- ggpubr::ggarrange(
    neo.I.raw.p,
    neo.I.raw.bar.p,
    ncol=2, nrow = 1)
  
  neo.I.filtered.all <- ggpubr::ggarrange(
    neo.I.filtered.p,
    neo.I.raw.filtered.bar.p,
    nrow=1,
    ncol=2)
  
  
  # =================================================================================== MI score 
  
  MI.score.plot <- ggplot(crc.neo,aes(y=Yes)) + xlim(-0.5, 0.5) +
    geom_boxplot(fill="orange", outlier.colour="grey",
                 outlier.shape=19,
                 outlier.size=1)+
    geom_point(data = neo_I.data2,
               aes(y=Yes,
                   x=0),
               color="purple", size=2, pch=19) + 
    scale_y_continuous(breaks =seq(0, 1, .1), limit = c(0, 1)) +
    coord_flip()
  
  
  
  MI.score.plot  <- MI.score.plot  + theme(axis.title.x=element_blank(),
                                           axis.title.y=element_blank(),
                                           axis.text.y=element_blank(),
                                           axis.ticks.y=element_blank(),
                                           panel.background = element_blank(),
                                           panel.border = element_rect(colour = "black", 
                                                                       fill=NA, 
                                                                       size=0.25,
                                           ),
                                           plot.title = element_text(size=8, face="bold")
  )+ labs(title="I. ImmuneMirror prediction score")
  
  
  
} # ======== neo_I end


#===================================================================== Neoantigen Class II (without filtered)
if(d_type=='No')
{
  
  neo.II.raw.all <- no_fig +
    labs(title="E. Tumor neoantigen load for class II (without filtering)")+
    theme(plot.title=element_text(size =8 ,
                                  face="bold"))
  
} else if(nclassII=='N') {
  
  neo.II.raw.all <- no_fig +
    labs(title="E. Tumor neoantigen load for class II (without filtering)")+
    theme(plot.title=element_text(size =8 ,
                                  face="bold"))
  
} else {
  
  neo_II.data<- read.table(nclassII,header=T, sep ='\t')
  in.neo.II<- nrow(neo_II.data)
  print("\nin.neo.II:")
  print(in.neo.II)
  
  
  neo.II.raw.p <- ggplot(crc.info2,aes(
    y=Neoantigen_load_ClassII
  )) + xlim(-0.5, 0.5) +
    geom_boxplot(fill="orange", outlier.colour="grey",
                 outlier.shape=19,
                 outlier.size=1)+
    geom_point(data = crc.info2, 
               aes(y=in.neo.II, 
                   x = 0),
               color="purple", size=2, pch=19)+ 
    coord_flip()
  neo.II.raw.p <- neo.II.raw.p + theme(axis.title.x=element_blank(),
                                       axis.title.y=element_blank(),
                                       axis.text.y=element_blank(),
                                       axis.ticks.y=element_blank(),
                                       panel.background = element_blank(),
                                       panel.border = element_rect(colour = "black", 
                                                                   fill=NA, 
                                                                   size=0.25,
                                       ),
                                       plot.title = element_text(size=8,
                                                                 face="bold")
  )+ labs(title="E. Tumor neoantigen load for class II (without filtering)")
  #neo.II.raw.p
  
  # -- Neoantigen Class II bar plot
  png("neo.II.raw.bar.png", res=200,
      height = 500,
      width= 1000)
  
  Neo.II.raw.sample_val=in.neo.II 
  #Neo.II.raw_min_val=min(crc.info2$Neoantigen_load_ClassII) # it was one 
  Neo.II.raw_min_val=0
  #Neo.II.raw_cut_off=75 # fixed value
  Neo.II.raw_max_val= max(crc.info2$Neoantigen_load_ClassII)# 9,430
  
  if(Neo.II.raw.sample_val>Neo.II.raw_max_val)
    Neo.II.raw.sample_val=Neo.II.raw_max_val
  
  col_fun = colorRamp2(breaks=c(Neo.II.raw_min_val,
                                Neo.II.raw_max_val), 
                       colors=c("blue","red"),
                       transparency=0)
  rm(lgd)
  lgd = Legend(col_fun = col_fun,
               legend_height = unit(6, "cm"),
               at = c(Neo.II.raw_min_val,
                      Neo.II.raw.sample_val,
                      Neo.II.raw_max_val
               ), 
               
               labels = c("Low", 
                          sample_name,
                          "High"),
               
               direction = "horizontal",
               labels_rot = 45,
               border = 1,
               title_gp = gpar(fontsize =8, 
                               fontface = "bold"),
               title_gap = unit(2, "mm"))
  draw(lgd)
  dev.off()
  neo.II.raw.bar.p <- rasterGrob(readPNG("neo.II.raw.bar.png",
                                         native = FALSE),
                                 interpolate = FALSE)
  
  neo.II.raw.all <- ggpubr::ggarrange(
    neo.II.raw.p,
    neo.II.raw.bar.p,
    nrow=1,
    ncol=2)
  
} # ============== neo II end



# ========================================================== MSI status
if(d_type=='No')
{
  
  MSI.plot <- no_fig
  
} else if(msi=='N'){
  
  MSI.plot <- no_fig
  
} else {
  
  msi.data<- read.table(msi,header=T, sep ='\t')
  in.msi<- nrow(msi.data)
  
  png("MMR_status_plot.png", res=200,
      height = 400,
      width= 1000)
  
  msi_sample_val=in.msi
  msi_min_val=0# it was zero 
  msi_cut_off= 450 # fixed value
  msi_max_val= max(crc.info2$MSI_status)# 9,430
  
  if(msi_sample_val>msi_max_val) {
    msi_sample_val=msi_max_val
  }
  
  
  col_fun = colorRamp2(breaks=c(msi_min_val,
                                msi_cut_off,
                                msi_max_val), 
                       colors=c("blue", "white","red"),
                       transparency=0)
  
  lgd = Legend(col_fun = col_fun,
               legend_height = unit(6, "cm"),
               at = c(msi_min_val,
                      msi_sample_val,
                      msi_cut_off,
                      msi_max_val), 
               
               labels = c("Proficiency", 
                          sample_name,
                          "cutoff",
                          "Deficiency"),
               
               direction = "horizontal",
               labels_rot = 45,
               border = 1,
               title_gp = gpar(fontsize = 12, 
                               fontface = "bold"),
               title_gap = unit(2, "mm"))
  draw(lgd)
  dev.off()
  
  MSI.plot <- rasterGrob(readPNG("MMR_status_plot.png",
                                 native = FALSE),
                         interpolate = FALSE)
  
} 

MSI.plot2 <- as.ggplot(MSI.plot)+ 
  labs(title="F. MMR status")+
  theme(plot.title=element_text(size =8 ,
                                face="bold"))

# ----- MSI end



# =============== Somatic mutation
if(in_somatic=='N')
{
  
  Somatic.p1 <- no_fig
  
} else {
  
  
  somatic.mutn<- read.delim(in_somatic,
                            comment.char = "#")
  
  sub.somatic.mutn<- somatic.mutn[,c('Hugo_Symbol',
                                     'cDNA_Change',
                                     'Protein_Change')]
  #View(sub.somatic.mutn)
  colnames(sub.somatic.mutn)<- c('Gene',
                                 'Mutation',
                                 'AA_change')
  
  Gene <- c('MLH1',
            'MLH3',
            'MSH2',
            'MSH6',
            'PMS2') 
  
  Mutation <- c('-', '-', '-', '-', '-')
  AA_change <- c('-', '-', '-', '-', '-')
  
  df.somatic <- data.frame(Gene, Mutation, AA_change)
  #print (df.somatic)
  rm(Gene)
  gc()
  
  sub1.df.somatic <- sub.somatic.mutn[!is.na(match(sub.somatic.mutn$Gene,
                                                   df.somatic$Gene)),]
  
  if(nrow(sub1.df.somatic)!=0)
  {
    sub1.df.somatic[sub1.df.somatic ==""]<- '-' # space replaced by '-'
    
    sub1.df.somatic <- dplyr::filter(sub1.df.somatic,
                                     AA_change!='-')
    #View(sub1.df.somatic)
    
    sub.df.somatic <- df.somatic %>%
      #Stay with the rows that are not found in sub.somatic.mutn
      dplyr::filter(!Gene %in% sub1.df.somatic$Gene)
    
    filtered.all.df.somamatic <- rbind(sub.df.somatic,
                                       sub1.df.somatic)
  } else {
    filtered.all.df.somamatic <- df.somatic 
  }
  #View(filtered.all.df.somamatic)
  
  Somatic.p1 <- as.ggplot(ggtexttable(filtered.all.df.somamatic, 
                                      rows = NULL, 
                                      cols = colnames(filtered.all.df.somamatic),
                                      theme = ttheme(base_size = 5,
                                                     base_style= "mBlue",
                                                     padding = unit(c(2, 1.5), "mm"))))
}

Somatic.p <- Somatic.p1  +
  labs(title="H. Somatic mutation")+
  theme(plot.title=element_text(size =8 ,
                                face="bold"))


#============================================== Germline mutation
if(in_anno=='N') {
  
  GermN.p1 <- no_fig
  
} else {
  
  germN.mutn.in<- read.delim(in_anno)
  
  filtered.germN.mutn<- dplyr::filter(germN.mutn.in,
                                      esp6500siv2_all<0.05 | is.na(esp6500siv2_all),
                                      X1000g2015aug_all<0.05 | is.na(X1000g2015aug_all),
                                      ExAC_ALL<0.05 | is.na(ExAC_ALL),
                                      SIFT_pred!='T',
                                      Polyphen2_HDIV_pred!='B',
                                      MutationTaster_pred!='N',
                                      MutationAssessor_pred!='N',
                                      CADD_phred>20 | is.na(CADD_phred)
  )
  
  dim(filtered.germN.mutn)
  #View(filtered.germN.mutn)
  library(tidyr)
  t.flt<- filtered.germN.mutn %>% 
    mutate(AAChange.refGene = strsplit(as.character(AAChange.refGene), ",")) %>%
    unnest(AAChange.refGene)
  #View(t.flt)
  t2.flt<- t.flt %>%
    separate(AAChange.refGene, 
             c("AAgene", "AAid","AAexon","AAc","AAp"), ":")
  
  #View(t2.flt)
  t2.flt['AAid']<- gsub("^.{0,3}", "",t2.flt$AAid)
  #View(t2.flt)
  t3.flt<- t2.flt[!is.na(t2.flt$AAid),]
  t3.flt['AAid']<- as.integer(t3.flt$AAid)
  #View(t3.flt)
  group.gene <- as.data.table(t3.flt)
  t4.flt<- group.gene[group.gene[, .I[which.min(AAid)], 
                                 by=Gene.refGene]$V1]
  #View(t4.flt)
  germN.mutn<- t4.flt
  #View(germN.mutn)
  sub.germN.mutn<- germN.mutn[,c('Gene.refGene',
                                 'AAc',
                                 'AAp',
                                 'CLINSIG')]
  
  sub.germN.mutn$CLINSIG <- ifelse(grepl("Likely Pathogenic",
                                         sub.germN.mutn$CLINSIG,
                                         ignore.case = FALSE,
                                         fixed=TRUE),
                                   "*",ifelse(grepl("Pathogenic",
                                                    sub.germN.mutn$CLINSIG,
                                                    ignore.case = FALSE,
                                                    fixed=TRUE),
                                              "**",'-'))
  #View(sub.germN.mutn)
  
  colnames(sub.germN.mutn)<- c('Gene',
                               'Mutation',
                               'AA_change',
                               'ClinVar')
  #View(sub.germN.mutn)
  
  rm(Gene, Mutation,AA_change,ClinVar)
  Gene <- c('BRCA2',
            'B2M',
            'JAK1',
            'JAK2',
            'PTEN',
            'AKT1',
            'EGFR') 
  
  Mutation <- c('-', '-', '-', '-', '-','-','-')
  AA_change <- c('-', '-', '-', '-', '-','-','-')
  ClinVar <- c('-', '-', '-', '-', '-','-','-')
  df.germN <- data.frame(Gene, Mutation, AA_change,ClinVar)
  
  rm(Gene,AA_change,ClinVar)
  gc()
  
  sub1.df.germN <- sub.germN.mutn[!is.na(match(sub.germN.mutn$Gene,
                                               df.germN$Gene)),]
  if(nrow(sub1.df.germN)!=0)
  {
    sub1.df.germN[sub1.df.germN ==""]<- '-' # space replaced by '-'
    
    sub1.df.germN<- dplyr::filter(sub1.df.germN,
                                  AA_change!='-')
    #View(sub1.df.germN)
    
    sub.df.germN<- df.germN %>%
      #Stay with the rows that are not found in sub.germN.mutn
      dplyr::filter(!Gene %in% sub1.df.germN$Gene) 
    #View(sub.df.germN)
    
    filtered.all.df.germN <- rbind(sub.df.germN,
                                   sub1.df.germN)
  } else {
    
    filtered.all.df.germN <- df.germN
  }
  
  GermN.p1 <- as.ggplot(ggtexttable(filtered.all.df.germN, 
                                    rows = NULL, 
                                    cols = colnames(filtered.all.df.germN),
                                    theme = ttheme(base_size = 5,
                                                   base_style= "mBlue",
                                                   padding = unit(c(2, 1.5), "mm"))))
} 

GermN.p <- GermN.p1  +
  labs(title="G. Germline mutation")+
  theme(plot.title=element_text(size =8 ,
                                face="bold"))


dev.off()
# ============================================================================== IPRES heatmap ============================
if(d_type=='No')
{
  
  gene_sign.p1 <- no_fig
  
} else if(in_rna=='N') {
  
  gene_sign.p1 <- no_fig
  
} else {
  
  Expr.Count<- read.csv(paste("/var/pipeline/Ref/IM_DB/",d_type,"_RNAexpr.csv",sep=""),
                        row.names = 1)
  
  
  #View(head(Expr.Count))
  #dim(Expr.Count)
  GeneList<- unique(readLines("/var/pipeline/Ref/IM_DB/IPRES_genes.txt"))
  #View(GeneList)
  sub.expr<-Expr.Count[GeneList,]
  #View(sub.expr)
  
  in.sample <- read.table(in_rna,
                          header = FALSE,
                          sep = '\t') # need to change
  
  colnames(in.sample)<- c("id","gene","exp")
  #View(in.sample)
  nr<-dim(in.sample)[1]
  sub.in.sample <- in.sample[1:(nr-5),]
  #View(sub.in.sample)
  sub.in.sample<-sub.in.sample[!duplicated(sub.in.sample$gene),]
  row.names(sub.in.sample)<-sub.in.sample$gene
  sub.in.sample<- sub.in.sample[GeneList,]
  #View(sub.in.sample)
  all.expr<-cbind(InSample=sub.in.sample$exp,sub.expr)
  colnames(all.expr)[1]<- sample_name
  #View(all.expr)
  
  all.expr<- as.matrix(all.expr)
  vst<-varianceStabilizingTransformation(all.expr,
                                         blind=FALSE)
  #dim(vst)
  #sum(duplicated(vst))
  vst<-vst[!duplicated(vst),]
  vst = vst[apply(vst, 1, function(x) sd(x)!=0),] 
  #View(head(vst))
  
  Annotation_col<- read.csv(paste("/var/pipeline/Ref/IM_DB/",d_type,"_Anno.csv", sep=""),
                            row.names = 1,
                            header = T)
  #View(Annotation_col)
  
  png("IPRES_Hmap.png",width = 2000,
      height = 1100)
  
  lab_list<- c(1:219)
  lab_list[1:219] <- ""
  lab_list[1]<- sample_name
  hmap.arrow <- pheatmap(vst
                         ,color=bluered(400)
                         ,annotation_col=Annotation_col
                         ,cluster_cols =TRUE
                         ,cluster_rows =TRUE
                         ,show_rownames = FALSE
                         ,show_colnames=TRUE
                         ,breaks=seq(-2,2,by=0.01)
                         ,scale="row",
                         fontsize = 20,
                         labels_col=lab_list,
                         fontsize_col = 24)
  
  # col.list<- colnames(vst)[hmap.arrow$tree_col[["order"]]]
  # sample.idx<- which(col.list==sample_name)
  
  # -- Arrow symbol
  #x1=sample.idx/ncol(vst)+0.0240-(0.0004*sample.idx)
  
  # grid.lines(
  # x = unit(c(x1, 
  #           x1),
  #         "npc"),
  # y = unit(c(0, 0.2), "npc"),
  # gp = gpar(fill="purple"),
  # arrow = arrow(length = unit(0.7, "inches"), 
  #            ends="last", type="closed"))
  
  dev.off()
  
  gene_sign.p1 <- as.ggplot(rasterGrob(readPNG("IPRES_Hmap.png",
                                               native = FALSE),
                                       interpolate = FALSE))
  
} 

gene_sign.p <- gene_sign.p1 +
  labs(title="J. IPRES gene signature")+
  theme(plot.title=element_text(size =8 ,
                                face="bold"))

# end IPRES heatmap



# ================================================== Arrange all plots ================================

text.space<- " "
text1.h <- paste("Analysis Report")
text2.h<- paste("Sample name: ",sample_name,
                sep="")

head.space <- ggparagraph(text=text.space,
                          face="bold",
                          size=16,
                          color="white")

head1.p <- ggparagraph(text=text1.h,
                       face="bold",
                       size=16,
                       color="brown")

head2.p <- ggparagraph(text=text2.h,
                       face="bold",
                       size=8,
                       color="purple")



p1 <- ggpubr::ggarrange(head.space,
                        head1.p,
                        head.space,
                        nrow=1,
                        ncol =3,
                        heights = c(0.1,0.1,0.1))

p2 <- ggpubr::ggarrange(
  head.space,
  head2.p,
  head.space,
  nrow = 1,
  ncol = 3,
  heights = c(0.1,0.1,0.1)
)

head.all.p <- ggpubr::ggarrange(
  p1,
  p2,
  ncol = 1,
  nrow= 2,
  heights = c(0.008, 0.009))

p3 <- ggpubr::ggarrange(
  Mut_load,
  head.space,
  hla.types.p2,
  ncol=3,nrow = 1,
  heights = c(1,1,1))

bottom.txt <- paste("Figure: Analysis report. Your sample is shown by purple dots.",
                    "A. Mutation load.",
                    "B. List of HLA types of your sample.",
                    "C. Tumor neoantigen load for class I (without filtering).",
                    "D. Tumor neoantigen load for class I (filtered).", 
                    "E. Tumor neoantigen load for class II (without filtering).",
                    "F. MMR status.", 
                    "G. Germline mutation.",
                    "H. Somatic mutation.",
                    "I. ImmuneMirror prediction score",
                    "J. IPRES gene signature.",
                    sep = " ")


bottom.txt.p <- ggparagraph(text=bottom.txt,
                            face="bold",
                            size=8,
                            color="black")

bottom.txt.p2 <- ggpubr::ggarrange(
  bottom.txt.p,
  nrow = 1,
  ncol=1,
  heights = c(0.03))

ack.png1 <- as.ggplot(rasterGrob(readPNG("/var/pipeline/Ref/IM_DB/ack.PNG",
                                         native = FALSE),
                                 interpolate = FALSE))

multi.page <- as_ggplot(arrangeGrob(
  head.all.p,
  p3,
  neo.I.raw.all,
  neo.I.filtered.all,
  neo.II.raw.all, 
  
  MSI.plot2,
  
  ggarrange(
    GermN.p,
    Somatic.p ,
    ncol=2,
    nrow=1),
  
  layout_matrix = rbind(1,
                        2,2,
                        3,3,
                        4,4,
                        5,5,
                        c(6,6,7,7,7),
                        c(6,6,7,7,7),
                        c(NA,NA,7,7,7)
  )
))

pdf(paste(tumor,"-Analysis_Report.pdf",sep=""),
    paper="a4",
    height = 10,
    width= 6)

multi.page

as_ggplot(arrangeGrob(
  MI.score.plot,
  gene_sign.p,
  bottom.txt.p2,
  ack.png1,
  layout_matrix = rbind(1,1,
                        2,2,2,
                        3,
                        4,4
  ),
  nrow=4,
  ncol=1))
dev.off()
