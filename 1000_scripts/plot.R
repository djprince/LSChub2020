#!/usr/bin/Rscript
setwd("1012_plots")
library(ggplot2)
library(ape)

#PCAs
for (x in sub(list.files(path = ".",pattern = ".*annot"),pattern = ".annot",replacement = "")) {
input <- x
covar <- read.table(paste0(input,".covar"), stringsAsFact=F)
annot <- read.table(paste0(input,".annot"), sep="\t", header=T)
comp <- as.numeric(strsplit("1-2", "-", fixed=TRUE)[[1]]) #change axes here

eig <- eigen(covar, symm=TRUE)
eig$val <- eig$val/sum(eig$val)
cat(signif(eig$val, digits=3)*100,"\n")
PC <- as.data.frame(eig$vectors)
colnames(PC) <- gsub("V", "PC", colnames(PC))
PC$SHAPE <- factor(annot$SHAPE)
PC$COLOR <- factor(annot$COLOR)
PC$LABEL <- factor(annot$LABEL)

p <- ggplot() + theme_bw(base_size=6) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.justification=c(1,1), legend.box.just= "left", legend.text.align =0, legend.position="none", legend.key = element_blank(), legend.background = element_rect(fill="transparent"), legend.text=element_text(size=5), legend.title=element_text(size=6.75)) +
  geom_point(data=PC, size =1,
             aes_string(x=paste("PC",comp[1],sep=""), y=paste("PC",comp[2],sep=""),
                        color="COLOR", shape="SHAPE")) +
  scale_color_manual(breaks = c(1:8), values = c("#F0E442",
                                                 "#0072B2","#D55E00","#009E73","#E69F00",
                                                 "#56B4E9","#BFBFBF","#CC79A7")) +
  geom_text(data=PC, size=2, aes_string(x=paste("PC",comp[1],sep=""), y=paste("PC",comp[2],sep=""),label="LABEL", color = "COLOR")) +
  xlab(label = paste0("PC",comp[1]," (", signif(eig$val[comp[1]],digits=3)*100,"%)")) +
  ylab(label = paste0("PC",comp[2]," (", signif(eig$val[comp[2]],digits=3)*100,"%)"))

pdf(paste0(x,"_pca_12.pdf"), )
print(p)
dev.off()
}

#Admix
cbPalette <- c("#F0E442",
               "#0072B2","#D55E00","#009E73","#E69F00",
               "#56B4E9","#BFBFBF","#CC79A7")[c(3,1,5,2,4)]
bamlist <- read.csv2("all_ge100k.bamlist", header = F, stringsAsFactors = F)
samples <- substr(bamlist$V1,17,21)
input = read.csv2("all_ge100k_k5.qopt", sep=" ", header = F, stringsAsFactors = F)
admix = t(as.matrix(input))
K = nrow(admix)-1
p <- barplot(admix, col=cbPalette[1:K],space=0, border=NA,names.arg = samples,xlab="Individuals", ylab="Admixture")

pdf("all_ge100k_admix_k5.pdf")
print(p)
dev.off()

#Tree
tree = read.tree("1k_constree.outtree")
tree = unroot(tree)
tree = root(tree, outgroup = c("1PCW33"))
tree = compute.brlen(tree,1)


edge.rt=substr(tree$tip.label[tree$edge[,2]],1,1)
edge.clr = edge.rt
edge.clr = sub(edge.clr, pattern = "^1", replacement = "#F0E442")
edge.clr = sub(edge.clr, pattern = "^2", replacement = "#0072B2")
edge.clr = sub(edge.clr, pattern = "^3", replacement = "#D55E00")
edge.clr = sub(edge.clr, pattern = "^4", replacement = "#009E73")
edge.clr = sub(edge.clr, pattern = "^5", replacement = "#E69F00")
edge.clr = sub(edge.clr, pattern = "^6", replacement = "#56B4E9")
edge.clr = sub(edge.clr, pattern = "^7", replacement = "#BFBFBF")
edge.clr = sub(edge.clr, pattern = "^8", replacement = "#CC79A7")
edge.clr = ifelse(is.na(edge.clr),'#000000',edge.clr)

p <- plot(tree,
     type="phylogram",
     cex = .3,
     lab4ut ="axial",
     no.margin = F,
     edge.color=edge.clr
)

pdf("1k_consensus_tree.pdf")
print(p)
dev.off()

