library(jpeg)
gc()

#load the image
# = readJPEG() 
#blu_im = readJPEG("C:/NeonData/digitalPhotography/temp_imgs_compress_blue/DHP_2019_01_BART034_E2_OVERSTORY_Blue.jpg",native=T)

bin_im = raster("C:/NeonData/digitalPhotography/temp_imgs_mask/DHP_2019_01_BART034_E2_OVERSTORY_Otsu.jpg")> 50
bin_im = raster("C:/NeonData/digitalPhotography/naturalis/FlevoPlot1.1.JPG", band=3)  #not sure of this threshold
bin_im = bin_im/255

#i assume this is what he does
plot(bin_im > .55)
bin_im <- bin_im > .55

(ncol(bin_im)/nrow(bin_im))

#load functions 
source("C:/NeonData/digitalPhotography/LAI_04_AuxFunctions.r")

#ok new plot function:
#PlotHemiImage(bin_im,draw.circle = T) #it will always plot a circle with the main radius as half the nr of columns

#in this paper the author uses rectangular images
#https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5743530/#ece33567-sup-0001
#but did this nikon project the data onto the sensor area instead?3
#https://www.mdpi.com/2072-4292/1/4/1298/htm
#the parameters of licor come from:
#https://sci-hub.im/10.2134/agronj1991.00021962008300050009x
#generating a simple approximation of the angle to the center pixel

#get coordinates of the corners of the image
#y axis
y_t <- yFromRow(bin_im,1)
y_b <- yFromRow(bin_im,nrow(bin_im)) 

#x axis
x_l <- xFromCol(bin_im,1)
x_r <- xFromCol(bin_im,ncol(bin_im))

#center
x_c <- x_r/2
y_c <- y_t/2

#aproximation in degrees
diag = sqrt((x_r)^2+(y_t)^2)/2
#diag_angle = 180/diag
diag_angle = 185/diag #this one is aproximately correct

#now for any given point we can calculate the angle to the center point
#point_coord <- coordinates(bin_im)
#point_angle = point_coord
#d_poi <- sqrt((point_coord[1,1]-x_c)^2+(point_coord[1,2]-y_c)^2)
#a_poi <-d_poi*diag_angle

#Making it quicker
#cell_ind <- setValues(bin_im,1:ncell(bin_im)) #creates a raster that each cell is the cell index
#plot(cell_ind)
x_rst <- setValues(bin_im,xFromCell(bin_im,1:ncell(bin_im)))
y_rst <- setValues(bin_im,yFromCell(bin_im,1:ncell(bin_im)))

#calculating a ratio
ratio_sky(bin_im)
#calculating a ring
#zen_rst <- sqrt((x_rst-x_c)^2+(y_rst-y_c)^2)*diag_angle
zen_rst <- sqrt((x_rst-x_c)^2+(y_rst-y_c)^2)*diag_angle

par(mfrow=c(1,1))
#plot(zen_rst)
#plot(bin_im)
#plot(ring_calc(zen_rst,10,20)*0+1)

#because this is a true fisheye, we have to remove everythig outside the ring
par(mfrow= c(1,3))
plot(bin_im)
plot(ring_calc(zen_rst,0,90))
plot(bin_im*(ring_calc(zen_rst,0,90)*0+1))

bin_im <- bin_im*(ring_calc(zen_rst,0,90)*0+1)
#now the ratio_sky should change
ratio_sky(bin_im)

#calculating a ring with the ratio of pixel that are sky or not
#ring_frac <- ratio_sky((ring_calc(zen_rst,40,50)*0+1)*bin_im)

#calculating the fraction of sky pixels in a given ring
#gap_frac(bin_im,zen_rst,10,11)

#calculating the gap fraction from 0 to 89 by steps of 1 degree and a total area of 1+/-.5

#exxample
A_t = cellStats(ring_calc(zen_rst,.5,89)*0+1,sum)
A_a = cellStats(ring_calc(zen_rst,3,5)*0+1,sum)
#calculating canopy openess for that specific single ring 
Can_Open = gap_frac(bin_im,zen_rst,3,5)*A_a/A_t
Can_Open

#calculating the gap fractions from 1 to 89 degree
min_At = 1
max_at = 89
ring_w = .5

A_t = cellStats(ring_calc(zen_rst,min_At,max_at)*0+1,sum)
Can_Open = 0
for (i in 1:89){
  print(i)
  min_a = i-ring_w
  max_a = i+ring_w
  A_a = cellStats(ring_calc(zen_rst,i-ring_w,i+ring_w)*0+1,sum)
  Can_Open=Can_Open+gap_frac(bin_im,zen_rst,min_a,max_a)*A_a/A_t
}
Can_Open

par(mfrow=c(1,1))
plot(bin_im)

Lai_calc(bin_im,zen_rst, 13)

gc()

