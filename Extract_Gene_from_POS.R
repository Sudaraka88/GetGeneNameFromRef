if(rstudioapi::isAvailable()) setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # WORKING DIRECTORY
library(data.table)
# 
# gff_data = readRDS("../gff_data_cleaned.rds")

gbk = LDWeaver::parse_genbank_file("FM211187.gbk", length_check = F)
gene_data = as.data.frame(gbk$gbk@cds)

gene_data = gff_data[!is.na(gff_data$gene),] # Only mapped genes in this df
dst = data.table(w = gene_data$start, val = gene_data$start)
setattr(dst, "sorted", "w")
dend = data.table(w = gene_data$end, val = gene_data$end)
setattr(dend, "sorted", "w")


map2gene = function(x, gene_data){
  TMP = which(gene_data$start <= x & gene_data$end >= x)
  if(length(TMP) > 0) {
    gd = gene_data[TMP,]
    overlap = 0 # Overlaps with a gene
  } else {
    sid = dst[CJ(x), .I, roll = "nearest", by = .EACHI]$I
    eid = dend[CJ(x), .I, roll = "nearest", by = .EACHI]$I
    ids = c(sid, eid)
    ds = c(abs(gene_data$start[sid] - x), abs(gene_data$end[eid] - x))
    minds = min(ds)
    gd = gene_data[ids[which(ds == minds)],]
    overlap = minds # No overlap with gene
  }
  return(list(x = x, gd = gd, dist_from_gene = overlap))
}

map2gene(100, gene_data)
