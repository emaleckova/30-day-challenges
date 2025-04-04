library(ggplot2)
library(cowplot)

# Load preprocessed data
load("data/preprocessed_internet_users.RData")

# Users by year
p_times <- ggplot(global_internet_users, aes(x = year, y = number_of_internet_users)) +
  geom_point(aes(size = number_of_internet_users),
             shape = 21, alpha = 0.75, colour = "black", fill = "#035AA6FF") +
  scale_x_continuous(breaks = seq(min(global_internet_users$year),
                                  max(global_internet_users$year), 10)) +
  scale_y_continuous(limits = c(0, 5000000000), expand = c(0, 0),
                     breaks = seq(1e9, 5e9, 1e9),
                     labels = scales::label_number(scale = 1e-9, suffix = " B")) +
  scale_size(range = c(1, 10)) +
  theme_classic() +
  theme(panel.grid.major.x = element_line(color = "grey", size = 0.2),
        axis.text.x = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_blank(),
        aspect.ratio = 0.65,
        legend.position = "none")

# Pie chart for 2021
world_pop_2021 <- 7954448391
users_2021 <- global_internet_users[global_internet_users$year == 2021, ]$number_of_internet_users

df_global_2021 <- data.frame(
  "internet_user" = c("users", "non-users"),
  "n_people" = c(users_2021,
                world_pop_2021 - users_2021)
)

# a label
df_global_2021$frx_people <- paste0(round(df_global_2021$n_people / world_pop_2021 * 100, 0), "%")

p_2021 <- ggplot(df_global_2021, aes(x = "", y = n_people, fill = internet_user)) +
  geom_bar(stat = "identity", width = 1) +
  scale_fill_manual(values = c("#F2F2F2FF", "#035AA6FF")) +
  geom_text(aes(y = n_people, label = paste(frx_people, "\n", internet_user)),
            position = position_stack(vjust = 0.5), size = 3) +
  scale_y_continuous(labels = scales::comma) +
  coord_polar(theta = "y") +
  labs(title = "Population with Access \n in 2021") + 
  theme_void() +
  theme(plot.title = element_text(size = 8, vjust = 0.5, hjust = 0.5),
        legend.position = "none")


# combined plot
p_combined <- ggdraw(p_times) +
  draw_plot(p_2021, x = 0.01, y = 0.5, width = 0.45, height = 0.45) +
  draw_label("Global Acess to the Internet between 1990 and 2021",
             x = 0.5, y = 1, size = 11, fontface = "bold", vjust = 1)

# export
ggsave(plot = p_combined, filename = "plots/03-Circles.png")

