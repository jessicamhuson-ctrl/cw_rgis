#Going over how to use ggplot 

pacman::p_load(tidyverse)
ggplot(data = iris,
       mapping = aes(x = Sepal.Length,
                     y = Sepal.Width))
#Does not show data, need to add layer to plot points 

ggplot(data = iris,
       mapping = aes(x = Sepal.Length,
                     y = Sepal.Width)) +
  geom_point()

#It needs to be named now 

g_point <- ggplot(data = iris,
       mapping = aes(x = Sepal.Length,
                     y = Sepal.Width)) +
  geom_point()

#Now try to write this code out with pipe 

iris %>% 
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width)) +
  geom_point()

#Create a color plot by grouping in ggplot 

g_point_col <- iris %>% 
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width,
             color = Species)) + 
  geom_point()

iris %>% 
  ggplot(aes(x = Sepal.Length,
             y = Sepal.Width),
         color = Species) +
  geom_point()
#One can see that this code above does not have color 

iris %>% 
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width)) +
  geom_point(color = "tomato")
#Now everything becomes tomato color 

#Now going through how to create a line plot 
tibble(x = 1:50,
       y = 2 * x)
#make sure to name 
df0 <- tibble(x = 1:50,
              y = 2 * x)

df0 %>% 
  ggplot(aes(x = x,
             y = y)) +
  geom_line()

#Can add multiple layers 
df0 %>% 
  ggplot(aes(x = x,
             y = y)) +
  geom_line() + 
  geom_point()

#Histogram 
iris %>% 
  ggplot(aes(x = Sepal.Length)) +
  geom_histogram()

#Boxplot 
iris %>% 
  ggplot(aes(x = Species, 
             y = Sepal.Length)) +
  geom_boxplot()

##Change the fill of box plot 
iris %>% 
  ggplot(aes(x = Species,
             y = Sepal.Length,
             color = Species)) +
  geom_boxplot()

iris %>% 
  ggplot(aes(x = Species,
             y = Sepal.Length,
             fill = Species)) +
  geom_boxplot()

#Excersize 
g_petal <- iris %>% 
  ggplot(aes(x = Petal.Width,
         y = Petal.Length)) +
  geom_point()

g_petal_box <- iris %>% 
  ggplot(aes(x = Species,
             y = Petal.Length, 
             fill = Species)) +
  geom_boxplot()

g_petal_box + 
  geom_point()

#Change Axes' titles 
g_petal_box + 
  labs(x = "Plant species",
       y = "Petal length")


#Excersize 

mtcars

df_mtcars <- as_tibble(mtcars)

#select rows where cyl is 4
filter(df_mtcars, cyl == 4)

#Select columns mpg, cyl, disp, wt, vs, carb
select(df_mtcars, 
       c(mpg, cyl, disp, wt, vs, carb))

#Select rows where cyl is greater than 4, then select columns of mpg, cyl, disp, wt, vs, carb.   Assign the output to 'df_sub'
df_sub <- df_mtcars %>% 
  filter(cyl > 4 ) %>% 
  select(mpg, cyl, disp, wt, vs, carb)

#Type code and run 
v_car <- rownames(mtcars)


#Add a new column called "car" to df_mtcars, then reassign it to "df_mtcars" 
df_mtcars <- mutate(df_mtcars, 
                    car = v_car)

#Identify the lightest car with cyl = 8 
df_mtcars %>% 
  filter(cyl == 8) %>% 
  arrange(wt)

#Calculate the average weight (wt) of cars within each group of gear numbers, consider using group_by() function and summarize() function, assign to 'df_mean' 
df_mean <- df_mtcars %>% 
  group_by(gear) %>% 
  summarize(mu = mean(wt))

#Combination of dplyr operations with ggplot 
df_mtcars %>% 
  ggplot(aes(x = wt,
             y = qsec)) +
  geom_point()

#Use above code to draw figure between wt and qsec, but only those with cyl = 6 
df_mtcars %>% 
  filter(cyl ==6) %>% 
  ggplot(aes(x = wt,
             y = qsec)) +
  geom_point()

# Draw a figure between mean wt and mean qsec for each group of gear
df_mtcars %>% 
  group_by(gear) %>% 
  summarize(mu_wt = mean(wt),
            mu_qsec = mean(qsec)) %>% 
  ggplot(aes(x = mu_wt,
             y = mu_qsec)) +
  geom_point()
