# Set-up -----------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

library(janitor)
library(dplyr)
library(tidyr)

library(ggplot2)
library(ggblur)
library(ggtext)
library(showtext)
library(glue)
library(cowplot)

source("commons/CreateSocialCaption.R")

# Get & pre-process data--------------------------------------------------------
# ---------------------------------------------------------------------------- #

# Original source
# https://data.metabrainz.org/pub/musicbrainz/data/fullexport/20260418-002325/



# Plot -------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

font_add_google(name = "Lobster", family = "lobster")
font_add_google(name = "League Spartan", family = "spartan")
showtext_auto()

# Plot background with caption

circ_sequence <- seq(1, 100, by = 5)

circles <- data.frame(
  size = circ_sequence,
  x = rep(1, length(circ_sequence)),
  y = rep(1, length(circ_sequence))
)

plot_cap <- paste0(
  "<span style='color:white;'>**Data source:** musicbrainz database</span>",
  "<br>",
  CreateSocialCaption(github_icon_color = "#F2D649", linkedin_icon_color = "#F2D649", text_color = "white")
  )

p_bg <- ggplot(data = circles, aes(x = 1, y = 1, size = size)) +
  geom_point(shape = 21, fill = NA, colour = "white") +
  scale_size_continuous(range = c(10, 100)) +
  scale_x_continuous(limits = c(-2, 5)) +
  scale_y_continuous(limits = c(-1, 2)) +
  labs(title = "Most Covered Songs of the King",
       caption = plot_cap) +
  theme_void() +
  theme(panel.background = element_rect(fill = "black"),
        plot.background = element_rect(fill = "black"),
        plot.title = element_text(family = "lobster", size = 30, colour = "white", hjust = 0.5),
        plot.caption = element_markdown(lineheight = 1.15, hjust = 0.95, align_widths = F),
        legend.position = "none")

# Data

dat = data.frame(
  year = c(1960, 1970, 1980),
  covers = c(10, 20, 50)
)

# colours from palette https://color.adobe.com/s-Presley-color-theme-1560137/

p_covers <- ggplot(data = dat, aes(x = year, y = covers)) +
  geom_point_blur(colour = "#F2D649", size = 5, blur_size = 10) +
  geom_point(colour = "#F2C84B", size = 4) +
  annotate(geom = "text", x = dat[1, ]$year, y = dat[1, ]$covers,
           label = glue("Covered {dat[1, ]$covers}x"),
           size = 4, colour = "white", family = "spartan",
           hjust = -0.5, vjust = -1) +
  geom_text(data = dat[2:nrow(dat), ],
            aes(x = year, y = covers, label = paste0(covers, "x")),
            size = 4, colour = "white", family = "spartan",
            hjust = -0.5, vjust = -1) +
  scale_x_continuous(expand = expansion(add = c(10, 10))) +
  scale_y_continuous(expand = expansion(add = c(5, 5))) +
  theme_void() +
  theme(plot.background = element_rect(fill = fill_alpha("black", 0.75)),
        plot.title = element_text(family = "lobster", size = 22, colour = "white", hjust = 0.5),
        aspect.ratio = 0.65,
        legend.position = "none")

p_covers

p_assembled <- ggdraw(p_bg) +
  draw_plot(p_covers, x = -0.05, y = 0.05, scale = 0.65)

# Data as insert

p_assembled

ggsave(plot = p_assembled, filename = "2026/plots/18.png", width = 1200, height = 800, units = "px", bg = "white", scale = 2.5)
