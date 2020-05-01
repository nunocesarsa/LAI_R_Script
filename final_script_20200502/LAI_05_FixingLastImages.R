### clear memory and 
rm(list = ls())
gc()


#load the list of images that got broken and save them as a tif
failed.fld <- "C:/NeonData/digitalPhotography/temp_failed_imgs/"
list.imgs <- list.files(failed.fld,pattern=".NEF")

setwd(failed.fld)



for (i in 1:length(list.imgs)){
  
  print(i)
  
  img.stack <- stack(list.imgs[i])
  img.blue <- raster(img.stack,layer=3)
  #writeRaster(img.stack,paste(failed.fld,gsub(".NEF",".TIF",list.imgs[i]),sep=""),overwrite=T)
  writeRaster(img.blue,paste(failed.fld,gsub(".NEF","_Blue.TIF",list.imgs[i]),sep=""),overwrite=T)
}

list.imgs <- list.files(failed.fld,pattern="_Blue.tif")

#loading the aux functions
source("C:/NeonData/digitalPhotography/LAI_04_FunctionsLAI.R")





#a daa frame to store the data
test.df <- data.frame("ImageID"=list.imgs,"LAI"=NA)


#next step is to put it into a loop where the otsu is ran and also te function for LAI
for (i in 1:length(list.imgs)){
  
  #setting the targets
  #tgt.url <- as.character(tgt.csv$imageFileUrl[i])
  #tgt.unique_id <- as.character(tgt.csv$subsampleID[i])
  #tgt.unique_id <- gsub(pattern=".",replacement="_",x=tgt.unique_id,fixed=T) 
  tgt.unique_id <- gsub(".Blue.tif","_OTSU.tif",list.imgs[i])
  
  
  print(paste("Processing img:",i, "of",length(list.imgs), "with the id:", list.imgs[i]))
  
  #tgt folder
  tmp.fld <- "./temp_imgs/"
  path2tmp.fld <- "C:/NeonData/digitalPhotography/temp_imgs/"
  path2bin.fld <- "C:/NeonData/digitalPhotography/temp_imgs_mask/"
  path2ultracompress <-  "C:/NeonData/digitalPhotography/temp_failed_imgs/temp_imgs_ultracompress/"
  
  #this commad does the automatic thresholding based on otsu method (notice the values have are not perfect 0/1)  
  #before further processing you ahve to do that change
  
  mgk.auto.1 <- "magick convert"
  mgk.auto.2 <- paste(failed.fld,list.imgs[i],sep="")
  mgk.auto.3 <- "-auto-threshold Otsu"
  mgk.auto.4 <- paste(failed.fld,tgt.unique_id,sep="")
  mgk.auto.A <- paste(mgk.auto.1,mgk.auto.2,mgk.auto.3,mgk.auto.4)
  mgk.auto.A
  #### from here it issues commands to the system
  #comment this if you want to just check the namings
  #download.file(tgt.url,
  #              paste(tmp.fld,tgt.unique_id,".NEF",sep=""),method="curl")
  
  #running magick
  system(mgk.auto.A)
  
    
  #now before cleaning up the folder, we calculate LAI
  #load the masked image
  binary.image <- raster(paste(failed.fld,tgt.unique_id,sep="")) < 50 

  #get the corner coordinates
  x_r <- xFromCol(binary.image,ncol(binary.image))
  y_t <- yFromRow(binary.image,1)
  #center
  x_c <- x_r/2
  y_c <- y_t/2
    
  #get diagonal:
  diag = sqrt((x_r)^2+(y_t)^2)
  diag_angle = 180/diag #this assumes a camera wit 180º along the diagonal
    
  #creates a raster with the X and Y coordinaates - this makes it easier later when generating the zenith raster
  x_rst <- setValues(binary.image,xFromCell(binary.image,1:ncell(binary.image)))
  y_rst <- setValues(binary.image,yFromCell(binary.image,1:ncell(binary.image)))
    
  #here we go
  zen_rst <- sqrt((x_rst-x_c)^2+(y_rst-y_c)^2)*diag_angle
    
  #and finally we can calculate LAI:
  test.df$LAI[i] <- Lai_calc(binary.image,zen_rst, 13)
    
  write.csv2(test.df,"C:/NeonData/digitalPhotography/temp_failed_imgs/Last_imgs.csv",row.names = F)
    
  
  
  #deleting previous files
  #file.remove(list.files(path2tmp.fld,pattern="NEF",full.names = T))
  #file.remove(list.files(path2out.fld,pattern="jpg",full.names = T)) #cleans the folder
  #file.remove(list.files(path2out.b.fld,pattern="jpg",full.names = T)) #cleans the folder
  #file.remove(list.files(path2bin.fld ,pattern="jpg",full.names = T)) #cleans the folder
  
  gc(verbose = F)
}

