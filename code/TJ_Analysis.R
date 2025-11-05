# Packages
library(tidyverse)
library(changepoint)

# Loading in the data
MLB_2025 <- read_csv("data/MLB_2025.csv")

TJ_players <- MLB_2025 |> 
  filter(pitcher %in% c(669203, # Corbin Burnes
                        700363, # AJ Smith-Shawver
                        679885, # Justin Martinez
                        673380, # Dedniel Nunez 
                        695549 # Jackson Jobe
                        )) |> 
  select(pitch_type, pitcher, game_date, release_speed, release_spin_rate, release_extension, pitch_name, spin_axis)


# Corbin Burnes -----------------------------------------------------------
Burnes <- TJ_players |> 
  filter(pitcher == 669203)

# Filtering for cutters
Burnes_FC <- Burnes |> 
  filter(pitch_type == "FC")

# We can see Burnes' spin rate for FC is normally distributed
hist(Burnes_FC$release_spin_rate)

# Change point for Burnes' FC
FC_change <- cpt.meanvar(Burnes_FC$release_spin_rate,
                      method = "PELT",
                      minseglen = 50)

FC_change_mph <- cpt.mean(Burnes_FC$release_speed,
                             minseglen = 20)

# Plotting changepoints
plot(FC_change)
plot(FC_change_mph)


# Filtering for curveballs
Burnes_CU <- Burnes |> 
  filter(pitch_type == "CU")

# Again we see a normal distribution
hist(Burnes_CU$release_spin_rate)

CU_change <- cpt.meanvar(Burnes_CU$release_spin_rate,
                         method = "PELT",
                         minseglen = 20)

plot(CU_change)


# Build a function to look at all TJ players ------------------------------
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
    filter(pitch_type == fastball)
  
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
    number_cpt = ncpts(Fastball_change)
  )
  
  return(change)
}

TJ_ids <- c(669203, # Corbin Burnes
            700363, # AJ Smith-Shawver
            679885, # Justin Martinez
            673380, # Dedniel Nunez 
            695549 # Jackson Jobe
)

changepoint_function(695549, graph = TRUE)

results <- map(TJ_ids, changepoint_function) |> 
  bind_rows()
