df1 <- read.csv("~/data/temp1.csv", sep=";")
df1

df2 <- read.csv("~/data/temp2.csv", sep=";")
df2

#df1$accession_number <- ifelse(is.na(df1$accession_number) == TRUE, df2$accession_number[df2$ksmbr_number == df1$ksmbr_number], df1$accession_number)
df3 <- ifelse(is.na(df1$accession_number) == "TRUE", df2$accession_number[df2$ksmbr_number == df1$ksmbr_number], df1$accession_number)
df3

library(data.table)

fillDf <- data.frame(a = c(1,2,1,2), b = c(3,3,4,4) ,f = c(100,200, 300, 400), g = c(11, 12, 13, 14))
naDf <- data.frame( a = sample(c(1,2), 100, rep=TRUE), b = sample(c(3,4), 100, rep=TRUE), f = sample(c(0,NA), 100, rep=TRUE), g = sample(c(0,NA), 200, rep=TRUE) )
fillDT <- data.table(fillDf, key=c("a", "b"))
naDT <- data.table(naDf, key=c("a", "b"))
outDT <- naDT[fillDT]
outDT
outDT[is.na(f), f:=f.1]

outDT

outDT[is.na(accession_number), accession_number:=f.1]

df1_1 <- data.table(df1, key=c("gene_names","protein_names","ksmbr_number","kust_number"))
df1_1
df2_1 <- data.table(df2, key=c("gene_names","protein_names","ksmbr_number","kust_number"))
df2_1
outDT <- df1_1[df2_1]
outDT
outDT[is.na(accession_number), accession_number:=i.accession_number]
res <- outDT[,list(accession_number,gene_names,protein_names,ksmbr_number,kust_number)]
res


df2$accession_number[df2$ksmbr_number == df1$ksmbr_number]
is.na(FALSE)
data<-c(0,1,2,3,4,2,3,1,4,3,2,4,0,1,2,0,2,1,2,0,4)
frame<-as.data.frame(data)
frame$twohouses <- ifelse(frame$data>=2, 2, 1)
frame

z <- c(TRUE, FALSE, NA)
sum(z)
table(z)["TRUE"]
length(z[z == TRUE])