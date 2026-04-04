# ABOUT DATA:
# Source: UN Data - https://data.un.org/
# Original file name: SYB61_253_Population_Growth_Rates_in Urban areas and Capital cities.csv

library(dplyr)
library(janitor)
library(stringr)

raw_pop <- read.delim("2026/data/SYB61_253_Population_Growth_Rates.csv", sep = ",", skip = 1, header = T)
# friendly column names
raw_pop <- janitor::clean_names(raw_pop)

glimpse(raw_pop)

# meaningful name for the missing one
colnames(raw_pop)[colnames(raw_pop) == "x"] <- "region"

# reduce notes and other repetitive data
prepro_pop <- raw_pop |> 
  select(-capital_city_footnote, -footnotes, -source)

# isolate units
unique(prepro_pop$series)

prepro_pop <- prepro_pop |> 
  mutate(pop_unit = gsub(" [(]|[)]", "", str_extract(string = series, pattern = " [(](.*?)[)]"))) |> 
  # also clean up population type
  mutate(pop_type = gsub(" [(](.*?)[)]", "", series)) |> 
  mutate(value = as.numeric(value)) |> 
  select(-series)

glimpse(prepro_pop)
summary(prepro_pop)

save(prepro_pop, file = "2026/data/preprocessed/SYB61_253_Population_Growth_Rates.RData")
