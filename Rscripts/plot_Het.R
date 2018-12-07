library(ggplot2)
library(cowplot)
library(RColorBrewer)
variants <-read.table("results/Hwer_ExpEvol_EXF-562.SNP.het_gg.bz2",header=T)

variants$CHR <- strtoi(sub("QWIS010+([0-9]+)\\.1","\\1",variants$CHROM,perl=TRUE))
chrlist = 1:327 # we probably want to truncate this - a bit too big or filter by length
# scaffold 1->327 are > 10kb
d=variants[variants$CHR %in% chrlist, ]

d <- d[order(d$CHR, d$POS), ]
d$index = rep.int(seq_along(unique(d$CHR)), times = tapply(d$POS,d$CHR,length)) 

d$pos=NA

nchr = length(unique(chrlist))
lastbase=0
ticks = NULL
minor = vector(,8)

for (i in 1:nchr ) {
  if (i ==1) {
    d[d$index==i, ]$pos = d[d$index==i, ]$POS
  } else {
    ## chromosome position maybe not start at 1, eg. 9999. So gaps may be produced. 
    lastbase = lastbase + max(d[d$index==(i-1),"POS"])
    minor[i] = lastbase
    d[d$index == i,"POS"] =
      d[d$index == i,"POS"]-min(d[d$index==i,"POS"]) +1
    d[d$index == i,"End"] = lastbase
    d[d$index == i, "pos"] = d[d$index == i,"POS"] + lastbase
  }
}
ticks <-tapply(d$pos,d$index,quantile,probs=0.5)
ticks
minorB <- tapply(d$End,d$index,max,probs=0.5)
minorB
minor
xmax = ceiling(max(d$pos) * 1.03)
xmin = floor(max(d$pos) * -0.03)

pdffile="plots/Genomewide_Het.pdf"
pdf(pdffile,width=30,height=8)
Title="Genomewide Heterozygocity"

p <- ggplot(d,aes(x=pos,y=HET)) +
  #geom_vline(mapping=NULL, xintercept=minorB,alpha=0.5,size=0.1,colour='grey15')	+
  geom_point(alpha=0.8,size=0.2,shape=16) + facet_wrap(~SAMPLE,nrow=4) +
  scale_color_brewer(palette="Set2") +
  labs(title=Title,xlab="Position",y="Het") +
  scale_x_continuous(name="Chromosome", expand = c(0, 0)) +
  scale_y_continuous(name="Het", expand = c(0, 0),
                     limits = c(0,1)) + theme_classic() + 
  guides(fill = guide_legend(keywidth = 3, keyheight = 1)) 

p

for (n in 1:5 ) {
  Title=sprintf("Chr%s HET",n)
  print(Title)
  l <- subset(d,d$CHR==n)
  p<-ggplot(l,
            aes(x=POS,y=HET,color=SAMPLE)) + 
    geom_point(alpha=0.7,size=0.75,shape=16) 
    labs(title=Title,xlab="Position",y="Het frequency") +
    theme_classic() +
    guides(fill = guide_legend(keywidth = 3, keyheight = 1))
  ggsave(sprintf("plots/Scaffold_%s.HET.pdf",n),p,width=18,height=8)
  p
}



