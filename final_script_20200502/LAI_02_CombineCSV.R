gc()

setwd("C:/NeonData/digitalPhotography")

out.fld <- "./csv_combined/"

#step 1, load the list of files

dhp_perplot.path <- list.files("./csv_dump/dhp_perplot/",full.names = T)
dhp_perplot <- list.files("./csv_dump/dhp_perplot/")

#this is specific for the task at hand
dhp.col.sel <- names(read.csv2(dhp_perplot.path[1]))

for (i in 1:length(dhp_perplot.path)){
  
  print(paste("processing:", dhp_perplot[i]))
  tmp.df = read.csv2(dhp_perplot.path[i])

  tmp.df = tmp.df[,dhp.col.sel]

  #print(names(tmp.df))
  if (i == 1){
    plt.df = tmp.df
  } else {
    plt.df = rbind(plt.df,tmp.df)
  }
  
  
}
write.csv2(plt.df,paste(out.fld,"dhp_perplot_combined.csv",sep=""),row.names = F)

#repeating the same for the other .csv file
perimagefil.path <- list.files("./csv_dump/perimagefile/",full.names = T)
perimagefil <- list.files("./csv_dump/perimagefile/")

#this is specific for the task at hand
img.col.sel <- names(read.csv2(perimagefil.path[1]))

for (i in 1:length(perimagefil.path)){
  
  print(paste("processing:", perimagefil[i]))
  tmp.df = read.csv2(perimagefil.path[i])
  
  tmp.df = tmp.df[,img.col.sel]
  
  #print(names(tmp.df))
  if (i == 1){
    img.df = tmp.df
  } else {
    img.df = rbind(img.df,tmp.df)
  }
  
  
}
write.csv2(img.df,paste(out.fld,"perimagefile_combined.csv",sep=""),row.names = F)

#selecting 2019
img.df.2019 <- img.df
img.df.2019$Year <- substr(img.df.2019$startDate,1,4)
img.df.2019 = img.df.2019[img.df.2019$Year=="2019",]
write.csv2(img.df.2019,paste(out.fld,"perimagefile_combined_2019.csv",sep=""),row.names = F)

img.df.2019.over <- img.df.2019[img.df.2019$imageType =="overstory",]
img.df.2019.unde <- img.df.2019[img.df.2019$imageType =="understory",]
write.csv2(img.df.2019.over,paste(out.fld,"perimagefile_combined_2019_overstory.csv",sep=""),row.names = F)
write.csv2(img.df.2019.unde,paste(out.fld,"perimagefile_combined_2019_understory.csv",sep=""),row.names = F)
