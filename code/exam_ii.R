# Exam II
# By submitting this exam on time, you will obtain 55 points
# 15 questions in total, with each worth 3 points
# Points will be awarded if your code produces the expected result(s)

if (!require(pacman)) install.packages("pacman")
library(pacman)

# call packages -----------------------------------------------------------

# Execute the following lines of code to call packages
p_load(tidyverse,
       sf,
       terra,
       exactextractr,
       tidyterra)

# To answer the following questions, use the data below:
df_site <- read_csv("data/data_finsync_nc.csv") %>% 
  distinct(site_id, 
           lon, 
           lat)

sf_nc_county <- readRDS("data/sf_nc_county.rds")
df_site
# vector data analysis ----------------------------------------------------

# Q1. 
# `df_site` currently has no coordinate reference system (CRS). 
# Convert it to an `sf` object and assign the WGS 84 CRS (EPSG: 4326). 
# Save the resulting object as `sf_site`.
sf_site <- st_as_sf(df_site,
                    coords = c("lon" , "lat"),
                    crs = 4326)

# Q2.
# From `sf_nc_county`, select only the county polygons of the following counties: 
#   "guilford", "randolph", "davidson", and "forsyth". 
# Save the result as `sf_four`.
sf_four <- subset(sf_nc_county, tolower(county) %in% c("guilford" , "randolph" , "davidson" , "forsyth"))

# Q3. 
# Perform a spatial join to identify sites in `sf_site` that fall within 
#   the four selected counties stored in `sf_four`. 
# Make sure that the output object is a POINT layer after spatial join.
# Remove any rows without a `county` value and save the result as `sf_site_four`.
sf_site_aligned <- st_transform(sf_site, st_crs(sf_four))

sf_site_four <- st_join(sf_site_aligned,
                        sf_four,
                        select("county"),
                        join = st_within,
                        left = FALSE)
# Q4. 
# Create a map showing the four selected counties (`sf_four`) 
#   and the sampling sites (`sf_site_four`) overlaid on the same plot. 
ggplot() +
  geom_sf(data = sf_four, fill = NA, color = "black") +
  geom_sf(data = sf_site_four, color = "blue") +
  theme_minimal()

# Q5. 
# Calculate the pairwise distances among all sites in `sf_site_four`
#   with the appropriate CRS, UTM Zone 17N (EPSG: 32617) 
#   so that distances are measured in meters. 
# Then, find the maximum distance among all site pairs.
# 
sf_site_four_utm <- st_transform(sf_site_four, 32617)

D <- st_distance)sf_site_four_utm) 
diag(D) <- NA 
max_dist <- max (D, na.rm = TRUE)
as.numeric(max_dist)
# ENTER YOUR ANSWER HERE:


# raster data analysis ----------------------------------------------------

# Q6. 
# The raster file "spr_land_reclass.tif" in the "data" folder 
#   contains reclassified land-cover data, 
#   where pixel values represent land-cover types as follows:
#   1001 = forest
#   1010 = crop
#   1100 = urban
#   0 = other
# 
# Load this raster as `spr_land` and display the unique land-cover codes it contains.
spr_land <- rast("data/spr_land_reclass.tif")
unique(values(spr_land))
# Q7. 
# Reclassify the raster `spr_land` to create a new raster object `spr_crop` 
#   that highlights only cropland areas. 
# Use the following reclassification rules:
#   1001 = 0 (forest)
#   1010 = 1 (crop)
#   1100 = 0 (urban)
#   0 = 0 (other)
sc <- cbind(c(1001, 1010, 1100, 0),
                  c(0, 1, 0, 0))
spr_crop <- classify (spr_land, sc)
unique(values(spr_crop))


# Q8. 
# Crop the cropland raster (`spr_crop`) to the extent of the four selected counties 
# (`sf_four`; "guilford", "randolph", "davidson", and "forsyth")
# Save the resulting cropped raster as `spr_crop_four`.
four_v <- project(vect(sf_four), crs(spr_crop))
spr_crop_four <- crop(spr_crop, four_v)

# Q9. 
# Create a map showing the cropped cropland raster (`spr_crop_four`) 
#   overlaid with the four counties (`sf_four`). 
# Use a semi-transparent overlay for the counties.
spr_df <- as.data.frame(spr_crop_four, xy = TRUE)

sf_four_gg <- st_transform(sf_four, crs(spr_crop_four))

ggplot() +
  geom_raster(data = spr_df, aes(x = x, y = y, fill = crop)) +
  scale_fill_gradient(low = "white", high = "darkgreen",
                      name = "Cropland (1 = crop)") +
  geom_sf(data = sf_four_gg,
          fill = NA,
          color = "black",
          alpha = 0.4,
          linewidth = 0.8) +
  coord_sf() +
  theme_minimal()
# Q10. Calculate the proportion of cropland pixels within the four counties 
#   from the cropped raster (`spr_crop_four`). 
# Since cropland pixels are coded as 1 and others as 0, the mean gives the proportion.
#
# ENTER YOUR ANSWER HERE:
# (round your answer to third decimal places, e.g., 0.021)
prop_crop <- mean(values(spr_crop_four), na.rm = TRUE)

# raster-vector interaction -----------------------------------------------

# Q11.
# The raster file "spr_tmp_nc.tif" in the "data" folder contains 
#   annual mean temperature (°C) data for North Carolina. 
# Load this raster and extract the temperature values 
#   at each sampling site in `sf_site`. 
# Then, identify how many sites have temperature values greater than 16°C.
#
# ENTER YOUR ANSWER HERE: 24
spr_temp <- rast("data/spr_tmp_nc.tif")
sf_site_temp <- st_transform(sf_site, crs(spr_temp))
temp_vals <- terra::extract(spr_temp, vect(sf_site_temp))
sf_site_temp$temp <- temp_vals[, 2]
sum(sf_site_temp$temp > 16, na.rm = TRUE)

# Q12. Create 3-km buffers around each site in `sf_site_four` (see Q3). 
# Be sure to first transform the coordinate reference system to UTM Zone 17N (EPSG: 32617) 
# so that the buffer distance is measured in meters.
sf_site_four_utm <- st_transform(sf_site_four, 32617)
sf_site_four_buf <- st_buffer(sf_site_four_utm, dist = 3000)

# Q13. Project the cropped cropland raster (`spr_crop_four`) 
# to the same UTM coordinate reference system (EPSG: 32617). 
# Use an appropriate re-sampling method in light of the raster data type.
spr_crop_four_utm <- project(spr_crop_four,
                             "EPSG:32617",
                             method = "near")

# Q14. Create a map displaying the projected cropland raster (`spr_crop_proj`) 
# with 3-km site buffers (`sf_buff_proj`) overlaid.
sf_buff_proj <- st_transform(sf_buff_proj, crs(spr_crop_proj))
crop_df <- as.data.frame(spr_crop_proj, xy = TRUE, na.rm = TRUE)

ggplot() +
  geom_raster(data = crop_df, aes(x = x, y = y, fill = factor(crop))) +
  scale_fill_manual(values = c("0" = "white", "1" = "darkgreen"),
                    name = "cropland",
                    labels = c("other", "crop")) +
  geom_sf(data = sf_buff_proj, fill = NA, color = "red", linewidth = 0.5, alpha = 0.9) +
  coord_equal() +
  theme_minimal() 
# Q15. Calculate the proportion of cropland within each 3-km site buffer. 
# Store the result as `df_crop_frac`, and identify the `site_id` 
# with the highest cropland fraction.
sf_buff_proj <- st_transform(sf_buff_proj, crs(spr_crop_proj))

buff_v <- vect(sf_buff_proj)

ext_vals <- terra::extract(spr_crop_proj, buff_v, df = TRUE)

df_crop_frac <- ext_vals %>% 
  grou[_by(site_id) ]