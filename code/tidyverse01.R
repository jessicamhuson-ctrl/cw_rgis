
if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse)

set.seed(123)

iris_sub <- as_tibble(iris) %>% 
  group_by(Species) %>% 
  sample_n(3) %>% 
  ungroup()

print(iris_sub)

#ROW MANIPULATION/SUBSET ROWS/SINGLE MATCH 
filter(iris_sub, Species == "virginica")

#MULTIPLE MATCH 
filter(iris_sub, Species %in% c("virginica", "versicolor"))

#EXCEPT 
filter(iris_sub, Species != "virginica")

#EXCEPT MULTIPLE 
filter(iris_sub, !(Species %in% c("virginica", "versicolor")))

#GREATER THAN 
filter(iris_sub, Sepal.Length > 5)

#GREATER THAN AND EQUAL TO 
filter(iris_sub, Sepal.Length >= 5)

#LESS THAN
filter(iris_sub, Sepal.Length < 5)

#LESS THAN AND EQUAL TO 
filter(iris_sub, Sepal.Length <= 5)

#MULTIPLE CONDITIONS (AND)/ Sepal.Length is less than 5 AND Species equals "setosa"
filter(iris_sub,
       Sepal.Length < 5 & Species == "setosa")

# same; "," works like "&"
filter(iris_sub,
       Sepal.Length < 5, Species == "setosa")

#MULTIPLE CONDITIONS(OR)/ Either Sepal.Length is less than 5 OR Species equals "setosa"
filter(iris_sub,
       Sepal.Length < 5 | Species == "setosa")

#ARRANGE ROWS/INCREASING/ASCENDING ORDER
arrange(iris_sub, Sepal.Length)

#DECREASING/DESCENDING ORDER
arrange(iris_sub, desc(Sepal.Length))

#COLUMN MANIPLUATION/SELECT ONE COLUMN
select(iris_sub, Sepal.Length)

#SELECT MULTIPLE COLUMNS
select(iris_sub, c(Sepal.Length, Sepal.Width))

#REMOVE ONE COLUMN
select(iris_sub, -Sepal.Length)

#REMOVE MULTIPLE COLUMNS
select(iris_sub, -c(Sepal.Length, Sepal.Width))

#SELECT/REMOVE WITH.. select columns starting with "Sepal"
select(iris_sub, starts_with("Sepal"))

# remove columns starting with "Sepal"
select(iris_sub, -starts_with("Sepal"))

#SELECT WITH.. select columns ending with "Sepal"
select(iris_sub, ends_with("Width"))

# remove columns ending with "Sepal"
select(iris_sub, -ends_with("Width"))

#ADD COLUMNS SECTION
# nrow() returns the number of rows of the dataframe
(x_max <- nrow(iris_sub))

# create a vector from 1 to x_max
x <- 1:x_max

# add as a new column
# named `x` as `row_id` when added
mutate(iris_sub, row_id = x)

#MODIFY AN EXISTING COLUMN/ twice `Sepal.Length` and add as a new column
mutate(iris_sub, sl_two_times = 2 * Sepal.Length)

#PIPING... Allows sequential operations of multiple functions %>% (hot key: Ctr + Shift + M)
df_vir <- filter(iris_sub, Species == "virginica")
df_vir_sl <- select(df_vir, Sepal.Length)

print(df_vir_sl)
#WITH PIPING THIS ABOVE EX BECOMES...

df_vir_sl <- iris_sub %>% 
  filter(Species == "virginica") %>% 
  select(Sepal.Length)

print(df_vir_sl)

#CLASS EXAMPLE 
iris_setosa <- filter(iris_sub, Species  == "setosa")

iris_num <- select(iris_setosa, -Species) 

iris_sub %>% 
  filter(Species == "setosa")

iris_sub %>% 
  filter(Species == "setosa") %>% 
  select(-Species)

#EXCERSCISE 
#Excercise 1 filter 'iris_sub' to contain only 'virginica'
filter(iris_sub, Species == "Virginica")
#Exercise 2 select column  "Sepal.Width" in "iris_sub" 
select(iris_sub, Sepal.Width)
#Exercise 3 filter "iris_sub" to contain only "virginica", then pipe to select "Sepal.Width", then pipe to create a new column "sw3that is a triple of values in Sepal.Width, assign to df0
df0 <- iris_sub %>% 
  filter(Species == "virginica") %>% 
  select(Sepal.Width) %>% 
  mutate(sw3 = 3 * Sepal.Width)
df0

#GROUP OPERATION 
#Calculate mean 
m <- mean(c(2,5,8))
s <- sum(c(2,5,8))
m_large <- mean(1:1000)
s_large <- sum(1:1000) 

mean(iris_sub$Sepal.Length)

#GROUP_BY()FUNCTION
df_summary <- iris_sub %>% 
  group_by(Species) %>% 
  summarize(mean_sl = mean(Sepal.Length), 
            sum_sl = sum(Sepal.Length),
            mean_pl = mean(Petal.Length),
            sum_pl = sum(Petal.Length))

#Join 
df1 <- tibble(Species = c("A", "B", "C"), 
       x = c(1, 2, 3))
df2 <- tibble(Species = c("A", "B", "C"), 
       y = c(10, 12, 13))

left_join(x = df1, 
          y = df2,
          by = "Species")

df2_minus_c <- tibble(Species = c("A", "B"),
                      y = c(10, 12))

left_join(x = df1,
          y = df2_minus_c,
          by = "Species")
