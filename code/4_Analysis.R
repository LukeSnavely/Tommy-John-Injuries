results <- rbind(no_tj_results, tj_results)

# Finding the difference in changepoint means
results <- results |> 
  mutate(diff_spin = ifelse(number_cpt_spin == 0, 0, most_recent_mean_spin - previous_mean_spin),
         diff_mph = ifelse(number_cpt_mph == 0, 0, most_recent_mean_mph - previous_mean_mph),
         tommy_john = factor(tommy_john))

# T tests to test significance

## DIFFERNCES IN MEANS
# Spin difference
t.test(diff_spin ~ tommy_john, data = results)
# p-value is not significance, no difference in groups

# MPH difference
t.test(diff_mph ~ tommy_john, data = results)
# p-value is not significance


## NUMBER OF CHANGEPOINTS
# Spin
t.test(number_cpt_spin ~ tommy_john, data = results)
# p-value is not significance

# MPH
t.test(number_cpt_mph ~ tommy_john, data = results)
# p-value is not significance
