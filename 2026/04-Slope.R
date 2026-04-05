# SETUP ------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

# Preprocessed dataset - loaded as 'prepro_pop'
load("2026/data/preprocessed/SYB61_253_Population_Growth_Rates.RData")

# Packages
library(dplyr)
library(rnaturalearth)

library(ggplot2)
library(ggrepel)
library(scales)
library(cowplot)
library(gridtext)

# Author details fxn
source("commons/CreateSocialCaption.R")


# SUBSET DATA: European countries ----------------------------------------------
# ---------------------------------------------------------------------------- #

# World data will be source of all European countries
world_map <- ne_countries(scale = 50, returnclass = "sf")
glimpse(world_map)

ecountries <- world_map |>
  filter(continent == "Europe") |>
  pull(sovereignt)

acountries <- world_map |>
  filter(continent == "Africa") |>
  pull(sovereignt)

# How many are present in the population data?
length(ecountries)

length(intersect(ecountries, unique(prepro_pop$region)))
setdiff(ecountries, unique(prepro_pop$region))

# This is a manual step for as complete dataset as possible
# Kosovo is missing in population growth data
# Moldova is Republic of Moldova, Republic of Serbia is Serbia, North Macedonia is TFYR of Macedonia
# Vatican City is a capital of Holy See - since it has only a single observation, it will not be included

# Update countries vector for filtering
ecountries <- c(ecountries, "Moldova", "Republic of Serbia", "TFYR of Macedonia")

length(acountries)

length(intersect(acountries, unique(prepro_pop$region)))
setdiff(acountries, unique(prepro_pop$region))

acountries <- c(
  acountries,
  "United Rep. of Tanzania", "Eswatini", "Somalia", "Sao Tome and Principe",
  "Dem. Rep. of the Congo", "Congo"
)

# Filtering for both continents
eur_pop <- prepro_pop |>
  filter(region %in% ecountries)

n_distinct(eur_pop$region)

urban_pop <- eur_pop |>
  filter(
    pop_type == "Urban population",
    pop_unit == "percent"
  ) |>
  # keep entries with min. 2 time points
  group_by(region) |>
  mutate(n_records = n()) |>
  filter(n_records >= 2) |>
  select(-n_records)

afr_pop <- prepro_pop |>
  filter(region %in% acountries)

n_distinct(afr_pop$region)

urban_pop_a <- afr_pop |>
  filter(
    pop_type == "Urban population",
    pop_unit == "percent"
  ) |>
  # keep entries with min. 2 time points
  group_by(region) |>
  mutate(n_records = n()) |>
  filter(n_records >= 2) |>
  select(-n_records)


# PLOT changes Europe vs Africa ------------------------------------------------
# ---------------------------------------------------------------------------- #

# --- Europe ---

# countires with change of min. 10%
e_tops <- urban_pop |>
  tidyr::pivot_wider(id_cols = "region", values_from = "value", names_from = "year") |>
  mutate(growth = `2018` - `2005`) |>
  filter(growth >= 10) |>
  pull(region)

# Isolate top growers and top in 2018 into a separate data frame -> access to labels
df_e_tops <- urban_pop |>
  filter(region %in% e_tops, year == 2018)

# Continent shape
# Including some filtering and cropping to keep "known" shape
bg_eur <- world_map |>
  filter(continent == "Europe", sovereignt != "Russia") |>
  ggplot() +
  geom_sf(fill = "#fcbf49", colour = NA, alpha = 0.25) +
  # labs(caption = paste("**Data source:** unstats.un.org", "**|**", CreateSocialCaption())) +
  scale_x_continuous(limits = c(-10, 40)) +
  scale_y_continuous(limits = c(35, 80)) +
  theme_void() +
  theme(plot.caption = ggtext::element_markdown(),
        aspect.ratio = 0.75)

p_eur <- ggplot(urban_pop, aes(x = year, y = value / 100, group = region)) +
  geom_line(colour = "grey80", alpha = 0.6, linewidth = 0.35) +
  # max and min
  geom_line(data = filter(urban_pop, region == "Liechtenstein"), colour = "#003DA5", linewidth = 0.5) +
  geom_text(
    data = filter(urban_pop, region == "Liechtenstein", year == 2018),
    label = "Liechtenstein", colour = "#003DA5",
    nudge_x = 0.2, hjust = 0, size = 3
  ) +
  geom_line(data = filter(urban_pop, region == "Belgium"), colour = "#C8102E", linewidth = 0.5) +
  geom_text(
    data = filter(urban_pop, region == "Belgium", year == 2018),
    label = "Belgium", colour = "#C8102E",
    nudge_x = 0.2, hjust = 0, size = 3
  ) +
  # growth above 10%
  geom_line(data = filter(urban_pop, region %in% e_tops), colour = "black", linewidth = 0.5) +
  geom_text(
    data = filter(urban_pop, region %in% e_tops, year == 2018),
    aes(label = region), colour = "black",
    nudge_x = 0.2, hjust = 0, size = 3
  ) +
  coord_cartesian(xlim = c(2005, 2018), ylim = c(0.1, 1), expand = F, clip = "off") +
  scale_x_continuous(breaks = unique(urban_pop$year)) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    x = "year",
    y = "urban population"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.margin = margin(0, 80, 0, 0),
    plot.background = element_rect(fill = NA),
    panel.background = element_rect(fill = NA),
    panel.grid = element_blank(),
    plot.caption = ggtext::element_markdown(),
    axis.title = element_text(colour = "black"),
    axis.text = element_text(colour = "black"),
    axis.line = element_line(colour = "black"),
    axis.ticks = element_line(colour = "black", linewidth = 0.5),
    axis.ticks.length = unit(-5, "pt"),
    aspect.ratio = 0.75
  )

# Align plots
aligned_plots <- align_patches(bg_eur, p_eur)

# Draw them in order and fine tune alignment
p <- cowplot::ggdraw(aligned_plots[[1]])
p_eur_assembled <- p + cowplot::draw_plot(aligned_plots[[2]], valign = 0.2, scale = 1)

p_title <- ggdraw() +
  draw_label(
    stringr::str_wrap(
      "A single European country experienced >10 percentage points increase in urban population between 2005 and 2018",
      width = 60
      ),
    fontface = 'bold',
    size = 11,
    x = 0.5
  )

# Include the title to arranged plot assemblies
p_final <- plot_grid(p_title, p_eur_assembled, ncol = 1, rel_heights = c(0.05, 0.9))
# And a caption-like data & author note
p_final_png <- ggdraw(p_final) +
  draw_grob(
    gridtext::richtext_grob(
      paste("**Data source:** unstats.un.org", "<br>", CreateSocialCaption()),
      gp = grid::gpar(fontsize = 10),
      x = 0.5,
      hjust = 0.5,
      vjust = 7, use_markdown = T
    )
  )

print(p_final_png)

# https://stackoverflow.com/questions/75020376/save-plot-exactly-as-previewed-in-the-plots-panel
# Create a temporary file
tmp <- tempfile()

# Put the current plot into the tempfile in the svg format
dev.print(svg,tmp)

# Convert the svg temp file to png and store it in a png file
rsvg::rsvg_png(tmp, "2026/plots/04-Slope.png", height = 800, width = 900)


# # --- Africa ---
#
# a_tops <- urban_pop_a |>
#   tidyr::pivot_wider(id_cols = "region", values_from = "value", names_from = "year") |>
#   mutate(growth = `2018` - `2005`) |>
#   filter(growth >= 10) |>
#   pull(region)
#
# df_a_tops <- urban_pop |>
#   filter(region %in% a_tops, year == 2018)
#
# # Continent shape
# bg_afr <- world_map |>
#   filter(continent == "Africa") |>
#   ggplot() +
#   geom_sf(fill = "grey90", colour = "grey90") +
#   theme_void()
#
# p_afr <- ggplot(data = urban_pop_a, aes(x = year, y = value / 100, group = region)) +
#   geom_line(colour = "grey80", alpha = 0.6, linewidth = 0.65) +
#   # top two in 2018
#   geom_line(data = filter(urban_pop_a, region == "Western Sahara"), colour = "#007A3D", linewidth = 0.5) +
#   geom_text(
#     data = filter(urban_pop_a, region == "Western Sahara", year == 2018),
#     label = "Western Sahara", colour = "#007A3D",
#     nudge_x = 0.2, hjust = 0
#   ) +
#   geom_line(data = filter(urban_pop_a, region == "Gabon"), colour = "#4664B2", linewidth = 0.5) +
#   geom_text(
#     data = filter(urban_pop_a, region == "Gabon", year == 2018),
#     label = "Gabon", colour = "#4664B2",
#     nudge_x = 0.2, hjust = 0
#   ) +
#   # min urban population
#   geom_line(data = filter(urban_pop_a, region == "Burundi"), colour = "#1EB53A", linewidth = 0.5) +
#   geom_text(
#     data = filter(urban_pop_a, region == "Burundi", year == 2018),
#     label = "Burudni", colour = "#1EB53A",
#     nudge_x = 0.2, hjust = 0
#   ) +
#   # growth above 10%
#   geom_line(data = filter(urban_pop_a, region %in% a_tops), colour = "black", linewidth = 0.5) +
#   coord_cartesian(xlim = c(2005, 2018), ylim = c(0.1, 1), expand = F, clip = "off") +
#   scale_x_continuous(breaks = unique(urban_pop_a$year)) +
#   scale_y_continuous(labels = scales::percent_format()) +
#   labs(
#     x = "year",
#     y = ""
#   ) +
#   theme_minimal(base_size = 14) +
#   theme(
#     plot.margin = margin(0, 50, 0, 0),
#     plot.background = element_rect(fill = NA),
#     panel.background = element_rect(fill = NA),
#     panel.grid = element_blank(),
#     axis.title = element_text(size = 14, colour = "black"),
#     axis.text = element_text(size = 14, colour = "black"),
#     axis.line = element_line(colour = "black"),
#     axis.ticks = element_line(colour = "black", linewidth = 0.5),
#     axis.ticks.length = unit(-5, "pt"),
#     aspect.ratio = 0.75
#   )
#
# # Align plots
# aligned_plots <- align_patches(bg_afr, p_afr)
#
# # Draw them in order and fine tune alignment
# p <- cowplot::ggdraw(aligned_plots[[1]])
# p_afr_assembled <- p + cowplot::draw_plot(aligned_plots[[2]], valign = 0.05, scale = 1.15)
#
#
# # Export both continents
# # -------------------- #
#
# # Prepare a joint title
# p_title <- ggdraw() +
#   draw_label(
#     "Urban population in course of 13 years in Europe and Africa",
#     fontface = 'bold',
#     x = 0,
#     hjust = 0,
#     vjust = 2
#   ) +
#   theme(
#     # title is aligned with left edge of first plot
#     plot.margin = margin(0, 0, 0, 7),
#     plot.background = element_rect(fill = "white", colour = "white"),
#     panel.background = element_rect(fill = "white", colour = "white")
#   )
#
# # Include arranged plot assemblies
# p_final <- plot_grid(p_title, plot_grid(p_eur_assembled + p_afr_assembled, align = "hv"), ncol = 1, rel_heights = c(-1, -1))
#
# ggsave(
#   plot = p_final,
#   filename = "2026/plots/04-Slope.png", width = 1200, height = 600, units = "px", scale = 2
# )
