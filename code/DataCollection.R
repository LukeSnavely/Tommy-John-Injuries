library(glue)
library(tidyverse)

download_savant_data <- function(start_date, end_date, verbose = FALSE) {
  
  base_url <- "https://baseballsavant.mlb.com/statcast_search/csv?all=true&type=details"
  
  # Split the dates into 5-day chunks. The Savant API will return at most 25,000 rows. Assuming 300
  # pitches per game, a day with 15 games will have 4,500 pitches. We can safely download 5 days of
  # data, but more days would risk hitting the 25,000-row limit.
  days <- as.numeric(as.Date(end_date) - as.Date(start_date))
  start_date_seq <- as.Date(start_date) + seq(from = 0, by = 5, to = days)
  end_date_seq <- start_date_seq + 4
  end_date_seq[length(end_date_seq)] <- end_date
  
  data <- NULL
  for (i in 1:length(start_date_seq)) {
    
    if (verbose) {
      message(glue::glue("Downloading Savant data from {start_date_seq[i]} to {end_date_seq[i]}"))
    }
    
    url <- glue::glue("{base_url}&game_date_gt={start_date_seq[i]}&game_date_lt={end_date_seq[i]}")
    data_i <- read.csv(url(url))
    
    if (nrow(data_i) == 25000) {
      warning(
        glue::glue("Exactly 25,000 rows returned for {start_date_seq[i]} to {end_date_seq[i]}")
      )
    }
    
    data <- dplyr::bind_rows(data, data_i)
  }
  
  return(data)
}

# MLB 2025
MLB_2025_March <- download_savant_data(start_date = "2025-03-27", end_date = "2025-03-31")
MLB_2025_April <- download_savant_data(start_date = "2025-04-01", end_date = "2025-04-30")
MLB_2025_May <- download_savant_data(start_date = "2025-05-01", end_date = "2025-05-31")
MLB_2025_June <- download_savant_data(start_date = "2025-06-01", end_date = "2025-06-30")
MLB_2025_July <- download_savant_data(start_date = "2025-07-01", end_date = "2025-07-31")
MLB_2025_August <- download_savant_data(start_date = "2025-08-01", end_date = "2025-08-31")
MLB_2025_September <- download_savant_data(start_date = "2025-09-01", end_date = "2025-09-28") # End of season

MLB_2025 <- rbind(MLB_2025_March,
                     MLB_2025_April,
                     MLB_2025_May,
                     MLB_2025_June,
                     MLB_2025_July,
                     MLB_2025_September)

write.csv(MLB_2025, "MLB_2025.csv")
