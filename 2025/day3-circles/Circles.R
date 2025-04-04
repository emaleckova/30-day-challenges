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

world_pop_2021 <- 7954448391 #source: https://www.worldometers.info/world-population/
users_2021 <- global_internet_users[global_internet_users$year == 2021, ]$total_users

df_global_2021 <- data.frame(
  "internet_user" = c("yes", "no"),
  "n_people" = c(users_2021,
                world_pop_2021 - users_2021)
)

ggplot(df_global_2021, aes(x = "", y = n_people, fill = internet_user)) +
  geom_bar(stat = "identity", width = 1) +
  scale_fill_manual(values = c("#F2F2F2FF", "#035AA6FF")) +
  scale_y_continuous(labels = scales::comma) +
  coord_polar(theta = "y") +
  theme_minimal()
