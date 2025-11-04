# Packages
library(tidyverse)
library(changepoint)

# Loading in the data
MLB_2025 <- read_csv("data/MLB_2025_TJ.csv")

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
hist(Burnes_FF$release_spin_rate)

# Change point for Burnes' FC
FC_change <- cpt.meanvar(Burnes_FF$release_spin_rate,
                         minseglen = 20)

FC_change_mph <- cpt.meanvar(Burnes_FF$release_speed,
                             minseglen = 20)

# Plotting changepoints
plot(FC_change)
plot(FC_change_mph)


# Filtering for curveballs
Burnes_CU <- Burnes |> 
  filter(pitch_type == "CU")

# Again we see a normal distribution
hist(Burnes_CU$release_spin_rate)

CU_change <- cpt.meanvar(Burnes_CB$release_spin_rate,
                         minseglen = 20)

plot(CU_change)
