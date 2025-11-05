library(tidyverse)
library(changepoint)

# Randomly selected players from 2025 with No TJ ever
NoTJ <- read_csv("data/NoTJ.csv")

# MLB Data from March to June 2025
MLB_2025 <- read_csv("data/MLB_2025.csv")

changepoint_function <- function(pitcher_id, graph = FALSE) {
  
  # Filtering the data for the desired pitcher
  changepoint_data <- MLB_2025 |> 
    select(pitch_type, pitcher, game_date, release_speed, release_spin_rate, release_extension, pitch_name, spin_axis) |> 
    filter(pitcher == pitcher_id,
           # Filtering for only fastballs
           pitch_type %in% c("FF", "FC", "FT", "FS"))
  
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
  Fastball_change <- cpt.meanvar(changepoint_data$release_spin_rate,
                                 method = "PELT",
                                 minseglen = 20)
  
  if (graph == TRUE) {
    plot(Fastball_change)
  }
  
  
  change <- tibble(
    pitcher_id = pitcher_id,
    fastball_type = fastball,
    most_recent_cpt = ifelse(ncpts(Fastball_change) == 0, NA, max(cpts(Fastball_change))),
    most_recent_mean = tail(param.est(Fastball_change)$mean, 1),
    previous_mean = ifelse(ncpts(Fastball_change) == 0, NA, tail(param.est(Fastball_change)$mean, 2)[1]),
    number_cpt = ncpts(Fastball_change),
    number_of_fastballs = nrow(changepoint_data),
    tommy_john = 0
  )
  
  return(change)
}



results <- map(NoTJ$pitcher, changepoint_function) |> 
  bind_rows()
