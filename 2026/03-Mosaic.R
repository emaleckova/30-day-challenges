# Set-up -----------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

# Load packages
library(NHANES)

library(dplyr)

library(ggplot2)
library(ggmosaic)
library(paletteer)
library(showtext)
library(ggtext)

# Access to author info
source("commons/CreateSocialCaption.R")

# Explore data and survey years
glimpse(NHANES)
unique(NHANES$SurveyYr)

target_survey <- "2011_12"

# LOAD DATA as a data frame

# It's a big dataset, so table() is your friend first
plot_dat <- data.frame(NHANES$SurveyYr, NHANES$Education, NHANES$HealthGen)
colnames(plot_dat) <- c("survey_year", "education", "health")

# Subset for selected year and keep only complete cases
plot_dat <- plot_dat |>
  filter(survey_year == target_survey)

plot_dat <- plot_dat[rowSums(is.na(plot_dat)) == 0, ]

# Make health column a factor with foxed order -> order in the plot
# Before that, control how "very good" is spelled
plot_dat$health <- case_when(
  plot_dat$health == "Vgood" ~ "Very good",
  TRUE ~ paste(plot_dat$health)
)

health_levels <- c(
  "Excellent",
  "Very good",
  "Good",
  "Fair",
  "Poor"
)

plot_dat$health <- factor(plot_dat$health, levels = rev(health_levels))


# Plot -------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

p_mosaic <- ggplot(plot_dat) +
  geom_mosaic(aes(x = product(education), fill = health)) +
  scale_fill_manual(values = rev(paletteer::paletteer_d("nord::silver_mine"))) +
  coord_cartesian(expand = F) +
  labs(
    title = paste("Education level vs self-reported health status \nacross",
                  format(nrow(plot_dat), big.mark = " "), "US respondents (Dec 2011)"),
    x = "",
    y = ""
  ) +
  theme_mosaic() +
  theme(
    plot.title = element_text(size = 14, face = "bold", lineheight = 0.35),
    axis.title = element_blank(),
    axis.text.x = element_text(
      size = 14, colour = "black", face = "bold",
      angle = 90, hjust = 1, vjust = 0.5
    ),
    axis.text.y = element_text(size = 14, colour = "black", face = "bold"),
    axis.ticks = element_blank(),
    aspect.ratio = 1,
    legend.position = "none"
  )

p_mosaic

# Include author details in the graphic
author_cap <- CreateSocialCaption()

font_add(family = "monospace", regular = "cour.ttf")

p_mosaic <- p_mosaic +
  labs(caption = paste(
    "**Data source**: <span style='font-family:monospace;'>{NHANES}</span> package ",
    "&nbsp;&nbsp;&nbsp;&nbsp; **|**",
    author_cap
  )) +
  theme(plot.caption = ggtext::element_markdown(size = 13, lineheight = 1.5, vjust = -2.5))

p_mosaic


# Export
# ---- #
ggsave(plot = p_mosaic, filename = "2026/plots/03-Mosaic.png", width = 1200, height = 1200, units = "px", scale = 0.65)
