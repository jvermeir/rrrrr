library(data.table)

df1 <- read.csv("~/data/temp1.csv", sep=";")
df1

df2 <- read.csv("~/data/temp2.csv", sep=";")
df2

df1_1 <- data.table(df1, key=c("gene_names","protein_names","ksmbr_number","kust_number"))
df1_1

df2_1 <- data.table(df2, key=c("gene_names","protein_names","ksmbr_number","kust_number"))
df2_1

outDT <- merge(df1_1,df2_1,all = TRUE)
outDT

outDT[is.na(accession_number.x), accession_number.x:=accession_number.y]

res <- outDT[,list(accession_number.x,gene_names,protein_names,ksmbr_number,kust_number)]
res
