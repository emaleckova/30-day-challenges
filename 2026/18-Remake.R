# Set-up -----------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

library(dplyr)
library(tidyr)

library(ggplot2)
library(ggblur)
library(ggtext)
library(showtext)
library(glue)
library(cowplot)

source("commons/CreateSocialCaption.R")

# Create input data ------------------------------------------------------------
# ---------------------------------------------------------------------------- #

# Credits: ChatGPT
elvis_covers <- data.frame(
  song = c(
    # Early rock & breakthrough (1950s)
    "That's All Right",
    "Blue Suede Shoes",
    "Hound Dog",
    "Heartbreak Hotel",
    "Don't Be Cruel",
    "All Shook Up",
    "Love Me Tender",
    "Jailhouse Rock",
    "Too Much",
    "Teddy Bear",
    
    # Late 1950s / early 1960s transition
    "Wear My Ring Around Your Neck",
    "It's Now or Never",
    "Are You Lonesome Tonight?",
    "Stuck on You",
    "A Big Hunk o' Love",
    
    # Early–mid 1960s film era
    "Can't Help Falling in Love",
    "Return to Sender",
    "She's Not You",
    "Viva Las Vegas",
    "Kiss Me Quick",
    
    # Late 1960s comeback era
    "Suspicious Minds",
    "In the Ghetto",
    "Kentucky Rain",
    
    # 1970s ballads & Vegas era
    "The Wonder of You",
    "Always on My Mind",
    "Burning Love",
    "An American Trilogy",
    "My Way",
    
    # Lesser-covered / deeper cuts
    "I Want You, I Need You, I Love You",
    "One Night",
    "Little Sister",
    "If I Can Dream",
    "Polk Salad Annie"
  ),
  
  release_year = c(
    1954, 1956, 1956, 1956, 1956, 1957, 1956, 1957, 1957, 1957,
    1958, 1960, 1960, 1960, 1961,
    1961, 1962, 1962, 1964, 1963,
    1969, 1969, 1969,
    1970, 1972, 1972, 1972, 1973,
    1956, 1958, 1961, 1968, 1969
  ),
  
  estimated_covers = c(
    # early rock (widely covered standards)
    120, 300, 500, 200, 250, 175, 250, 200, 140, 160,
    
    # transitional hits
    80, 200, 150, 120, 90,
    
    # film era staples
    300, 130, 110, 200, 90,
    
    # comeback era
    150, 180, 100,
    
    # 1970s
    150, 400, 220, 140, 300,
    
    # deep cuts (less covered)
    90, 110, 95, 160, 80
  ),
  
  genre = c(
    # early rock
    "Rockabilly", "Rockabilly", "Rock & Roll", "Rock & Roll", "Rock & Roll",
    "Rock & Roll", "Ballad", "Rock & Roll", "Rock & Roll", "Rock & Roll",
    
    # transition
    "Rock & Roll", "Ballad", "Ballad", "Rock & Roll", "Rock & Roll",
    
    # film era
    "Ballad", "Pop", "Pop", "Rock & Roll", "Pop",
    
    # comeback
    "Rock Ballad", "Soul", "Country Ballad",
    
    # 1970s
    "Ballad", "Ballad", "Rock", "Gospel/Orchestral", "Ballad",
    
    # deep cuts
    "Ballad", "Rock & Roll", "Rock & Roll", "Gospel", "Blues Rock"
  )
)



# Plot -------------------------------------------------------------------------
# ---------------------------------------------------------------------------- #

font_add_google(name = "Lobster", family = "lobster")
font_add_google(name = "League Spartan", family = "spartan")
showtext_auto()

# Plot background with caption

circ_sequence <- seq(1, 150, by = 5)

circles <- data.frame(
  size = circ_sequence,
  x = rep(1, length(circ_sequence)),
  y = rep(1, length(circ_sequence))
)

plot_cap <- paste0(
  "<span style='color:white;'>**Data source:** SecondHandSongs & MusicBrainz, compilation by ChatGPT</span>",
  "<br>",
  CreateSocialCaption(github_icon_color = "#F2D649", linkedin_icon_color = "#F2D649", text_color = "white")
  )

p_bg <- ggplot(data = circles, aes(x = 1, y = 1, size = size)) +
  geom_point(shape = 21, fill = NA, colour = "white") +
  scale_size_continuous(range = c(10, 100)) +
  scale_x_continuous(limits = c(-2, 5)) +
  scale_y_continuous(limits = c(-151, 152)) +
  labs(title = "Most Covered Songs of the King",
       caption = plot_cap) +
  theme_void() +
  theme(panel.background = element_rect(fill = "black"),
        plot.background = element_rect(fill = "black"),
        plot.title = element_text(family = "lobster", size = 30, colour = "white", hjust = 0.5),
        plot.caption = element_markdown(lineheight = 1.15, hjust = 0.95, align_widths = F),
        legend.position = "none")

# colours from palette https://color.adobe.com/s-Presley-color-theme-1560137/

# arrange data by year -> text placement int he plot
elvis_covers <- elvis_covers |> 
  arrange(-estimated_covers)

p_covers <- ggplot(data = elvis_covers, aes(x = release_year, y = estimated_covers)) +
  geom_point_blur(colour = "#F2D649", size = 3, blur_size = 10) +
  geom_point(colour = "#F2C84B", size = 2.5) +
  annotate(geom = "text", x = elvis_covers[1, ]$release_year, y = elvis_covers[1, ]$estimated_covers,
           label = glue("Covered {elvis_covers[1, ]$estimated_covers}x"),
           size = 3, colour = "white", family = "spartan",
           hjust = -0.5, vjust = -0.5) +
  ggrepel::geom_text_repel(data = elvis_covers[2:nrow(elvis_covers), ],
            aes(x = release_year, y = estimated_covers, label = paste0(estimated_covers, "x")),
            size = 3, colour = "white", family = "spartan", nudge_y = 1) +
  ggrepel::geom_text_repel(data = elvis_covers[elvis_covers$estimated_covers >= 400, ],
                           aes(x = release_year, y = estimated_covers, label = song),
                           size = 4, colour = "#F2D649", family = "spartan",
                           min.segment.length = 0, nudge_y = -15) +
  scale_x_continuous(limits = c(1950, 1980), expand = expansion(add = c(0, 10))) +
  scale_y_continuous(expand = expansion(add = c(35, 25))) +
  theme_void() +
  theme(plot.background = element_rect(fill = fill_alpha("black", 0.75)),
        plot.title = element_text(family = "lobster", size = 22, colour = "white", hjust = 0.5),
        axis.line = element_line(colour = "white", linewidth = 1),
        axis.text.x = element_text(family = "spartan", colour = "white", size = 14),
        axis.ticks.x = element_line(colour = "white", linewidth = 1),
        axis.ticks.length.x = unit(-10, "pt"),
        aspect.ratio = 0.65,
        legend.position = "none")

p_covers

p_assembled <- ggdraw(p_bg) +
  draw_plot(p_covers, x = -0.05, y = 0.01, scale = 0.65)

# Data as insert

p_assembled

ggsave(plot = p_assembled, filename = "2026/plots/18.png", width = 1200, height = 800, units = "px", bg = "white", scale = 2.5)
