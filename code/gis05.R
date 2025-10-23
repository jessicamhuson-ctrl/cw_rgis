if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               terra,
               tidyterra,
               mapview,
               stars,
               here)

# crop --------------------------------------------------------------------

#US-WIDE Precipitation Layer 
(spr_prec <- rast(here("data/spr_prec_us.tif")))

#Visualization
ggplot() +
  geom_spatraster(data = spr_prec)

#Function ext shows the extent of the layer 
ext(spr_prec)

#crop function, direct entry of lat/lon 
spr_prec_crop <- crop(x = spr_prec,
                      y = c(-80, -75, 34, 37))

ext(spr_prec_crop)

# Check coverage Visually 
sf_nc_county <- readRDS(here("data/sf_nc_county.rds"))

ggplot() +
  geom_spatraster(data = spr_prec_crop) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

# Use vector layer as a mask layer. No need to enter raw lat/lon values directly. Crop function extracts the extent from the vector layer. 
spr_prec_nc <- crop(x = spr_prec,
                    y = sf_nc_county)

ggplot() +
  geom_spatraster(data = spr_prec_nc) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)               ##aplha makes the polygon layer transparent 



# Merge -------------------------------------------------------------------

spr_nw <- rast(here("data/spr_prec_ncnw.tif")) # Northwest NC
spr_ne <- rast(here("data/spr_prec_ncne.tif")) # Northeast NC
spr_sw <- rast(here("data/spr_prec_ncsw.tif")) # Southwest NC
spr_se <- rast(here("data/spr_prec_ncse.tif")) # Southeast NC

# Visualize NorthWest 
ggplot() +
  geom_spatraster(data = spr_nw) +
  geom_sf(data = sf_nc_county,
          aplha = 0.25)

# Use merge() function 
spr_n <- merge(spr_nw, spr_ne)

ggplot() +
  geom_spatraster(data = spr_n) +
  geom_sf(data = sf_nc_county, 
          alpha = 0.25)
ext(spr_nw)
ext(spr_n)


# Merge multiple Raster Layers --------------------------------------------
# 1st step: create a list of raster layers 
list(spr_ne,
     spr_nw)

#Can add more to list and assign to list_spr 
list_spr <- list(spr_ne,
                 spr_nw,
                 spr_se,
                 spr_sw)


spr_col <- sprc(list_spr) ## Need to complete this step before merge 

spr_merge <- merge(spr_col)

ggplot() +
  geom_spatraster(data = spr_merge) + 
  geom_sf(data = sf_nc_county,
          alpha = 0.25) 

# Export the merged file 
writeRaster(spr_merge, 
            filename = here("data/spr_prec_nc.tif"),
            overwrite = TRUE)


# Stack  ------------------------------------------------------------------
spr_prec_nc <- rast(here("data/spr_prec_nc.tif"))
spr_tmp_nc <- rast(here("data/spr_tmp_nc.tif"))

spr_pt_nc <- c(spr_prec_nc,
               spr_tmp_nc)
print(spr_pt_nc)

# Access each layer separately 
spr_pt_nc$precipitation 
spr_pt_nc$temperature


# Reprojection  -----------------------------------------------------------
print(spr_prec_nc)

# Reprojection for raster 
spr_prec_nc_proj <- project(x = spr_prec_nc,
                            y = "EPSG: 32617")

# "Safer way to do this bc of projection, do not want to lose original information"
spr_prec_nc_proj <- project(x = spr_prec_nc,
                            y = "EPSG: 32617",
                            method = "bilinear")


# Exercise  ---------------------------------------------------------------
tmp_nw <- rast(here("data/spr_tmp_ncnw.tif"))
tmp_ne <- rast(here("data/spr_tmp_ncne.tif"))
tmp_sw <- rast(here("data/spr_tmp_ncsw.tif"))
tmp_se <- rast(here("data/spr_tmp_ncse.tif"))

list_tmp <- list(tmp_nw,
                 tmp_ne,
                 tmp_sw,
                 tmp_se)

tmp_col <- sprc(list_tmp)

tmp_merge <- merge(tmp_col)

ggplot() +
  geom_spatraster(data = tmp_merge) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

sf_camden <- sf_nc_county %>% 
  filter(county == "camden")

ext(sf_camden)

spr_tmp_camden <- crop(x = spr_merge,
                       y = sf_camden)

ggplot() +
  geom_spatraster(data = spr_tmp_camden) +
  geom_sf(data = sf_camden,
          alpha = 0.25)

spr_tmp_camden_proj <- project(x = spr_tmp_camden,
                               y = "EPSG: 32618", 
                               method = "bilinear")

print(spr_tmp_camden_proj)
