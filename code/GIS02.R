##Going over vector today 

if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               sf,
               mapview, 
               here)

# Read/export vector data

# read a shapefile (e.g., ESRI Shapefile format)
# `quiet = TRUE` just for cleaner output **meaning no reason for this, just to clean up the code a bit 
sf_nc_county <- st_read(dsn = here("data/nc.shp"),
                         quiet = TRUE)


#Export object in R 
#append = false IS needed for the code 
st_write(sf_nc_county,
         dsn = here("data/sf_nc_county.shp"),
         append = FALSE)

#Export as geopackage 
st_write(sf_nc_county,
         dsn = here("data/sf_nc_county.gpkg"),
         append = FALSE)

#Export as rds 
saveRDS(sf_nc_county,
        file = here("data/sf_nc_county.rds"))

#Read rds
sf_nc_county <- readRDS(file = here("data/sf_nc_county.rds"))

#Point data 
sf_site <- readRDS(file = here("data/sf_finsync_nc.rds"))
sf_site

#Now want to map out our data 
mapview(sf_site,
        col.regions = "black", # point's fill color
        legend = FALSE) # disable legend

#Line data 
(sf_str <- readRDS(here("data/sf_stream_gi.rds")))

#Put on map 
mapview(sf_str,
        color = "steelblue", # line's color
        legend = FALSE) # disable legend

#Polygon 
mapview(sf_nc_county,
        col.regions ="tomato",
        legend = FALSE)

#You can mess around with functions and make different maps (same map and points, different view)
sf_str10 <- sf_str %>% 
  slice(1:10)

mapview(sf_str10,
        col.regions = "black",
        legend = FALSE)           ##THis is a map with only first 10 streams, compare to original map - only appears as lines whereas other map is full 

#More messing around; Pick guilford county and highlight **WAY TO ORGANIZE AND VISUALIZE 
mapview(sf_nc_county,
        col.regions = "tomato",
        legend = FALSE)

sf_nc_gi <- sf_nc_county %>% 
  filter(county == "guilford")

mapview(sf_nc_gi,
        col.regions = "salmon",
        legend = FALSE)

#Connecting map to ggplot... use ggplot to visualize a map 
ggplot() +
  geom_sf(data = sf_nc_county)

#Add another layer 
ggplot() +
  geom_sf(data = sf_nc_county) +
  geom_sf(data = sf_str)

#Another layer 
ggplot() +
  geom_sf(data = sf_nc_county) +
  geom_sf(data = sf_str) +
  geom_sf(data = sf_site)

#Better map than above 
ggplot() +
  geom_sf(data = sf_nc_gi) +
  geom_sf(data = sf_str) 

#Exercise 
#Read streamline data for Ashe county - load stream line data file. Assign to sf_str_as
sf_str_as <- readRDS(file = here("data/sf_stream_as.rds"))

#Check CRS - print objects to check CRS for both sf_str_as + sf_nc_county
print(sf_str_as)
print(sf_nc_county)

#Map streams and county boundaries - display both NC county boundaries from sf_nc_county, and Ashe stream lines from sf_str_as
ggplot() +
  geom_sf(data = sf_nc_county) +
  geom_sf(data = sf_str_as)

#Subset county layer to Ashe county and Remap
sf_nc_as <- sf_nc_county %>% 
  filter(county == "ashe")

ggplot() +
  geom_sf(data = sf_nc_as) +
  geom_sf(data = sf_str_as)
