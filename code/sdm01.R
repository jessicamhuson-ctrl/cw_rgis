if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               ggeffects,
               sf,
               terra,
               tidyterra,
               exactextractr,
               mapview,
               here)


# Prepare Ecological Data ------------------------------------------------- 


df_finsync <- read_csv(here("data/data_finsync_nc.csv"))

#Want to see what is in this set 
df_st1 <- df_finsync %>% 
  filter(site_id == "finsync_nrs_nc-10013")

df_st1

df_finsync %>% 
  pivot_wider(id_cols = c(site_id, lon, lat),
              names_from = latin,
              values_from = presence) 

#Replace NA's with the number zero 
df_rbs <- df_finsync %>% 
  pivot_wider(id_cols = c(site_id, lon, lat),
              names_from = latin,
              values_from = presence,
              values_fill = 0) %>% 
  select(site_id,
         lon,
         lat,
         "Lepomis auritus") %>% 
  rename(y = "Lepomis auritus")



#Create Sf Object from  this dataframe 
sf_rbs <- df_rbs %>% 
  st_as_sf(coords = c("lon", "lat"),
           crs = 4326)


spr_tmp_nc <- rast(here("data/spr_tmp_nc.tif"))


sf_rbs_w_tmp <- extract(x = spr_tmp_nc,
                          y = sf_rbs,
                          bind = TRUE) %>% 
  st_as_sf()


##MAPPING 

ggplot() +
  geom_spatraster(data = spr_tmp_nc) +
  geom_sf(data = sf_rbs_w_tmp,
          aes(color = factor(y))) +
  scale_fill_viridis_c()


# Statistical Analysis  ---------------------------------------------------

#Draw a figure relating fish presence absence to temp 
df_rbs_w_temp <- as_tibble(sf_rbs_w_tmp)

df_rbs_w_temp %>% 
  ggplot(aes(x = temperature,
            y = y)) +
  geom_point() +
  theme_bw() 
  
m_rbs <- glm(y ~ temperature,
             data = df_rbs_w_temp,
             family = "binomial")  

summary(m_rbs) 

##Draw a Predicted Line 
df_pred <- ggpredict(m_rbs, terms = "temperature [all]")
df_pred

ggplot() +
  geom_point(data = df_rbs_w_temp,
             aes(x = temperature,
                 y = y)) +
  geom_line(data = df_pred,
            aes(x = x,
                y = predicted)) +
  geom_ribbon(data = df_pred,
              aes(x = x,
                  ymin = conf.low,
                 ymax = conf.high),
              fill = "grey",
              alpha = 0.2) +
  theme_bw() +
  labs(x = "Air temperature",
       y = "Probability of occurrence")
       

