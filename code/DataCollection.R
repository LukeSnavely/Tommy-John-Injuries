## NOTE: This data will TAKE A LONG TIME to write

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


# MLB 2024
MLB_2024_March <- download_savant_data(start_date = "2024-03-20", end_date = "2024-03-31")
MLB_2024_April <- download_savant_data(start_date = "2024-04-01", end_date = "2024-04-30")
MLB_2024_May <- download_savant_data(start_date = "2024-05-01", end_date = "2024-05-31")
MLB_2024_June <- download_savant_data(start_date = "2024-06-01", end_date = "2024-06-30")
MLB_2024_July <- download_savant_data(start_date = "2024-07-01", end_date = "2024-07-31")
MLB_2024_August <- download_savant_data(start_date = "2024-08-01", end_date = "2024-08-31")
MLB_2024_September <- download_savant_data(start_date = "2024-09-01", end_date = "2024-09-29") # End of season

MLB_2024 <- rbind(MLB_2024_March,
                  MLB_2024_April,
                  MLB_2024_May,
                  MLB_2024_June,
                  MLB_2024_July,
                  MLB_2024_September)

write.csv(MLB_2024, "MLB_2024.csv")

# MLB 2023
MLB_2023_March <- download_savant_data(start_date = "2023-03-30", end_date = "2023-03-31")
MLB_2023_April <- download_savant_data(start_date = "2023-04-01", end_date = "2023-04-30")
MLB_2023_May <- download_savant_data(start_date = "2023-05-01", end_date = "2023-05-31")
MLB_2023_June <- download_savant_data(start_date = "2023-06-01", end_date = "2023-06-30")
MLB_2023_July <- download_savant_data(start_date = "2023-07-01", end_date = "2023-07-31")
MLB_2023_August <- download_savant_data(start_date = "2023-08-01", end_date = "2023-08-31")
MLB_2023_September <- download_savant_data(start_date = "2023-09-01", end_date = "2023-09-29")
MLB_2023_October <- download_savant_data(start_date = "2023-10-01", end_date = "2023-10-01") # End of season

MLB_2023 <- rbind(MLB_2023_March,
                  MLB_2023_April,
                  MLB_2023_May,
                  MLB_2023_June,
                  MLB_2023_July,
                  MLB_2023_September,
                  MLB_2023_October)

write.csv(MLB_2023, "MLB_2023.csv")

# MLB 2022
MLB_2022_April <- download_savant_data(start_date = "2022-04-07", end_date = "2022-04-30")
MLB_2022_May <- download_savant_data(start_date = "2022-05-01", end_date = "2022-05-31")
MLB_2022_June <- download_savant_data(start_date = "2022-06-01", end_date = "2022-06-30")
MLB_2022_July <- download_savant_data(start_date = "2022-07-01", end_date = "2022-07-31")
MLB_2022_August <- download_savant_data(start_date = "2022-08-01", end_date = "2022-08-31")
MLB_2022_September <- download_savant_data(start_date = "2022-09-01", end_date = "2022-09-29")
MLB_2022_October <- download_savant_data(start_date = "2022-10-01", end_date = "2022-10-05") # End of season

MLB_2022 <- rbind(MLB_2022_April,
                  MLB_2022_May,
                  MLB_2022_June,
                  MLB_2022_July,
                  MLB_2022_August,
                  MLB_2022_September,
                  MLB_2022_October)

write.csv(MLB_2022, "MLB_2022.csv")


# MLB 2021
MLB_2021_April <- download_savant_data(start_date = "2021-04-01", end_date = "2021-04-30")
MLB_2021_May <- download_savant_data(start_date = "2021-05-01", end_date = "2021-05-31")
MLB_2021_June <- download_savant_data(start_date = "2021-06-01", end_date = "2021-06-30")
MLB_2021_July <- download_savant_data(start_date = "2021-07-01", end_date = "2021-07-31")
MLB_2021_August <- download_savant_data(start_date = "2021-08-01", end_date = "2021-08-31")
MLB_2021_September <- download_savant_data(start_date = "2021-09-01", end_date = "2021-09-29")
MLB_2021_October <- download_savant_data(start_date = "2021-10-01", end_date = "2021-10-03") # End of season

MLB_2021 <- rbind(MLB_2021_April,
                  MLB_2021_May,
                  MLB_2021_June,
                  MLB_2021_July,
                  MLB_2021_August,
                  MLB_2021_September,
                  MLB_2021_October)

write.csv(MLB_2021, "MLB_2021.csv")
