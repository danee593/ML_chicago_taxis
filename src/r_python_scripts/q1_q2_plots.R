library(readr)
library(tidyverse)
library(patchwork)
library(fpp3)


q1 <- read_csv("data_sources/queries/q1_and_2.csv", 
                                         col_types = cols(date_formatted = col_date(format = "%Y-%m-%d")))

plots <- list()

timelineplot <- function(data, y_value, y_title){
  y_value <- enquo(y_value)
  plot <- ggplot(data = data, aes(x = date_formatted, y = !!y_value)) +
    geom_line(linewidth = 1.5) +
    labs(x = "Time", y = y_title) +
    theme_bw()
  return(plot)
}

columns <- c("avg_real_fare_mile", "avg_real_fare_second", "avg_trip_miles", "avg_trip_seconds")
names <- c("Average Real Fare per Mile", "Average Real Fare per Second", "Average Miles per Trip",
           "Average Seconds per Trip")

for (i in 1:length(columns)){
  plot <- timelineplot(q1, !!sym(columns[i]) , names[i])
  plots[[i]] <- plot
}

combined_plot <- wrap_plots(plots, ncol = 2)

combined_plot


q1_t <- q1 |>
  mutate(no_trips_millions = no_trips/1000000,
         date = make_yearmonth(year=year(date_formatted), month=month(date_formatted))) |>
  select(c(date, no_trips_millions)) |>
  as_tsibble(index = date)


q1_t |>
  gg_season() +
  ylab("Taxi Trips in Millions") +
  ggtitle("Taxi Trips in Chicago") +
  theme_bw()


q1_t |>
  gg_subseries(no_trips_millions)+
  ylab("Taxi Trips in Millions") +
  ggtitle("Monthly trends of taxi trips in Chicago") +
  theme_bw()


