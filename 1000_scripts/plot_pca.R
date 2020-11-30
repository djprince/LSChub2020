# Usage: Rscript -i infile.covar -c component1-component2 -a annotation.file -o outfile.eps
.libPaths("/home/djprince/programs/R/x86_64-pc-linux-gnu-library/3.6/")
library(optparse)
library(ggplot2)

option_list <- list(make_option(c('-i','--in_file'), action='store', type='character', default=NULL, help='Input file (output from ngsCovar)'),
                    make_option(c('-c','--comp'), action='store', type='character', default=1-2, help='Components to plot'),
                    make_option(c('-a','--annot_file'), action='store', type='character', default=NULL, help='Annotation file with individual classification (3 column TSV with headers "SHAPE[tab]COLOR[tab]LABEL"'),
                    make_option(c('-o','--out_file'), action='store', type='character', default=NULL, help='Output file')
)
opt <- parse_args(OptionParser(option_list = option_list))
covar <- read.table(opt$in_file, stringsAsFact=F)
annot <- read.table(opt$annot_file, sep="\t", header=T)
comp <- as.numeric(strsplit(opt$comp, "-", fixed=TRUE)[[1]])
                   
                   
eig <- eigen(covar, symm=TRUE)
eig$val <- eig$val/sum(eig$val)
cat(signif(eig$val, digits=3)*100,"\n")
PC <- as.data.frame(eig$vectors)
colnames(PC) <- gsub("V", "PC", colnames(PC))
PC$SHAPE <- factor(annot$SHAPE)
PC$COLOR <- factor(annot$COLOR)
PC$LABEL <- factor(annot$LABEL)

ggplot() + theme_bw(base_size=6) + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.justification=c(1,1), legend.box.just= "left", legend.text.align =0, legend.position=c(1,1), legend.key = element_blank(), legend.background = element_rect(fill="transparent"), legend.text=element_text(size=5), legend.title=element_text(size=6.75)) +
  geom_point(data=PC, size =2,
             aes_string(x=paste("PC",comp[1],sep=""), y=paste("PC",comp[2],sep=""), 
                        color="COLOR", shape="SHAPE")) +
  geom_text(data=PC, size=1, aes_string(x=paste("PC",comp[1],sep=""), y=paste("PC",comp[2],sep=""),label="LABEL")) +
  xlab(label = paste0("PC",comp[1]," (", signif(eig$val[comp[1]],digits=3)*100,"%)")) +
  ylab(label = paste0("PC",comp[2]," (", signif(eig$val[comp[2]],digits=3)*100,"%)")) + scale_color_brewer(palette="Paired") 

ggsave(opt$out_file)
unlink("Rplots.pdf", force=TRUE)

