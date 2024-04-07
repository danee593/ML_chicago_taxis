library(readr)
library(tidyverse)

fare <- read_csv("data_sources/queries/Fare_uncleaned.csv")

fare |> ggplot() +
  geom_density(mapping = aes(x=fare), fill = "aquamarine")



mean_fare <- mean(fare$fare)

sd_fare <- sd(fare$fare)


summary(fare$fare)

left <- 9999-mean_fare

how_many_sds_max = left/sd_fare


mean(fare$fare<(mean_fare+sd_fare*4))

fare <- fare |>
  mutate(fare_log = log(fare))


fare |> ggplot() +
  geom_density(mapping = aes(x=fare_log), fill = "aquamarine") +
  geom_vline(aes(xintercept = log(mean_fare + 4*(sd_fare))))



