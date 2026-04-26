# SETUP ------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

# Packages
library(Kendall)

library(dplyr)
library(ggplot2)
library(ggtext)
library(showtext)

# Custom author/data details function
source("commons/CreateSocialCaption.R")

# Load and explore data
data(PrecipGL)
str(PrecipGL)

# Preprocess for plotting
dat_precip <- data.frame(
  year = 1900:1986,
  "precip_in" = PrecipGL[1:length(PrecipGL)]
  )

glimpse(dat_precip)

# PLOT -------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

# Custom fonts
# fontawesome icons
font_add(family = "fa-solid", regular = "commons/fonts/Font Awesome 7 Free-Solid-900.otf")
# title and plain text
font_add_google(name = "Source Code Pro", family = "monospace")
font_add_google(name = "Winky Rough", family = "winky")
# this is so that fonts are accessible to ggplot2
showtext_auto()

# Title
p_title <- "Great Lakes Annual Precipitation (1900–1986)"
# Caption is combination of data source and author details
p_caption = paste0(
  "**Data source:**", " PrecipGL dataset from the {Kendall} R package",
  "**Visualization:**", CreateSocialCaption(github_icon_color = "#A89797FF", linkedin_icon_color = "#007FFFFF")
  )

# Actual plot is created here
ggplot(data = dat_precip, aes(x = year, y = precip_in)) +
  geom_path(linetype = "dotted", linewidth = 0.85, colour = "#007FFFFF", alpha = 0.5) +
  # display waterdrop at place of individual data points
  geom_richtext(aes(label = "<span style='font-family:fa-solid'>&#xf043;</span>", size = precip_in),
                label.colour = NA,
                label.padding = unit(0, "pt"),
                label.margin = unit(0, "pt"),
                show.legend = F,
                col = "#007FFFFF",
                fill = NA) +
  # label every fifth year - should be easier to navigate across years than usual axis breaks
  geom_text(data = filter(dat_precip, year %in% seq(1905, 1990, by = 5)) |> 
              mutate(nudge = case_when(
                precip_in <= 30 ~ -1.15,
                TRUE ~ 1.15
              )),
            aes(x = year, y = precip_in, label = year, nudge_y = nudge),
            angle = 90, size = 3.5, family = "winky", fontface = "bold", colour = "#A89797FF") +
  labs(title = p_title,
       y = "precipitation [in]",
       caption = p_caption) +
  scale_size_continuous(range = c(1.5, 5)) +
  scale_x_continuous(limits = c(1900, 1986), expand = expansion(add = c(0.5, 1))) +
  scale_y_continuous(limits = c(22, max(dat_precip$precip_in) + 2.55),
                     breaks = seq(20, max(dat_precip$precip_in), by = 5),
                     expand = F,
                     # secondary axis is to include metric units in the same plot
                     sec.axis = sec_axis(transform = ~ . * 25.4, name = "precipitation [mm]")) +
  theme_void() +
  theme(plot.margin = margin(5, 5, 5, 5),
        plot.background = element_rect(fill = alpha("#FFEFB2FF", 0.35)),
        plot.title = element_text(colour = "#A89797FF", family = "winky",
                                  size = 22, hjust = 0.5),
        plot.caption = element_markdown(family = "winky"),
        axis.title.y.left = element_text(colour = "#A89797FF", family = "winky",
                                         angle = 90, margin = margin(0, 10, 0, 0)),
        axis.title.y.right = element_text(colour = "#A89797FF", family = "winky",
                                          angle = 90, margin = margin(0, 0, 0, 10)),
        axis.line.x = element_line(colour = "#A89797FF", linewidth = 1),
        axis.line.y = element_line(colour = "#A89797FF", linewidth = 1),
        axis.ticks.y = element_line(colour = "#A89797FF", linewidth = 1),
        axis.ticks.length.y = unit(5, "pt"),
        axis.text.y = element_text(colour = "#A89797FF", family = "winky"),
        aspect.ratio = 0.5)

# Note: colour choice is based on palette "tvthemes::Arryn"