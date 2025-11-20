if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               ggeffects,
               sf,
               terra,
               tidyterra,
               exactextractr,
               mapview,
               here)

#Prepare ecological data 
df_finsync <- read_csv(here("data/data_finsync_nc.csv"))

#See whats in this set 
df_st1 <- df_finsync %>% 
  filter(site_id == "finsync_nrs_nc-10013")

df_st1

df_finsync %>% 
  pivot_wider(id_cols = c(site_id, lon, lat),
              names_from = latin,
              values_from = presence) 

#Replace NA's w the number zero 
(df_rbs <- df_finsync %>% 
  pivot_wider(id_cols = c(site_id, lon, lat),
              names_from = latin,
              values_from = presence,
              values_fill = 0) %>% 
  select(site_id,
         lon,
         lat,
         "Lepomis auritus") %>% 
  rename(y = "Lepomis auritus"))

df_rbs

#Create sf object 
sf_rbs <- df_rbs %>% 
  st_as_sf(coords = c("lon", "lat"),
           crs = 4326)


#Load Prec Data 
spr_prec_nc <- rast(here("data/spr_prec_nc.tif"))

sf_rbs_w_prec <- terra::extract(x = spr_prec_nc,
                               y = sf_rbs,
                               bind = TRUE) %>% 
  st_as_sf()


#Mapping 
ggplot() +
  geom_spatraster(data = spr_prec_nc) +
  geom_sf(data = sf_rbs_w_prec,
          aes(color = factor(y))) +
  scale_fill_viridis_c()

#Statistical Analysis 
#Draw a figure relating fish presence/absence to Precipitation 
df_rbs_w_prec <- as_tibble(sf_rbs_w_prec)

df_rbs_w_prec %>% 
  ggplot(aes(x = precipitation,
             y = y)) +
  geom_point() +
  theme_bw() 

m_rbs <- glm(y ~ precipitation,
             data = df_rbs_w_prec,
             family = "binomial")  

summary(m_rbs) 

#Draw a predicted Line 
df_pred <- ggpredict(m_rbs, terms = "precipitation [all]")
df_pred

ggplot() +
  geom_point(data = df_rbs_w_prec,
             aes(x = precipitation,
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
  labs(x = "Precipitation",
       y = "Probability of occurrence")


