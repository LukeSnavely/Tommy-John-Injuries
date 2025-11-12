results <- rbind(no_tj_results, tj_results)

# Finding the difference in changepoint means
results <- results |> 
  mutate(diff_spin = ifelse(number_cpt_spin == 0, 0, most_recent_mean_spin - previous_mean_spin),
         diff_mph = ifelse(number_cpt_mph == 0, 0, most_recent_mean_mph - previous_mean_mph),
         tommy_john = factor(tommy_john))

# T tests to test significance

## DIFFERNCES IN MEANS
# Spin difference
t_diff_spin <- t.test(diff_spin ~ tommy_john, data = results)
# p-value is not significance, no difference in groups

# MPH difference
t_diff_mph <- t.test(diff_mph ~ tommy_john, data = results)
# p-value is not significance


## NUMBER OF CHANGEPOINTS
# Spin
t_cpt_spin <- t.test(number_cpt_spin ~ tommy_john, data = results)
# p-value is not significance

# MPH
t_cpt_mph <- t.test(number_cpt_mph ~ tommy_john, data = results)
# p-value is not significance

t_test_df <- data.frame(diff_spin = round(t_diff_spin$p.value, 3),
                        diff_mph = round(t_diff_mph$p.value, 3),
                        cpt_spin = round(t_cpt_spin$p.value, 3),
                        cpt_mph = round(t_cpt_mph$p.value, 3))

# Visualizations ----------------------------------------------------------
library(gt)

# p-value table
t_test_df |> 
  gt() |> 
  tab_header(title = md("**All p-values of t-tests with Tommy John Indicator**"),
             subtitle = md("*No p-values were found to be significant*")) |> 
  cols_label(diff_spin = "Difference in spin", diff_mph = "Difference in MPH",
             cpt_spin = "Number of changepoints for spin",
             cpt_mph = "Number of changepoints for MPH") |> 
  gtExtras::gt_theme_pff() |> 
  opt_align_table_header("center") # |> 
  # gtsave("pvalues.png")

# Data table (Corbin Burnes)
MLB_2025 |> 
  filter(pitcher == 669203) |> 
  select(pitcher, pitch_type, release_speed, release_spin_rate, game_date, player_name, description) |> 
  slice_head(n = 8) |> 
  gt() |> 
  tab_header(title = md("**Example pitch-by-pitch data from MLB Savant**"),
             subtitle = md("*Corbin Burnes in the 2025 season*")) |> 
  cols_label(pitcher = "Pitcher ID", pitch_type = "Pitch Type", release_speed = "Release Speed",
             release_spin_rate = "Release Spin Rate", game_date = "Game Date",
             player_name = "Batter", description = "Description") |> 
  gtExtras::gt_theme_pff() |> 
  opt_align_table_header("center") # |> 
  # gtsave("Data.png")

## Player example
# Corbin Burnes
changepoint_function_by_data(669203, MLB_2025, graph_spin = TRUE)
changepoint_function_by_data(669203, MLB_2025, graph_mph = TRUE)
