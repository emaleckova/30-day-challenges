library(dplyr)
library(lubridate)

library(ggplot2)
library(scales)
library(gridExtra)

# Load preprocessed data
load("data/preprocessed_internet_users.RData")

# By decade
decade_data <- internet_users_by_continent |>
  mutate(decade = floor(year / 10) * 10) |> 
  group_by(decade, entity) |>
  # first meaningful data start in 1990s -> keep only those and later
  filter(year >= 1990) |>
  summarise(total_users = sum(number_of_internet_users)) |>
  group_by(decade) |> 
  arrange(total_users)

p_ls <- list()

for (d in unique(decade_data$decade)) {
  input <- filter(decade_data, decade == d)
  
  p <- ggplot(input, aes(x = reorder(entity, total_users), y = total_users, group = entity)) +
    geom_col(aes(fill = entity), position = "dodge") +
    scale_y_continuous(labels = ifelse(max(input$total_users > 1e9), label_number(scale = 1e-9, suffix = " B"),
                                  label_number(scale = 1e-6, suffix = " M")),
                                expand = c(0, 0)) +
    labs(title = paste0(d, "s")) +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5),
          axis.title = element_blank(),
          axis.ticks.x = element_blank(),
          aspect.ratio = 0.65,
          legend.position = "none")
  
  p_ls[[as.character(d)]] <- p
}

grid.arrange(grobs = p_ls, nrow = 1)
