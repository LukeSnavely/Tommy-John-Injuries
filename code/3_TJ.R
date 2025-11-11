library(tidyverse)

# Loading in the TJ players
TJ <- read_csv("data/TJ.csv")

# Loading in season data
MLB_2025 <- read_csv("data/MLB_2025.csv")
MLB_2024 <- read_csv("data/MLB_2024.csv")
MLB_2023 <- read_csv("data/MLB_2023.csv")
MLB_2022 <- read_csv("data/MLB_2022.csv")
MLB_2021 <- read_csv("data/MLB_2021.csv")

# Filtering by year
TJ_2025 <- TJ |> 
  filter(year == 2025)

TJ_2024 <- TJ |> 
  filter(year == 2024)

TJ_2023 <- TJ |> 
  filter(year == 2023)

TJ_2022 <- TJ |> 
  filter(year == 2022)

TJ_2021 <- TJ |> 
  filter(year == 2021)


changepoint_function_by_data <- function(pitcher_id, data, graph = FALSE) {
  
  # Filtering the data for the desired pitcher
  changepoint_data <- data |> 
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
    # Last 200 pitches
    slice_tail(n = 200) 
  
  
  # Building the model
  Fastball_change_spin <- cpt.meanvar(changepoint_data$release_spin_rate,
                                      method = "PELT",
                                      minseglen = 20)
  Fastball_change_mph <- cpt.meanvar(changepoint_data$release_speed,
                                     method = "PELT",
                                     minseglen = 20)
  
  if (graph == TRUE) {
    plot(Fastball_change_spin)
    plot(Fastball_change_mph)
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
    tommy_john = 1
  )
  
  return(change)
}

# Getting results
# 2025
tj_results_2025 <- map(TJ_2025$pitcher, changepoint_function_by_data, data = MLB_2025) |> 
  bind_rows() |> 
  left_join(TJ, by = c("pitcher_id" = "pitcher"))

# 2024
tj_results_2024 <- map(TJ_2024$pitcher, changepoint_function_by_data, data = MLB_2024) |> 
  bind_rows() |> 
  left_join(TJ, by = c("pitcher_id" = "pitcher"))

# 2023
tj_results_2023 <- map(TJ_2023$pitcher, changepoint_function_by_data, data = MLB_2023) |> 
  bind_rows() |> 
  left_join(TJ, by = c("pitcher_id" = "pitcher"))

# 2022
tj_results_2022 <- map(TJ_2022$pitcher, changepoint_function_by_data, data = MLB_2022) |> 
  bind_rows() |> 
  left_join(TJ, by = c("pitcher_id" = "pitcher"))

# 2021
tj_results_2021 <- map(TJ_2021$pitcher, changepoint_function_by_data, data = MLB_2021) |> 
  bind_rows() |> 
  left_join(TJ, by = c("pitcher_id" = "pitcher"))

# Full results
tj_results <- rbind(tj_results_2025,
                    tj_results_2024,
                    tj_results_2023,
                    tj_results_2022,
                    tj_results_2021)
