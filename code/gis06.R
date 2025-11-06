if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               sf,
               terra,
               tidyterra,
               exactextractr,
               here)

## finsync survey site
sf_site <- readRDS(here("data/sf_finsync_nc.rds"))

## county polygons
sf_nc_county <- readRDS(here("data/sf_nc_county.rds"))

## precipitation raster
spr_prec_nc <- rast(here("data/spr_prec_nc.tif"))


# Point-Wise Extraction ---------------------------------------------------

ggplot() +
  geom_spatraster(data = spr_prec_nc) +
  geom_sf(data = sf_site) +
  scale_fill_viridis_c()

#visualization of where the sites are 

#Now lets extract 
(sf_site_prec <- extract(x = spr_prec_nc, 
        y = sf_site,
        bind = TRUE)) %>% 
  st_as_sf()

ggplot() +
  geom_sf(data = sf_nc_county,
          fill = "gray") +
  geom_sf(data = sf_site_prec,
          aes(color = precipitation)) +
  scale_color_viridis_c() +
  theme_bw()


# Zonal Statistics  -------------------------------------------------------

#Transrom the sf_site to 32617 using st_transform()  #converts crs in vector data 

sf_nc_county_proj <- sf_nc_county %>% 
  st_transform(crs = 32617)


#transform spr_prec_nc to 32617 using project() 
spr_prec_nc_proj <- project(spr_prec_nc,
                            y = "EPSG: 32617",
                            method = "bilinear")


df_prec_county <- exact_extract(x = spr_prec_nc_proj,
                                y = sf_nc_county_proj,
                                fun = "mean",
                                append_cols = TRUE) %>%
  as_tibble() %>% 
  rename(precipitation = mean)



df_prec_county_sd <- exact_extract(x = spr_prec_nc_proj,
                                y = sf_nc_county_proj,
                                fun = "stdev",
                                append_cols = TRUE) %>%
  as_tibble()



sf_nc_county_prec <- sf_nc_county %>% 
  left_join(df_prec_county,
             by = "county")

ggplot() +
  geom_sf(data = sf_nc_county_prec,
          aes(fill = precipitation)) +
  scale_fill_viridis_c() +
  theme_bw()



# buffer analysis  --------------------------------------------------------

#Transform CRS
sf_site_proj <- sf_site %>% 
  st_transform(crs = 32617)

#Create Buffer around the points 
sf_site_buff_proj <- sf_site_proj %>% 
  st_buffer(dist = 10000) 

ggplot() +
  geom_sf(data = sf_nc_county_proj) +
  geom_sf(data = sf_site_buff_proj) +
  geom_sf(data = sf_site_proj) 

### Get the mean precipitation for each site buffer (1)
## link these values to site layer (2)
# map the precipitation value at each site (3)

#1
df_buff_prec <- exact_extract(x = spr_prec_nc_proj,
                              y = sf_site_buff_proj,
                              fun = "mean",
                              append_cols = TRUE) %>% 
  as_tibble() %>% 
  rename(precipitation = mean)
 
# 2 
sf_site_prec_buff <- sf_site %>% 
  left_join(df_buff_prec,
            by = "site_id")
#3
ggplot() +
  geom_sf(data = sf_nc_county) +
  geom_sf(data = sf_site_prec_buff,
          aes(color = precipitation))

#Identify top three high-prec sites 
sf_site_prec_buff %>% 
  arrange(desc(precipitation)) %>% 
  slice(1:3)

