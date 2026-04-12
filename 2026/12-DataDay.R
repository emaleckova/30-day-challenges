# Set-up -----------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

library(janitor)
library(dplyr)
library(tidyr)
library(countrycode)

library(ggflags)
library(ggplot2)
library(ggtext)

library(showtext)
library(glue)

source("commons/CreateSocialCaption.R")

# Get & pre-process data--------------------------------------------------------
# ---------------------------------------------------------------------------- #

rep_dat <- read.delim("2026/data/reporters_without_borders_2025.csv", sep = ";", dec = ",", header = T)
rep_dat <- janitor::clean_names(rep_dat)

score_dat <- rep_dat |> 
  filter(zone == "UE Balkans") |> 
  select(iso, country_en, score_2025, score_n_1) |> 
  pivot_longer(cols = contains("score"), names_to = "year", values_to = "score") |> 
  mutate(year = case_when(
    grepl("2025", year) ~ 2025,
    grepl("n_1", year) ~ 2024,
    TRUE ~ NA
  ))

score_dat$iso2 <- countrycode(score_dat$country_en, "country.name", "iso2c")
score_dat$iso2 <- case_when(
  score_dat$country_en == "Kosovo" ~ "XK",
  score_dat$country_en == "Northern Cyprus" ~ NA,
  TRUE ~ score_dat$iso2
  )
score_dat$iso2 <- tolower(score_dat$iso2)

# For segment lengths in the dumbbell plot
df_scores1 <- filter(score_dat, year == 2024)
df_scores2 <- filter(score_dat, year == 2025)

# Sort countries by the latest result
countries_order <- df_scores2 |> 
  arrange(desc(score)) |> 
  pull(country_en)

df_scores1 <- rep_dat |> 
  filter(zone == "UE Balkans") |> 
  select(country_en, score_evolution) |> 
  left_join(df_scores1, by = "country_en") |> 
  mutate(score_evo_dir = case_when(
    score_evolution > 0 ~ "gain",
    score_evolution < 0 ~ "loss",
    TRUE ~ NA
  ))

score_dat <- left_join(score_dat, select(df_scores1, country_en, score_evo_dir))
score_dat$country_en <- factor(score_dat$country_en, levels = rev(countries_order))
df_scores1$country_en <- factor(df_scores1$country_en, levels = rev(countries_order))

# Plot -------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

font_add_google(name = "Nunito", family = "nunito")
showtext_auto()

p_title <- "World Press Freedom Index of European countries in 2024 and 2025"

n_gain <- sum(df_scores1$score_evo_dir == "gain")
n_loss <- sum(df_scores1$score_evo_dir == "loss")

p_subtitle <- glue(
  "The purpose of the index is to compare the level of freedom enjoyed by journalists and media in individual countries.\n
  In {n_gain} countries, the index <span style='color:#a7c957;'>**improved**</span>, but {n_loss} countries experienced <span style='color:#d4a373;'>**a decline**</span>.
  \n(Index values from 2024 are shown as dots, 2025 values are represented by country flags.)"
  )

p <- ggplot() +
  geom_rect(aes(xmin = 85, xmax = 100, ymin = -Inf, ymax = Inf), fill = "grey80") +
  geom_rect(aes(xmin = 70, xmax = 85, ymin = -Inf, ymax = Inf), fill = "grey60") +
  geom_rect(aes(xmin = 55, xmax = 70, ymin = -Inf, ymax = Inf), fill = "grey40") +
  geom_rect(aes(xmin = 40, xmax = 55, ymin = -Inf, ymax = Inf), fill = "grey20") +
  geom_rect(aes(xmin = 30, xmax = 40, ymin = -Inf, ymax = Inf), fill = "grey5") +
  geom_vline(xintercept = c(85, 70, 55, 40), linetype = "dashed", colour = "grey80") +
  annotate(geom = "text", x = c(40, 55, 70, 85, 100), y = "Norway", hjust = 1.5,
           label = c("very serious", "difficult", "problematic", "satisfactory", "good"), colour = "white", fontface = "bold", size = 8.5) +
  geom_segment(data = df_scores1,
               aes(x = score, y = country_en,
                   xend = df_scores2$score, yend = df_scores2$country_en,
                   colour = score_evo_dir),
               linewidth = 3.5,
               alpha = 0.5) +
  scale_colour_manual(values = c("loss" = "#d4a373", "gain" = "#a7c957")) +
  geom_point(data = score_dat,
             aes(x = score, y = country_en, group = country_en, colour = score_evo_dir),
             size = 4) +
  geom_flag(data = filter(score_dat, year == 2025),
            aes(x = score, y = country_en, country = iso2), size = 4) +
  scale_y_discrete(sec.axis = dup_axis(name = "")) +
  labs(title = p_title,
       subtitle = p_subtitle,
       caption = paste0(
         "**Data source:** Reporters without borders",
         "**Design:**", CreateSocialCaption())) +
  scale_x_continuous(breaks = c(40, 55, 70, 85)) +
  theme_void() +
  theme(plot.margin = margin(2, 2, 2, 2),
        text = element_text(family = "nunito", color = "#4a4e4d"),
        plot.title = element_text(face = "bold", size = 32, margin = margin(0, 0, 5, 25)),
        plot.title.position = "panel",
        plot.subtitle = element_markdown(size = 26, lineheight = 0.85, margin = margin(0, 0, 5, 25)),
        plot.caption = element_markdown(size = 22, lineheight = 1),
        axis.text.x = element_text(colour = "black", size = 22, hjust = 0.5),
        axis.text.y = element_text(colour = "black", size = 22, hjust = 1),
        axis.text.y.right = element_text(colour = "black", size = 22, hjust = 0),
        aspect.ratio = 0.65,
        legend.position = "none")

print(p)

ggsave(plot = p, filename = "2026/plots/12-DataDay.png", width = 1200, height = 800, units = "px", bg = "white", scale = 2.5)
