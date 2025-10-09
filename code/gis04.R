if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               terra,
               tidyterra,
               mapview,
               stars,
               here)


# read/export raster data  ------------------------------------------------

##Reading data 
spr_ex <- rast(here("data/spr_example.tif"))
spr_ex

##Exporting data 
writeRaster(spr_ex,
            filename = here("data/spr_elev.tif"),
            overwrite = TRUE)

##Mapping 
ggplot() +
  geom_spatraster(data = spr_ex) 

#Mapview function (as stars)
star_ex <- st_as_stars(spr_ex)
class(spr_ex)
class(star_ex)
mapview(star_ex)

#How to get information from Raster Data
#Countinuous data example 

v_elev <- values(spr_ex)

head (v_elev, 10)

#na.omit gets rid of NA's... mean gets average output without NA's 

na.omit(v_elev) %>% 
  mean()

#extract is a function to get certain value from location... which and where (first always long second always lat)
#Want to extract data from a given location 

xy <- cbind(6.0000, 50.0000)

extract(spr_ex, xy)

#xy can be multiple sites 
df_point <- tibble(lon = c(6, 5.9),
                   lat = c(50, 49.96))
df_point

extract(spr_ex,
        y = df_point)

#Discrete Data is a tad more complicated than continuous Data 
spr_forest <- rast(here("data/spr_forest_nc.tif"))
#adding one more paranthesis will print the code 
(spr_forest <- rast(here("data/spr_forest_nc.tif")))

#Mapping 
ggplot() +
  geom_spatraster(data = spr_forest)

unique(spr_forest)

v_binary <- values(spr_forest)
mean(v_binary)

##Discrete data, coded values.. can look at land use and assign different categories 
spr_land <- rast(here("data/spr_land_reclass.tif"))

unique(spr_land)

extract(spr_land, cbind(-79.8063, 36.0701))

#Classify function.. reclass.. need to create a conversion matrix 

cm <- cbind(c(0, 1001, 1010, 1100),
      c(0, 1, 0, 0))  #this is what you want it to look like after conversion 

spr_bin <- classify(spr_land,
         rcl = cm)

unique(spr_bin)

v_bin <- values(spr_bin)
mean(v_bin)


# Exercise ----------------------------------------------------------------


spr_prec_ncne <- rast(here("data/spr_prec_ncne.tif"))

#There are 162 rows and 532 columns. The resolution is 0.00833.., 0.00833..  The Spatial extent is -79.89181, -75.45847, 35.24153, 36.59153. The minimun value is 1063.1 and maximum value is 1501.5. The CRS = 4326

ggplot() +
  geom_spatraster(data = spr_prec_ncne)

sf_site <- readRDS(here("data/sf_finsync_nc.rds"))

df_xy <- st_coordinates(sf_site)

df_land <- extract(spr_land, df_xy) 

unique(df_land)

cu <- cbind(c(0, 1001, 1010, 1100),
      c(0, 0, 0, 1))

spr_urban <- classify(spr_land,
                      rcl = cu)

v_urb <- values(spr_urban)

mean(v_urb)
