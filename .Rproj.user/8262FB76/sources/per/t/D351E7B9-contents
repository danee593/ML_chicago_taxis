library(readr)
evolution_trips_uncleaned <- read_csv("data_sources/queries/evolution_trips_uncleaned.csv")
View(evolution_trips_uncleaned)

structural_change = as_date('2019-01-01')

evolution_trips_uncleaned |>
  mutate(number_of_trips_millions = number_of_trips / 1000000) |>
  ggplot() +
  geom_line(aes(x=months, y=number_of_trips_millions), linewidth = 2) +
  geom_vline(aes(xintercept = structural_change), color = "blue" , linetype = "longdash") +
  labs(x = "Time",
       y = "Millions of trips")+
  theme_bw()
