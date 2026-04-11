# Set-up -----------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

library(janitor)
library(dplyr)
library(tidyr)
library(countrycode)

library(ggflags)
library(ggplot2)
library(showtext)

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

ptitle <- ""

ggplot() +
  geom_vline(xintercept = seq(50, 100, 10), linetype = "dashed", colour = "grey80") +
  geom_vline(xintercept = median(df_scores1$score), colour = "grey80", linewidth = 3) +
  geom_vline(xintercept = median(df_scores2$score), colour = "grey80", linewidth = 3) +
  annotate(geom = "text", x = median(df_scores1$score), y = "Serbia", label = "2014", size = 2.5, angle = 90) +
  annotate(geom = "text", x = median(df_scores2$score), y = "Serbia", label = "2015", size = 2.5, angle = 90) +
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
  theme_void() +
  theme(plot.margin = margin(2, 2, 2, 2),
        text = element_text(family = "nunito", color = "#4a4e4d"),
        axis.text.x = element_text(colour = "black", size = 10, hjust = 0.5),
        axis.text.y = element_text(colour = "black", size = 10, hjust = 1),
        axis.text.y.right = element_text(colour = "black", size = 10, hjust = 0),
        aspect.ratio = 0.65,
        legend.position = "none")
