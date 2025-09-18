#if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               sf,
               mapview,
               here)

#Read Fish Data (get data from spreadsheet and move to R)
df_fish <- read_csv(here::here("data/data_finsync_nc.csv"))


#Converting to a GIS format
sf_site <- df_fish %>% 
  distinct(site_id,
           lon,
           lat) %>% 
  st_as_sf(coords = c("lon", "lat"),
           crs = 4326)

#Comparing the two tables 
df_fish
sf_site

#Data on the map 
mapview(sf_site,
        legend = FALSE)

#Now going to save or export data to use later 
saveRDS(sf_site,
        file = here::here("data/sf_finsync_nc.rds"))


##Conversion from Geodetic CRS to Projected CRS
sf_ft_wgs <- sf_site %>% 
  slice(c(1,2))

sf_ft_utm <- sf_ft_wgs %>% 
  st_transform(crs = 32617)

#View these two points on the map 
mapview(sf_ft_wgs)

#Find distance between two points on map 
st_distance(sf_ft_utm)

#Excercise 
as_tibble(quakes)
df_quakes <- as_tibble(quakes)

sf_quakes <- df_quakes %>% 
  st_as_sf(coords = c("long", "lat"),
           crs = 4326)

mapview(sf_quakes)

st_bbox(sf_quakes)

#Convert geodetic CRS to projected CRS (UTM 60S)
sf_ft_quakes <- sf_quakes %>% 
  slice(c(1,2))

sf_ft_quakes_proj <- sf_ft_quakes %>% 
  st_transform(crs = 32760)

##Calculate geographic distance 
st_distance(sf_ft_quakes_proj)

st_distance(sf_ft_quakes)

#Save and export 
saveRDS(sf_quakes,
        file = here::here("data/sf_quakes.rds"))



