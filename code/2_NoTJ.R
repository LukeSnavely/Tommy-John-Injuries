library(tidyverse)
library(changepoint)

# Randomly selected players from 2025 with No TJ ever
NoTJ <- read_csv("data/NoTJ.csv")

# MLB Data from March to June 2025
MLB_2025 <- read_csv("data/MLB_2025.csv")

changepoint_function <- function(pitcher_id, graph_spin = FALSE, graph_mph = FALSE) {
  
  # Filtering the data for the desired pitcher
  changepoint_data <- MLB_2025 |> 
    select(pitch_type, pitcher, game_date, release_speed, release_spin_rate, release_extension, pitch_name, spin_axis) |> 
    filter(pitcher == pitcher_id,
           # Filtering for only fastballs
           pitch_type %in% c("FF", "FC", "FT", "FS", "SI"))
  
  # Finding the most common fastball thrown
  fastball <- changepoint_data |> 
    count(pitch_type) |> 
    arrange(desc(n)) |> 
    head(n = 1) |> 
    pull(pitch_type)
  
  # Filtering for most common fastball thrown
  changepoint_data <- changepoint_data |> 
    filter(pitch_type == fastball) |> 
    na.omit() |> 
    # First 300 pitches
    slice_head(n = 200) 
    
  
  # Building the model
  Fastball_change_spin <- cpt.meanvar(changepoint_data$release_spin_rate,
                                 method = "PELT",
                                 minseglen = 20)
  Fastball_change_mph <- cpt.meanvar(changepoint_data$release_speed,
                                      method = "PELT",
                                      minseglen = 20)
  
  if (graph_spin == TRUE) {
    plot(Fastball_change_spin,
         xlab = "Number of Pitches",
         ylab = "Spin Rate")
  }
  
  if (graph_mph == TRUE) {
    plot(Fastball_change_mph,
         xlab = "Number of Pitches",
         ylab = "MPH")
  }
  
  
  change <- tibble(
    pitcher_id = pitcher_id,
    fastball_type = fastball,
    # spin
    most_recent_cpt_spin = ifelse(ncpts(Fastball_change_spin) == 0, NA, max(cpts(Fastball_change_spin))),
    most_recent_mean_spin = tail(param.est(Fastball_change_spin)$mean, 1),
    previous_mean_spin = ifelse(ncpts(Fastball_change_spin) == 0, NA, tail(param.est(Fastball_change_spin)$mean, 2)[1]),
    number_cpt_spin = ncpts(Fastball_change_spin),
    # mph
    most_recent_cpt_mph = ifelse(ncpts(Fastball_change_mph) == 0, NA, max(cpts(Fastball_change_mph))),
    most_recent_mean_mph = tail(param.est(Fastball_change_mph)$mean, 1),
    previous_mean_mph = ifelse(ncpts(Fastball_change_mph) == 0, NA, tail(param.est(Fastball_change_mph)$mean, 2)[1]),
    number_cpt_mph = ncpts(Fastball_change_mph),
    number_of_fastballs = nrow(changepoint_data),
    tommy_john = 0
  )
  
  return(change)
}

# Results
no_tj_results <- map(NoTJ$pitcher, changepoint_function) |> 
  bind_rows() |> 
  left_join(NoTJ, by = c("pitcher_id" = "pitcher")) |> 
  mutate(year = 2025)
