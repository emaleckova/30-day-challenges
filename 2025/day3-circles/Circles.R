library(ggplot2)

load("data/preprocessed_internet_users.RData")

ggplot(global_internet_users, aes(x = year, y = total_users)) +
  geom_point(aes(size = total_users), shape = 21, alpha = 0.75, colour = "black", fill = "#035AA6FF") +
  scale_x_continuous(breaks = seq(min(global_internet_users$year), max(global_internet_users$year), 10)) +
  scale_size(range = c(0.5, 5)) +
  theme_void() +
  theme(panel.grid.major.x = element_line(color = "grey", size = 0.2),
        axis.text.x = element_text(),
        axis.title.x = element_text(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank(),
        aspect.ratio = 0.65,
        legend.position = "none")
