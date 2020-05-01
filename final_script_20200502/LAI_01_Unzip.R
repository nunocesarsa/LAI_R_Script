library(utils)
library(rlang)

setwd("C:/NeonData/digitalPhotography")


list.zips <- list.files("./OriginalZips/",pattern=".zip",full.names = T)
head(list.zips)


#testing object
zip1 <- list.zips[c(1)]


list.files("./TempTables",pattern="*LMA*")

#comment this to run for the entire data
#list.zips <- list.zips[1:10]
list.zips

p <- 1
for (i in list.zips){
  
  #cleans any file that excaped
  templist <- list.files("./temp_fld",full.names = T)
  file.remove(templist)
  
  print(paste("unziping file number",p))
  p<-p+1
  print(i)
  unzip(i,exdir = "./temp_fld")

  #namesfiles = list.files("./temp_fld",pattern="*perimagefile*")
  #pathsfiles = list.files("./temp_fld",full.names = T,pattern="*perimagefile*")  

  namesfiles = list.files("./temp_fld",pattern="*dhp_perplot*")
  pathsfiles = list.files("./temp_fld",full.names = T,pattern="*dhp_perplot*")  
  
  
  if (is_empty(namesfiles)){ 
    print(paste(i,"has no file"))
  } else {
    temp.file <- read.csv(pathsfiles[1])
    write.csv2(temp.file,paste("./csv_dump/dhp_perplot/",namesfiles[1],sep = ""))
    print(paste("saved:",namesfiles[1]))
  }
  
  
  
  # TabOfInt = c(4,6,8,12)
  # k <- 1
  # for (j in namesfiles[TabOfInt]){
  #   print(j)
  #   temp.table <- read.csv(pathsfiles[TabOfInt[k]])
  #   write.csv2(temp.table,paste("./TablesInterest/",j,sep = ""))
  #   k <- k+1
  # }
  
  templist <- list.files("./temp_fld",full.names = T)
  file.remove(templist)
}