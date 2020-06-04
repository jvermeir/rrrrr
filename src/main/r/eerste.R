library(dplyr)

eerste <- function() {
  meuk <- read.csv("~/data/klein.csv")
  kol1lijst <- c("kustd1700", "kuste2958")
  gefilterde_meuk <- subset(meuk, kust.number %in% kol1lijst)
  
  eerste_rij <- head(gefilterde_meuk, 1)
  print ("eerste rij")
  print (eerste_rij)
  pid <- select(eerste_rij, Protein.ID)
  print ("pid")
  print(pid)
  str(pid)
  result <- pid$Protein.ID[[1]]
  str(result)
  print("---")
  return (result)
}

eerste()
aap <- 1 + 1
print (aap)