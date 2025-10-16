#Still working on vectors. We have point, line, and polygon vectors. You can do many things within this 

if (!require(pacman)) install.packages("pacman")

if (!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse,
               sf,
               mapview,
               here)

#Point Vector 
sf_site <- readRDS("data/sf_finsync_nc.rds")

#Polygon Vector 
sf_nc_county <- readRDS(file = here("data/sf_nc_county.rds"))

#st_join() evaluates two geometry layers. You can see if they overlap each other 

sf_site_join <- st_join(x = sf_site,
        y = sf_nc_county)

#Check how it works 
sf_one <- sf_site %>% 
  slice(1)

mapview(sf_nc_county) + mapview(sf_one) 

#Get data by county 
sf_site_guilford <- sf_site_join %>% 
  filter(county == "guilford")

sf_nc_guilford <- sf_nc_county %>% 
  filter(county == "guilford")

sf_str_guilford <- readRDS(here("data/sf_stream_gi.rds"))

#Create a map... ggplot() is how to make map 
ggplot() +
  geom_sf(data = sf_nc_guilford) +
  geom_sf(data = sf_str_guilford) + 
  geom_sf(data = sf_site_guilford)

#Count the number of sites in each county... Identify the county that has the most sites 
sf_site_join %>% 
  group_by(county) %>% 
  summarize(n_site = n()) %>% 
  arrange(desc(n_site))

#Applying as_tibble takes out the geospacial data.. Now only clean data 
df_n <- sf_site_join %>% 
  as_tibble() %>% 
  group_by(county) %>% 
  summarize(n_site = n()) %>% 
  arrange(desc(n_site))

#sf_nc_county - this is a "geospatial" object
#df_n - the number of sites by county
#Combine them with left_join()

sf_nc_county %>% 
  left_join(df_n,
            by = "county") 

sf_nc_n <- sf_nc_county %>% 
  left_join(df_n,
            by = "county") %>% 
    mutate(n_site = ifelse(is.na(n_site),
                           0,
                           n_site))

#Mapping 
ggplot() +
  geom_sf(data = sf_nc_n,
          aes(fill = n_site))
  

# Geometric Analysis  -----------------------------------------------------
#Length Calculation (available for line objects) 
#Change CRS First!!!!Very Important 
sf_str_proj <- st_transform(sf_str_guilford,
             crs = 32617) 

v_str_l <- st_length(sf_str_proj)
head(v_str_l)

sf_str_w_len <- sf_str_guilford %>% 
  mutate(length = as.numeric(v_str_l))

ggplot() +
  geom_sf(data = sf_str_w_len,
          aes(color = length))

#Area calculation 
sf_nc_county_proj <- st_transform(sf_nc_county,
                                  crs = 32617)

v_area <- st_area(sf_nc_county_proj)

sf_nc_county_w_area <- sf_nc_county %>% 
  mutate(area = as.numeric(v_area)) 

ggplot() +
  geom_sf(data = sf_nc_county_w_area,
          aes(fill = area))

#Exercise 
sf_quakes <- readRDS("data/sf_quakes.rds")
sf_nz <- readRDS("data/sf_nz.rds")

mapview(sf_nz) + mapview(sf_quakes)

sf_quakes_join <- st_join(x = sf_quakes,
                          y = sf_nz)

sf_quakes_nz <- drop_na(sf_quakes_join, fid) 

nrow(sf_quakes_nz)

df_n <- sf_site_join %>% 
  as_tibble() %>% 
  group_by(county) %>% 
  summarize(n = n())

sf_n_site <- sf_site_join %>% 
  left_join(df_n,
            by = "county")

sf_n10 <- sf_n_site %>% 
  filter(n > 10)

ggplot() +
  geom_sf(data = sf_nc_county) +
  geom_sf(data = sf_n_site,
          color = "gray") +
  geom_sf(data = sf_n10,
          color = "salmon")





