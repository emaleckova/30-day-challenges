# Set-up -----------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

# Load packages
library(dplyr)

library(ggplot2)
library(showtext)
library(scales)
library(ggtext)
library(ungeviz) # data source

# Access to author info
source("commons/CreateSocialCaption.R")

# Data pre-processing ----------------------------------------------------------
# ---------------------------------------------------------------------------- #
cacao <- cacao |> 
  filter_out(is.na(location)| is.na(cocoa_percent)) |> 
  # mutate(bean_origin = case_when(
  #   bean_origin == "Domincan Republic" ~ "Dominican Republic",
  #   TRUE ~ bean_origin
  # )) |> 
  group_by(location) |> 
  mutate(n_records = n()) |> 
  filter(n_records >= 5) |> 
  mutate(cocoa_percent = as.numeric(gsub("%", "", cocoa_percent)))

locations_sorted <- cacao |> 
  group_by(location) |> 
  summarize(median_prcnt = median(cocoa_percent)) |> 
  arrange(median_prcnt) |> 
  pull(location)

cacao$location <- factor(cacao$location, levels = locations_sorted)


# Plot -------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

sysfonts::font_add_google(name = "Finger Paint", family = "fpaint")
showtext_auto()

p_cap <- paste("**Visualization:**", CreateSocialCaption(github_icon_color = "white", linkedin_icon_color = "white", text_color = "white"))

ggplot(cacao, aes(x = cocoa_percent / 100, y = location)) +
  geom_boxplot(colour = "white", linewidth = 0.55, outlier.shape = NA) +
  geom_jitter(colour = "white", size = 1.05, height = 0.35) +
  labs(title = stringr::str_wrap("Cocoa content in dark chocolate bars of the world", width = 30),
       subtitle = stringr::str_wrap("Globally, the median cocoa content in dark chocolate bars is 70%. No matter manufacturer's location, however, surprises can happen - pay attention to product labeling. Data source: cacao dataset from the {ungeviz} package (originally compiled and still updated by flavorsofcacao.com)", width = 80),
       caption = p_cap,
       x = "",
       y = "") +
  scale_x_continuous(labels = scales::percent_format()) +
  scale_y_discrete(expand = expansion(add = c(1.5, 1.5))) +
  coord_cartesian(clip = "off") +
  theme_void() +
  theme(panel.background = element_rect(fill = "#664436", colour = "#664436"),
        plot.background = element_rect(fill = "#664436", colour = "#664436"),
        plot.title.position = "plot",
        plot.title = element_text(colour = "white", hjust = 0.5,
                                  family = "fpaint", size = 24),
        plot.subtitle = element_text(colour = "white", hjust = 0.5,
                                     family = "sains", size = 11),
        plot.caption = element_markdown(margin = margin(2.5, 10, 2.5, 0), size = 10, colour = "white"),
        axis.text.x = element_text(colour = "white", hjust = 0.5,
                                 family = "fpaint", size = 10),
        axis.text.y = element_text(colour = "white", hjust = 1,
                                   family = "fpaint", size = 8.5, margin = margin(0, 0, 0, 10)),
        axis.line.x = element_line(colour = "white", linewidth = 1),
        axis.ticks.x = element_line(colour = "white", linewidth = 1),
        axis.ticks.length.x = unit(5, "pt"),
        aspect.ratio = 1.55)
