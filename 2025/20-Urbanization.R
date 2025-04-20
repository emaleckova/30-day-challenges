# Packages
library(dplyr)
library(janitor)

library(ggplot2)
library(ggrepel)
library(scales)
library(ggtext)
library(glue)
library(ggpubr)
library(gridExtra)

# Load data
all_data <- read.delim("data/urban-share-european-commission/urban-share-european-commission.csv", sep = ",", header = T)
all_data <- clean_names(all_data)
# make percentages fractions between 0 and 1 -> nice axis labels with {scales} package
all_data$share_of_population_living_in_urban_areas <- all_data$share_of_population_living_in_urban_areas / 100

# Keep only years with data
past_data <- all_data[all_data$year < 2025, ]

# Explore data
summary(past_data)

sort(unique(past_data$entity))

### PLOTS
continents <- c("Africa", "Asia", "Europe", "North America", "South America", "Oceania")

continent_colors <- c(c("Africa" = "#524595", "Asia" = "#0392cf",
                        "Europe" = "#e86af0", "North America" = "#ffbf00",
                        "Oceania" = "#95CA3E", "South America" = "#F26923"))

# World - continents
global_trend <- past_data |> 
  filter(entity %in% continents) |> 
  group_by(year) |> 
  summarise(global_urban = mean(share_of_population_living_in_urban_areas, na.rm = TRUE))
# for plot label later on
max_global <- max(global_trend$global_urban)

# Plot
p_world <- ggplot() +
  # individual continents
  geom_line(data = filter(past_data, entity %in% continents),
            aes(x = year, y = share_of_population_living_in_urban_areas, colour = entity), linewidth = 1) +
  scale_colour_manual(values = continent_colors) +
    # global trend line (smooth)
  geom_smooth(data = global_trend, aes(x = year, y = global_urban),
              color = "grey30", se = F, linewidth = 1.2) +
  # annotate - global
  geom_text_repel(data = global_trend[nrow(global_trend), ], aes(x = 2020, y = global_urban, label = "World"),
                  color = "grey30", size = 4, nudge_x = 8, nudge_y = 0.005,
                  xlim = c(2021, NA), segment.size = 0.75, segment.linetype = "dotted", fontface = "bold") +
  # annotate - continents
  geom_text_repel(data = filter(past_data, entity %in% continents, year == 2020),
                aes(x = 2020, y = share_of_population_living_in_urban_areas, label = entity,
                color = entity), size = 4, nudge_x = 10, nudge_y = -0.01,
                xlim = c(2024, NA), segment.size = 0.75, segment.linetype = "dotted",
                segment.ncp = 4,
                box.padding = 0.4,
                segment.curvature = -0.2,
                segment.angle = 45) +
  scale_x_continuous(expand = c(0, 0), limits = c(1975, 2040), breaks = seq(1970, 2020, 10)) +
  scale_y_continuous(labels = scales::label_percent(), expand = c(0, 0),
                    limits = c(0.55, 0.85), breaks = seq(0.55, 0.85, 0.05)) +
  labs(title = "Urbanization development across continents \nand the global trend",
       x = "Year",
       y = "Population in urban areas") +
  theme_classic() +
  theme(plot.title = element_text(size = 12, face = "bold", hjust = 0),
        legend.position = "none",
        aspect.ratio = 0.65)

# Identify least and fastest growing countries
# 1. Calculate slope for each entity
# Do not inlcude world and per-contine tdata
slopes <- past_data |> 
  filter(entity != "World", !entity %in% continents) |>
  group_by(entity) |> 
  summarise(slope = coef(lm(share_of_population_living_in_urban_areas ~ year))[2])

# 2. Identify least and fastest growing countries
fastest_growing <- slopes |> 
  top_n(3, slope) |>
  pull(entity)

# sorting will ensure consistenty of order/colours in title and geom_line()
fastest_growing <- sort(fastest_growing)

least_growing <- slopes |> 
  top_n(3, -slope) |>
  pull(entity)
least_growing <- sort(least_growing)

col_fastest <- c("#E07529FF", "#FAAE32FF", "#7F7991FF")
names(col_fastest) <- fastest_growing

fastest_title <- glue("<span style = 'color: {col_fastest[1]}'> Cayman Islands </span>,
  <span style = 'color: {col_fastest[2]}'> Saint Barthelemy </span> and <br>
  <span style = 'color: {col_fastest[3]}'> Turks and Caicos Islands </span> <br>
  have seen the fastest growth in urbanization")

p_growth <- ggplot() +
  geom_line(data = filter(past_data, entity %in% fastest_growing),
            aes(x = year, y = share_of_population_living_in_urban_areas, colour = entity), linewidth = 1.5) +
  scale_colour_manual(values = col_fastest) +
  scale_x_continuous(expand = c(0, 0), limits = c(1975, 2025), breaks = seq(1970, 2020, 10)) +
  scale_y_continuous(labels = scales::label_percent(), limits = c(0, 1),  expand = c(0, 0)) +
  labs(title = fastest_title,
    x = "Year",
    y = "Population in urban areas") +
  theme_classic() +
  theme(plot.title = element_markdown(size = 12, hjust = 0, face = "bold"),
        legend.position = "none",
        aspect.ratio = 0.65) +
    # add explanatory text
    geom_curve(aes(x = 2006, y = 0.75, xend = 2001, yend = 0.8),
              arrow = arrow(length = unit(0.2, "cm"), type = "open"), curvature = 0.3) +
    geom_curve(aes(x = 2006, y = 0.7, xend = 2003, yend = 0.3),
              arrow = arrow(length = unit(0.2, "cm"), type = "open"), curvature = 0.3) +
    annotate("text", x = 2010, y = 0.73, label = "boom of tourism")
  

col_least <- c("#A84A00FF", "#5D4F36FF", "#B39085FF")
names(col_least) <- least_growing

slowest_title <- glue("<span style = 'color: {col_least[1]}'> Montserrat </span>,
  <span style = 'color: {col_least[2]}'> Palau </span> and <br>
  <span style = 'color: {col_least[3]}'> Saint Pierre and Miquelon </span> <br>
  have seen marked drops in urbanization")

p_decline <- ggplot() +
  geom_line(data = filter(past_data, entity %in% least_growing),
            aes(x = year, y = share_of_population_living_in_urban_areas, color = entity), linewidth = 1.5) +
  scale_colour_manual(values = col_least) +
  scale_x_continuous(expand = c(0, 0), limits = c(1975, 2025), breaks = seq(1970, 2020, 10)) +
  scale_y_continuous(labels = scales::label_percent(), limits = c(0, 1),  expand = c(0, 0)) +
  labs(title = slowest_title,
    x = "Year",
    y = "Population in urban areas") +
  theme_classic() +
  theme(plot.title = element_markdown(size = 12, hjust = 0, face = "bold"),
        legend.position = "none",
        aspect.ratio = 0.65) +
  # add explanatory text
  geom_curve(aes(x = 2001, y = 0.9, xend = 1997, yend = 0.85),
            arrow = arrow(length = unit(0.2, "cm"), type = "open"), curvature = 0.3) +
  annotate("text", x = 1999, y = 0.78, colour = "#A84A00FF",
          label = "1997: Soufrière Hills volcano \n eruption destroyed \n the capital city Plymouth",
          hjust = 0)
  
# combine for export
p_combined <- ggarrange(
  ggarrange(p_world, arrangeGrob(p_growth, p_decline, ncol = 2), nrow = 2, widths = c(1, 1)),
  ncol = 2,
  widths = c(10, 2),
  heights = c(1, 2)
)

p_combined

ggsave(p_combined, filename = "plots/20-Urbanization.png",
       width = 8, height = 6, scale = 1.5, bg = "white")
