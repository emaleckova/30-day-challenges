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
internet_users_by_continent <- internet_users |> 
  filter(entity %in% c("Africa", "Asia", "Europe", "North America", "South America", "Australia"))

# 4. European Union
internet_users_eu <- internet_users |>
  filter(grepl("European Union", entity))

# 5. By country
internet_users_by_country <- internet_users |> 
  filter(!entity %in% c("World", unique(c(internet_users_by_income$entity, internet_users_by_continent$entity, internet_users_eu$entity))))

# Check for completness of data
nrow(global_internet_users) + nrow(internet_users_by_income) + nrow(internet_users_by_continent) +
  nrow(internet_users_eu) + nrow(internet_users_by_country) == nrow(internet_users)

save(global_internet_users, internet_users_by_income, internet_users_by_continent,
  internet_users_eu, internet_users_by_country,
  file = "data/preprocessed_internet_users.RData")
