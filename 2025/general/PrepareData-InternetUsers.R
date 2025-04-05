library(janitor)
library(dplyr)

internet_users <- read.delim("data/number-of-internet-users.csv", sep = ",")
internet_users <- clean_names(internet_users)

### Break down by various aspects:

# 1. World
global_internet_users <- internet_users |> 
  filter(entity == "World")

# 2. By income
internet_users_by_income <- internet_users |> 
  filter(grepl("income", entity))

# 3. By continent
continents <- c("Africa", "Asia", "Europe", "North America", "South America", "Oceania")

internet_users_by_continent <- internet_users |> 
  filter(entity %in% continents)

# 4. European Union
internet_users_eu <- internet_users |>
  filter(grepl("European Union", entity))

# 5. By country
internet_users_by_country <- internet_users |> 
  filter(!entity %in% c("World", unique(c(internet_users_by_income$entity, internet_users_eu$entity), continents[continents != "Australia"])))

save(global_internet_users, internet_users_by_income, internet_users_by_continent,
  internet_users_eu, internet_users_by_country,
  file = "data/preprocessed_internet_users.RData")
