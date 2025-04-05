library(janitor)
library(dplyr)

population_dat <- read.delim("data/population.csv", sep = ",")
population_dat <- clean_names(population_dat)

### Break down by various aspects:

# By continent
population_by_continent <- population_dat |> 
  filter(grepl("UN", entity)) |> 
  filter(!grepl("Latin America|Northern America", entity)) |> 
  mutate(entity = gsub(" \\(UN\\)", "", entity))

save(population_by_continent,
  file = "data/preprocessed_population.RData")
