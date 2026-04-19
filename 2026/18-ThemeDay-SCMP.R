# SETUP ------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

# Packages
library(dplyr)
library(tidyr)
library(rnaturalearth)
library(countrycode)

library(ggplot2)
library(showtext)

# Author details fxn
source("commons/CreateSocialCaption.R")

rep_dat <- read.delim("2026/data/reporters_without_borders_2025.csv", sep = ";", dec = ",", header = T)
rep_dat <- janitor::clean_names(rep_dat)

score_dat <- rep_dat |> 
  filter(zone == "Asie-Pacifique") |> 
  select(iso, country_en, score_2025, score_n_1) |> 
  pivot_longer(cols = contains("score"), names_to = "year", values_to = "score") |> 
  mutate(year = case_when(
    grepl("2025", year) ~ 2025,
    grepl("n_1", year) ~ 2024,
    TRUE ~ NA
  ))

score_dat$iso2 <- countrycode(score_dat$country_en, "country.name", "iso2c")

# PLOT -------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

# South China Morning Post colours
scmp_blue <- "#001246"
scmp_yellow <- "#FFCA05"
scmp_gold <- "#c79a00"

# and fonts

sysfonts::font_add_google("Merriweather", "merriweather")
sysfonts::font_add_google("Roboto", "roboto")

# top 5% by increase
top_incs <- rep_dat |> 
  filter(zone == "Asie-Pacifique") |> 
  select(country_en, score_evolution) |> 
  distinct() |> 
  slice_max(n = 5, order_by = score_evolution) |> 
  pull(country_en)

# and top 5% by decrease
top_decs <- rep_dat |> 
  filter(zone == "Asie-Pacifique") |> 
  select(country_en, score_evolution) |> 
  distinct() |> 
  slice_min(n = 5, order_by = score_evolution) |> 
  pull(country_en)

# categorize
score_dat <- score_dat |> 
  mutate(category = case_when(
    country_en %in% top_incs ~ "top",
    country_en %in% top_decs ~ "bottom",
    TRUE ~ "others"
  ),
  # and a numerical helper for plotting
  num_category = case_when(
    country_en %in% top_incs ~ 2,
    country_en %in% top_decs ~ 2,
    TRUE ~ 1
  ))



p_subt <- glue(
  "**The purpose of the index is to compare the level of freedom <br>enjoyed by journalists and media in individual countries.** <br> The five countries with biggest year-to-year <span style=color:{scmp_yellow};>**IMPROVEMENT**</span> are problematic countries. <br> In contrary, countries with largest <span style=color:{scmp_blue};>**SCORE DECLINE**</span> are a mixture of well and poorly scoring countries."
)

p_cap <- paste0(
  "**Data source:** Reporters without borders <br>",
  "**Design:**", CreateSocialCaption(github_icon_color = scmp_gold, linkedin_icon_color = scmp_gold)
  )

p_asia <- ggplot(data = score_dat, aes(x = as.factor(year), y = score)) +
  geom_path(aes(colour = category, linewidth = num_category, group = country_en)) +
  geom_point(aes(colour = category, size = score)) +
  ggrepel::geom_text_repel(data = filter(score_dat, country_en %in% c(top_incs, top_decs), year == 2025),
            aes(label = country_en), size = 4, nudge_x = 0.35, segment.linetype = "dashed",
            family = "roboto") +
  scale_colour_manual(values = c("bottom" = scmp_blue, "top" = scmp_yellow, "others" = "grey80")) +
  scale_size_continuous(range = c(2, 6)) +
  scale_linewidth_continuous(range = c(1, 2)) +
  scale_x_discrete(expand = expansion(add = c(0.02, 0.05))) +
  labs(
    title = "World Press Freedom Index of Asian countries in 2024 vs 2025",
    subtitle = p_subt,
    caption = p_cap,
    x = " ",
    y = "score"
  ) +
  theme_void() +
  theme(
    plot.margin = margin(0, 50, 0, 0),
    plot.background = element_rect(fill = NA),
    panel.background = element_rect(fill = NA),
    panel.grid = element_blank(),
    plot.title = element_text(family = "merriweather", color = scmp_gold, margin = margin(2.5, 0, 5, 0)),
    plot.subtitle = ggtext::element_markdown(family = "roboto", lineheight = 1.15, size = 10,
                                             margin = margin(2.5, 0, 2.5, 0)),
    plot.caption = ggtext::element_markdown(family = "roboto", size = 10),
    axis.title.y = element_text(colour = "black", angle = 90, family = "roboto"),
    axis.text = element_text(colour = "black", family = "roboto"),
    axis.line.x.bottom = element_line(colour = "black"),
    axis.line.y.left  = element_line(colour = "black"),
    axis.ticks = element_line(colour = "black", linewidth = 0.5),
    axis.ticks.length = unit(5, "pt"),
    aspect.ratio = 1,
    legend.position = "none"
  )

p_asia
