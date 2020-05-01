
library(raster)

gc()
#setting wd
setwd("C:/NeonData/digitalPhotography")
#loading the csv
#tgt.csv <- read.csv2("C:/NeonData/digitalPhotography/csv_combined/perimagefile_combined_2019_overstory.csv")
#tgt.csv <- read.csv2("C:/NeonData/digitalPhotography/csv_combined/temp_perimagefile_combined_2019_overstory_loopfinal_failedimges.csv")




#load the auxiliar functions for LAI calculation
source("LAI_04_FunctionsLAI.R")


##this part make some selections already

head(tgt.csv)
list.sites = c("JERC","UNDE","KONA",
               "DELA","DCFS","CLBJ",
               "NIWO","WREF","SJER")
tgt.csv <- tgt.csv[tgt.csv$siteID %in% list.sites,]


#and now we select the months of interest:
tgt.csv$Month = substr(tgt.csv$startDate,6,7)
month.list <- c("03","04","05","06","07","08","09")

tgt.csv <- tgt.csv[tgt.csv$Month %in% month.list,]
#and also we need to redux the number of months 

########### From here its the REAL DEAL  ####################


#ok lets do a loop - beware this takes time
#test.csv <- tgt.csv[1:3,]
test.csv <- tgt.csv

#test.csv$LAI <- NA
#had a crash at line 824
#had a crash at line 886
#had a crash at line 1009 to 1020 were skipped, fatal error which i can't seem to solve 
#had a crash at line 1427 - jumped to 1440
#had a crash at line 1550 - jumped to 1555
#had a crash at line 1634 - jumped to 1640
#had a crash at line 1927 - jumped to 1945
#had a crash at line 2014 - jumped to 2024
#had a crash at line 3882 - jumped to 3900
#had a crash at line 3941 - jumped to 3951
#had a crash at line 4014


#for (i in 1){
for (i in 1:nrow(test.csv)){
  
  #setting the targets
  tgt.url <- as.character(tgt.csv$imageFileUrl[i])
  tgt.unique_id <- as.character(tgt.csv$subsampleID[i])
  tgt.unique_id <- gsub(pattern=".",replacement="_",x=tgt.unique_id,fixed=T) 
  
  print(paste("Processing img:",i, "of",nrow(test.csv), "with the id:", tgt.unique_id))
  
  #tgt folder
  tmp.fld <- "./temp_imgs_failed/"
  path2tmp.fld <- "C:/NeonData/digitalPhotography/temp_imgs_failed/"
  path2out.fld <- "C:/NeonData/digitalPhotography/temp_imgs_compress/"
  path2out.b.fld <- "C:/NeonData/digitalPhotography/temp_imgs_compress_blue/"
  path2bin.fld <- "C:/NeonData/digitalPhotography/temp_imgs_mask/"
  
  path2ultracompress <-  "C:/NeonData/digitalPhotography/temp_imgs_ultracompress/"
  
  
  #creating magic command to compress the image for further processing
  magick.p1 <- "magick"
  magick.p2 <- "-strip -interlace Plane -gaussian-blur 0.05 -quality 75%"
  magick.cmd <- paste(magick.p1,
                      paste(path2tmp.fld,tgt.unique_id,".NEF",sep=""),
                      magick.p2,
                      paste(path2out.fld,tgt.unique_id,".jpg",sep=""))
  
  #and also taking the chance to store a ultra-compressed image
  ultra_magick.p1 <- "magick"
  ultra_magick.p2 <- "-strip -interlace Plane -gaussian-blur 0.25 -quality 1%"
  ultra_magick.cmd <- paste(ultra_magick.p1,
                            paste(path2out.fld,tgt.unique_id,".jpg",sep=""),
                            ultra_magick.p2,
                            paste(path2ultracompress,tgt.unique_id,"_1perc.jpg",sep=""))
  
  
  #print(magick.cmd)
  
  ### this command selects only blue band
  mgk.b.1 <- "magick convert"
  mgk.b.2 <- paste(path2out.fld,tgt.unique_id,".jpg",sep="")
  mgk.b.3 <- "-channel RG -fx 0"
  mgk.b.4 <- paste(path2out.b.fld,tgt.unique_id,"_Blue.jpg",sep="")
  mgk.b.A <- paste(mgk.b.1,mgk.b.2,mgk.b.3,mgk.b.4)
  
  
  #this commad does the automatic thresholding based on otsu method (notice the values have are not perfect 0/1)  
  #before further processing you ahve to do that change
  
  mgk.auto.1 <- "magick convert"
  mgk.auto.2 <- paste(path2out.b.fld,tgt.unique_id,"_Blue.jpg",sep="")
  mgk.auto.3 <- "-auto-threshold Otsu"
  mgk.auto.4 <- paste(path2bin.fld,tgt.unique_id,"_Otsu.jpg",sep="")
  mgk.auto.A <- paste(mgk.auto.1,mgk.auto.2,mgk.auto.3,mgk.auto.4)
  
  #### from here it issues commands to the system
  #comment this if you want to just check the namings
  download.file(tgt.url,
                paste(tmp.fld,tgt.unique_id,".NEF",sep=""),method="curl")
  
  #running magick
  #system(magick.cmd)
  #system(ultra_magick.cmd)
  #system(mgk.b.A)
  #system(mgk.auto.A)
  
  #now before cleaning up the folder, we calculate LAI
  #load the masked image
  #binary.image <- raster(paste(path2bin.fld,tgt.unique_id,"_Otsu.jpg",sep="")) > 50 
  #get the corner coordinates
  #x_r <- xFromCol(binary.image,ncol(binary.image))
  #y_t <- yFromRow(binary.image,1)
  #center
  #x_c <- x_r/2
  #y_c <- y_t/2
  
  #get diagonal:
  #diag = sqrt((x_r)^2+(y_t)^2)
  #diag_angle = 180/diag #this assumes a camera wit 180º along the diagonal
  
  #creates a raster with the X and Y coordinaates - this makes it easier later when generating the zenith raster
  #x_rst <- setValues(binary.image,xFromCell(binary.image,1:ncell(binary.image)))
  #y_rst <- setValues(binary.image,yFromCell(binary.image,1:ncell(binary.image)))
  
  #here we go
  #zen_rst <- sqrt((x_rst-x_c)^2+(y_rst-y_c)^2)*diag_angle
  
  #and finally we can calculate LAI:
  #test.csv$LAI[i] <- Lai_calc(binary.image,zen_rst, 13)
  
  #write.csv2(test.csv,"C:/NeonData/digitalPhotography/csv_combined/temp_perimagefile_combined_2019_overstory.csv",row.names = F)
  
  
  #deleting previous files
  #file.remove(list.files(path2tmp.fld,pattern="NEF",full.names = T))
  #file.remove(list.files(path2out.fld,pattern="jpg",full.names = T)) #cleans the folder
  #file.remove(list.files(path2out.b.fld,pattern="jpg",full.names = T)) #cleans the folder
  #file.remove(list.files(path2bin.fld ,pattern="jpg",full.names = T)) #cleans the folder
  
  gc(verbose = F)
}


for (i in 10:1){
  print(i)
}


