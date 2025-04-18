library(dplyr)
library(janitor)

library(ggplot2)
library(ggtext)
library(glue)
library(paletteer)
library(ggpubr)
library(gridExtra)

occurences <- read.delim("data/data-gov/ROMOFish_TroutData_Occurrence.csv", sep = ",", header = TRUE)
occurences <- clean_names(occurences)

### PREPROCESS DATA

# Assign year of observation
occurences$year <- case_when(
  grepl("-2021", occurences$event_id) ~ "2021",
  grepl("-2022", occurences$event_id) ~ "2022",
  TRUE ~ NA
)
# check
sum(is.na(occurences$year)) == 0

occurences[is.na(occurences$scientific_name), ] # all observation without species are in a single year but very few -> drop them
occurences <- occurences[!is.na(occurences$scientific_name), ]

### Polis scientific names
# remove the scitnitis, year part
occurences$scientific_name <- gsub("\\s*\\(.*?\\)", "", occurences$scientific_name)

# there is a type for S. fontinalis in year 2022 -> unify spelling
occurences$scientific_name[occurences$scientific_name == "Salvelinus fontilis"] <- "Salvelinus fontinalis"

### PLOTS

theme_set(
  theme_classic() +
  theme(
    text = element_text(size = 14),
    axis.text = element_text(size = 14)
  )
)

# 1. Observations by species and year
occurences_counts <- occurences |>
  group_by(scientific_name, year) |>
  summarise(n_individuals = n())

# create colour scales by species and year
col_species <- paletteer_d("Manu::Kereru")
names(col_species) <- unique(sort(occurences_counts$scientific_name))

col_years <- c("2021" = "#E35205FF", "2022" = "#5C88DAFF")

# Trout counts by species and year
p_species <- ggplot(occurences_counts, aes(x = year, y = n_individuals, colour = scientific_name)) +
  geom_jitter(aes(size = n_individuals),
    position = position_jitter(width = 0.15, seed = 123)
  ) +
  geom_line(aes(group = scientific_name, colour = scientific_name),
    position = position_jitter(width = 0.15, seed = 123)
  ) +
  scale_y_continuous(limits = c(0, 1050), expand = c(0, 0)) +
  scale_size(range = c(1, 5), guide = "none") +
  scale_colour_manual(values = col_species, name = "Species") +
  labs(
    x = "Year",
    y = "Observations"
  ) +
  guides(colour = guide_legend(ncol = 2)) +
  theme_classic() +
  theme(
    axis.title = element_text(face = "bold"),
    axis.ticks.x = element_blank(),
    legend.title = element_text(face = "bold"),
    legend.text = element_text(size = 10, face = "italic"),
    legend.position = "bottom",
    aspect.ratio = 1.5
  )

# Comparison between years makes sense only if there were spotting on both years
species_subset <- unique(occurences_counts[occurences_counts$year == "2022" & occurences_counts$n_individuals > 0, ]$scientific_name)

# A joint plot for both fish weight and length
plot_title <- glue('Weight and Length of Selected Trout Species In Years <span style = "color:{col_years["2021"]}"> 2021 </span>
  and <span style = "color:{col_years["2022"]}"> 2022 </span>')

p_title <- ggplot() +
  geom_blank() +
  labs(
    title = plot_title,
    subtitle = "(Rocky Mountain National Park, USA)"
  ) +
  theme(
    plot.background = element_rect(fill = "white"),
    plot.title = element_markdown(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 14, face = "bold", hjust = 0.5),
    aspect.ratio = 0.15
  )

p_mass <- ggplot(
  filter(occurences, scientific_name %in% species_subset),
  aes(x = mass)
) +
  geom_density(aes(fill = year), alpha = 0.65) +
  facet_wrap(~scientific_name) +
  scale_fill_manual(values = col_years) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  labs(
    x = "weight [g]"
  ) +
  theme_classic() +
  theme(
    panel.background = element_rect(fill = "white"),
    strip.background = element_blank(),
    strip.text = element_text(face = "bold.italic", size = 11),
    axis.title = element_text(face = "bold"),
    legend.position = "none"
  )

p_length <- ggplot(
  filter(occurences, scientific_name %in% species_subset),
  aes(x = length)
) +
  geom_density(aes(fill = year), alpha = 0.65) +
  facet_wrap(~scientific_name) +
  scale_fill_manual(values = col_years) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = "length [mm]") +
  theme_classic() +
  theme(
    panel.background = element_rect(fill = "white"),
    strip.background = element_blank(),
    strip.text = element_text(face = "bold.italic", size = 11),
    axis.title = element_text(face = "bold"),
    legend.position = "none"
  )

# combine for export
p_combined <- ggarrange(
  p_title,
  ggarrange(p_species, arrangeGrob(p_mass, p_length, ncol = 1), ncol = 2, heights = c(1, 1)),
  ncol = 1,
  heights = c(0.1, 0.9)
)

p_combined

ggsave(p_combined, filename = "plots/12-data-gov.png", width = 8, height = 7, scale = 1.15, bg = "white")
