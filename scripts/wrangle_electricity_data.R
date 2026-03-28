# Wrangle Fortis BC electricity consumption data into a consolidated CSV.
# Reads CSV file(s) from rawdata/fortis_data/, parses date/time fields,
# and writes outdata/fortis_data.csv.
#
# Checkpoint: skips processing if fortis_data.csv already exists and is newer
# than all raw CSV files.

library(tidyverse)
library(here)
library(lubridate)

outfile         <- here::here("outdata", "fortis_data.csv")
fortis_raw_files <- list.files(here::here("rawdata", "fortis_data"),
                               full.names = TRUE)

# Checkpoint ---------------------------------------------------------------
if (file.exists(outfile) &&
    length(fortis_raw_files) > 0 &&
    max(file.mtime(fortis_raw_files)) <= file.mtime(outfile)) {
  message("fortis_data.csv is up-to-date. Skipping.")
} else {
  message("Updating fortis_data.csv...")

  # Handle single or multiple input files.
  # Files are reversed as a workaround for a known readr multi-file abort.
  if (length(fortis_raw_files) > 1) {
    fortis.data <- readr::read_csv(
      fortis_raw_files[length(fortis_raw_files):1],
      show_col_types = FALSE
    )[, -5]
  } else {
    fortis.data <- readr::read_csv(fortis_raw_files[1], show_col_types = FALSE)
  }

  # Parse date and the unusual "H a.m./p.m." time format
  fortis.data <- fortis.data %>%
    mutate(
      day         = lubridate::dmy(Date),
      hour        = hour(parse_date_time(gsub("\\.", "", Time), "%I %p")),
      kw_consumed = `kWh delivered`,
      kw_returned = `kWh received`
    ) %>%
    select(day, hour, kw_returned, kw_consumed) %>%
    arrange(day, hour)

  readr::write_csv(fortis.data, outfile)
  message("Done. ", nrow(fortis.data), " rows written to fortis_data.csv.")
}
