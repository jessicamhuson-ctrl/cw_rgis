rm(list = ls())
install.packages("ggeffects")   # only once
library(ggeffects)

library(googledrive)

drive_auth(scopes = "https://www.googleapis.com/auth/drive")

Yes
1

df_snake <- read_csv("data/data_snake_count_v_1_0_1.csv")

install.packages("terra")   
library(terra)
df_precipitation <- rast("data/spr_prec_nc.tif")

