library(janitor)
library(dplyr)

internet_users <- read.delim("data/number-of-internet-users.csv", sep = ",")
internet_users <- clean_names(internet_users)

global_internet_users <- internet_users |> 
  filter(entity == "World")

save(global_internet_users, file = "data/preprocessed_internet_users.RData")
