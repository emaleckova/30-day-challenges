library(dplyr)

library(ggplot2)
library(scales)
library(gridExtra)

# Load preprocessed data
load("data/preprocessed_internet_users.RData")

# color scale by continent - as in the Internet data
continent_colors <- c(c("Africa" = "#524595", "Asia" = "#0392cf",
                        "Europe" = "#e86af0", "North America" = "#ffbf00",
                        "Oceania" = "#95CA3E", "South America" = "#F26923"))

# Population data has both Americas together
continent_colors_merged <- c(c("Africa" = "#524595", "Asia" = "#0392cf",
                        "Europe" = "#e86af0", "Americas" = "#a7882e",
                        "Oceania" = "#95CA3E"))

### USERS BY THE END OF EACH DECADE
# =================================

# For number of user at a given decade, take last year of the decade
decade_data <- internet_users_by_continent |>
  # first meaningful data start in 1990s -> keep only those and later
  filter(year %in% c(1999, 2009, 2019, 2021)) |>
  group_by(year) |> 
  arrange(number_of_internet_users) |> 
  mutate(decade = floor(year / 10) * 10)


### ABSOLUTE NUMBERS
# ------------------

p_ls <- list()

for (d in sort(unique(decade_data$decade))) {
  input <- filter(decade_data, decade == d)
  
  p <- ggplot(input, aes(x = reorder(entity, number_of_internet_users), y = number_of_internet_users, group = entity)) +
    geom_col(aes(fill = entity), position = "dodge") +
    scale_fill_manual(values = continent_colors) +
    scale_y_continuous(labels = ifelse(max(input$number_of_internet_users > 1e9), label_number(scale = 1e-9, suffix = " B"),
                                  label_number(scale = 1e-6, suffix = " M")),
                                expand = c(0, 0)) +
    labs(title = paste0(d, "s")) +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5, vjust = 1, face = "bold"),
          axis.title = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
          aspect.ratio = 0.65,
          legend.position = "none")
  
  p_ls[[as.character(d)]] <- p
}

# export
ggsave(plot = grid.arrange(grobs = p_ls, nrow = 1, top = "Number of Internet Users \n at the End of Each Decade and in 2021"),
      filename = "plots/05-Ranking-Absolute.png", width = 7, height = 4)

### PERCENTAGE OF POPULATION
# --------------------------

# For population, take last year of the decade
load("data/preprocessed_population.RData")

population_decades <- population_by_continent |>
  filter(year %in% c(1999, 2009, 2019, 2021)) |>
  mutate(decade = floor(year / 10) * 10)

decade_data <- decade_data |> 
  mutate(entity = case_when(
    grepl("America", entity) ~ "Americas",
    TRUE ~ entity)) |> 
  # Americas must be summer up
  group_by(entity, decade) |>
  summarise(number_of_internet_users = sum(number_of_internet_users))

decade_data_pop <- merge.data.frame(decade_data, population_decades, by = c("decade", "entity"))
# percentage of continent's population with internet users
decade_data_pop$prcnt <- decade_data_pop$number_of_internet_users / decade_data_pop$all_years

p_ls <- list()

for (d in sort(unique(decade_data_pop$decade))) {
  input <- filter(decade_data_pop, decade == d)
  
  p <- ggplot(input, aes(x = reorder(entity, prcnt), y = prcnt, group = entity)) +
    geom_col(aes(fill = entity), position = "dodge") +
    scale_fill_manual(values = continent_colors_merged) +
    geom_text(aes(x = entity, y = ifelse(prcnt > 0.05, prcnt + 0.05, 0.05), label = paste0(round(prcnt * 100, 0), "%")),
                  position = position_dodge(width = 0.5), size = 3) +
    scale_y_continuous(expand = c(0, 0), limits = c(0, max(input$prcnt) * 1.25)) +
    labs(title = paste0(d, "s")) +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5, vjust = 1, face = "bold"),
          axis.title = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
          axis.ticks.y = element_blank(),
          axis.line.y = element_blank(),
          axis.text.y = element_blank(),
          aspect.ratio = 0.65,
          legend.position = "none")
  
  p_ls[[as.character(d)]] <- p
}

# export
ggsave(plot = grid.arrange(grobs = p_ls, nrow = 1, top = "Population with Internet Access \n at the End of Each Decade and in 2021"),
      filename = "plots/05-Ranking-Percentage.png", width = 7, height = 4)