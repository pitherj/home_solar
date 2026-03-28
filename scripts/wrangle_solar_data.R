# Wrangle raw solar energy data (AP Systems Excel files) into a consolidated CSV.
# Reads weekly .xls files from rawdata/solar_data/, reshapes to long format,
# and writes outdata/solar_data.csv.
#
# Checkpoint: skips processing if solar_data.csv already exists and is newer
# than all raw Excel files.

library(readxl)
library(tidyverse)
library(here)
library(stringr)
library(lubridate)
library(purrr)

outfile        <- here::here("outdata", "solar_data.csv")
solar_raw_dir  <- here::here("rawdata", "solar_data")
solar_raw_files <- list.files(solar_raw_dir, full.names = TRUE)

# Checkpoint ---------------------------------------------------------------
if (file.exists(outfile) &&
    length(solar_raw_files) > 0 &&
    max(file.mtime(solar_raw_files)) <= file.mtime(outfile)) {
  message("solar_data.csv is up-to-date. Skipping.")
} else {
  message("Updating solar_data.csv...")

  solar.files <- list.files(solar_raw_dir)

  # Derive temp CSV output names from the Excel filenames
  solar.output.files <- vapply(solar.files, function(f) {
    f %>%
      stringr::str_split("Report") %>%
      purrr::pluck(1, 2) %>%
      str_trim() %>%
      str_replace(" to ", "_") %>%
      str_replace("\\.xls$", ".csv")
  }, character(1), USE.NAMES = FALSE)

  # Import each Excel file, reshape to long format, write temp CSV
  for (i in seq_along(solar.files)) {
    temp <- readxl::read_xls(
      file.path(solar_raw_dir, solar.files[i]),
      trim_ws = TRUE
    ) %>%
      filter(Hour != "Total") %>%
      mutate(Hour = as.integer(Hour)) %>%
      rename(hour = Hour) %>%
      tidyr::pivot_longer(!hour, names_to = "day", values_to = "kWh") %>%
      arrange(day) %>%
      mutate(date = lubridate::ymd_h(paste0(str_sub(day, 1, 10), hour))) %>%
      select(date, kWh)

    write_csv(temp, file.path(here::here("outdata"), solar.output.files[i]))
  }

  # Combine all temp CSVs, add day/hour columns, deduplicate
  temp_paths <- file.path(here::here("outdata"), solar.output.files)

  solar.data <- readr::read_csv(temp_paths, id = "file_name",
                                show_col_types = FALSE) %>%
    select(date, kWh) %>%
    mutate(
      day  = lubridate::date(date),
      hour = lubridate::hour(date)
    ) %>%
    select(date, day, hour, kWh) %>%
    distinct()

  readr::write_csv(solar.data, outfile)
  file.remove(temp_paths)

  message("Done. ", nrow(solar.data), " rows written to solar_data.csv.")
}
