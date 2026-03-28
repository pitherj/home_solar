# Download local weather data for the Kelowna area from Environment Canada
# via the weathercan package.
#
# Unlike the other wrangling scripts, weather data is NOT automatically
# re-downloaded on each run. Set force_update <- TRUE below to refresh.
# The end date defaults to today so re-running with force_update = TRUE
# will always fetch the most current data.

library(tidyverse)
library(weathercan)
library(here)

outfile      <- here::here("outdata", "weather_data.csv")
force_update <- FALSE   # set to TRUE to re-download regardless of file state

# Checkpoint ---------------------------------------------------------------
if (!file.exists(outfile) || force_update) {
  message("Downloading weather data from Environment Canada...")

  # Locate the UBCO (Okanagan) station – best available near Kelowna
  # Note: no solar radiation data is publicly available for Kelowna
  station_id <- stations_search("UBCO", interval = "hour")$station_id

  kelowna <- weather_dl(
    station_ids = station_id,
    start       = "2022-07-08",
    end         = as.character(Sys.Date())
  )

  readr::write_csv(kelowna, outfile)
  message("Done. Weather data written to weather_data.csv.")
} else {
  message("weather_data.csv exists. Set force_update <- TRUE to re-download.")
}
