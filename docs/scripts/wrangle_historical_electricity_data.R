# Wrangle historical Fortis BC electricity data (Jan 2019 – May 2022) into CSV.
# Reads rawdata/fortis_historical/Jan_01_2019_May_31_2022_fortis.csv,
# parses the m/d/yyyy h:mm:ss a.m./p.m. date-time format, and writes
# outdata/fortis_historical_data.csv.
#
# Checkpoint: skips processing if fortis_historical_data.csv already exists
# and is newer than the raw input file.

library(tidyverse)
library(here)
library(lubridate)

infile      <- here::here("rawdata", "fortis_historical",
                         "Jan_01_2019_May_31_2022_fortis.csv")
outfile     <- here::here("outdata", "fortis_historical_data.csv")
this_script <- here::here("scripts", "wrangle_historical_electricity_data.R")

# Checkpoint ---------------------------------------------------------------
if (file.exists(outfile) &&
    file.mtime(infile)       <= file.mtime(outfile) &&
    file.mtime(this_script)  <= file.mtime(outfile)) {
  message("fortis_historical_data.csv is up-to-date. Skipping.")
} else {
  message("Updating fortis_historical_data.csv...")

  historical.data <- readr::read_csv(infile, show_col_types = FALSE) %>%
    mutate(
      date_time    = parse_date_time(Date, orders = "%m/%d/%Y %I:%M:%S %p"),
      day          = date(date_time),
      hour         = hour(date_time),
      kwh_returned = NA_real_,
      kwh_consumed = `kWh delivered`
    ) %>%
    select(day, hour, kwh_returned, kwh_consumed)

  readr::write_csv(historical.data, outfile)
  message("Done. ", nrow(historical.data), " rows written to ",
          "fortis_historical_data.csv.")
}
