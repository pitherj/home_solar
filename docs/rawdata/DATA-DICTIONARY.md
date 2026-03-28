# Raw Data — Data Dictionary

**Directory**: `rawdata/`
**Dictionary type**: Input data
**Last updated**: 2026-03-28
**Maintained by**: Jason Pither

All input data for the home solar analysis. Data must be manually placed in the
appropriate subdirectory; none of the files in this directory are auto-downloaded.
Wrangling scripts in `scripts/` check file modification times and only regenerate
output files when the raw data is newer.

---

## Manually obtained datasets

---

### AP Systems solar energy reports

**Location**: `rawdata/solar_data/`
**Source**: [AP Systems EMA portal](https://www.apsystemsema.com) — login → Energy Report → Detail Daily Energy Report → Export
**Citation**: N/A — proprietary export from system monitoring portal
**Version / access date**: Exported on demand; filenames encode the date range
**Git-ignored**: No
**Wrangled by**: `scripts/wrangle_solar_data.R` → `outdata/solar_data.csv`

Weekly energy production reports for the 36-panel (12.96 kW) solar array installed
July 2022. Each file covers exactly 7 consecutive days of hourly data. Files should
be downloaded regularly and placed in this directory; `wrangle_solar_data.R` processes
all files present on each run.

**Filters applied by pipeline**: The "Total" row at the bottom of each sheet is removed.
All other rows (hours 0–23 for each of 7 days) are retained as-is.

#### Files

| Pattern | Example filename | Description |
|---|---|---|
| `216200061058 Detail Daily Energy Report YYYY-MM-DD to YYYY-MM-DD.xls` | `...2025-04-07 to 2025-04-13.xls` | One file per 7-day reporting period |

**Coverage**: July 8, 2022 – present (continuous weekly reports).
**Total files**: ~160+ and growing.

#### Column schema (each .xls file)

Each file is in **wide format**: one row per hour, one column per day.

| Column | Type | Units | Description | Nullable |
|---|---|---|---|---|
| `Hour` | integer | 24-hour clock | Hour of the day (0–23); last row is "Total" (removed by pipeline) | No |
| `YYYY-MM-DD(kWh)` | numeric | kWh | Energy produced during that hour on the given date; one such column per day (7 total) | Yes (0 at night) |

**Note**: Column headers include "(kWh)" appended to the date string (e.g., `2025-04-07(kWh)`).
The pipeline extracts the date from the first 10 characters of the column name.

---

### Fortis BC hourly electricity usage (current)

**Location**: `rawdata/fortis_data/`
**Source**: [Fortis BC customer portal](https://www.fortisbc.com) — My Account → Energy Use → Download
**Citation**: N/A — account data export
**Version / access date**: Exported on demand; filename encodes the date range
**Git-ignored**: No
**Wrangled by**: `scripts/wrangle_electricity_data.R` → `outdata/fortis_data.csv`

Hourly electricity delivery and return data from the Fortis BC smart meter, starting
June 1, 2022. "kWh delivered" is energy drawn from the grid; "kWh received" is solar
energy exported to the grid. Note that these portal figures may differ slightly from
billing calculations when the meter fails to communicate and Fortis estimates usage.

**Filters applied by pipeline**: Used as-is; no pipeline filtering applied.

#### Files

| File | Description |
|---|---|
| `June_01_2022_March_27_2026.csv` | Hourly usage from June 1, 2022 to present |

Replace this file with the most recent download from the Fortis portal to update the
analysis. If multiple files are present, the wrangling script reads them in reverse
order (a known workaround for a `readr` multi-file read issue) and drops the fifth column.

#### Column schema

| Column | Type | Units | Description | Nullable |
|---|---|---|---|---|
| `Date` | character | — | Date in `DD/MM/YYYY` format | No |
| `Time` | character | — | Hour in unusual format: integer (1–12) followed by `a.m.` or `p.m.` (e.g., `"2 p.m."`) | No |
| `kWh delivered` | numeric | kWh | Energy delivered from grid to household in that hour | Yes |
| `kWh received` | numeric | kWh | Energy returned from solar array to grid in that hour | Yes |

**Note**: Despite the variable names in the wrangled output (`kw_consumed`, `kw_returned`),
the raw values are in **kWh** (energy per hour interval), not instantaneous power in kW.

---

### Fortis BC billing history

**Location**: `rawdata/fortis_billing/`
**Source**: Manually transcribed from Fortis BC paper/email bills
**Citation**: N/A
**Git-ignored**: No
**Used by**: `index.Rmd` directly for billing summary tables and inline calculations

Billing summary records compiled manually from Fortis BC bi-monthly bills. These data
are used to track actual charges paid and to calculate net savings from the solar system.

#### Files

| File | Description |
|---|---|
| `billing_history.csv` | Bi-monthly billing periods with usage and payment amounts |
| `billing.csv` | [TODO: describe contents — appears to be a billing reference file] |
| `meter_paid.csv` | [TODO: describe contents — appears to record meter charges paid] |

#### Column schema — `billing_history.csv`

| Column | Type | Units | Description | Nullable |
|---|---|---|---|---|
| `read_date` | character | — | Meter read date in `MM/DD/YYYY` format (parsed to Date by pipeline) | No |
| `usage` | numeric | kWh | Total kWh billed for the period | Yes |
| `days` | integer | days | Number of days in the billing period | No |

**Note**: The pipeline derives `avg_per_day = usage / days` for trend plots.

---

### Fortis BC historical electricity usage (2019–2022)

**Location**: `rawdata/fortis_historical/`
**Source**: Fortis BC customer portal — historical export (one-time download)
**Citation**: N/A — account data export
**Version / access date**: Exported once; covers January 1, 2019 – May 31, 2022
**Git-ignored**: No
**Wrangled by**: `scripts/wrangle_historical_electricity_data.R` → `outdata/fortis_historical_data.csv`

Historical hourly electricity consumption data predating the solar installation. This
file provides a pre-solar baseline for the household's energy consumption going back
to January 2019. No solar return data exists for this period (`kw_returned` is set to
NA in the wrangled output).

**Filters applied by pipeline**: Used as-is; no pipeline filtering applied.

#### Files

| File | Description |
|---|---|
| `Jan_01_2019_May_31_2022_fortis.csv` | Hourly kWh delivered, Jan 1 2019 – May 31 2022 |

#### Column schema

| Column | Type | Units | Description | Nullable |
|---|---|---|---|---|
| `Date` | character | — | Date and time in `M/D/YYYY H:MM:SS AM/PM` format (e.g., `"1/1/2019 12:00:00 AM"`) | No |
| `kWh delivered` | numeric | kWh | Energy delivered from grid to household in that hour | Yes |

---

## Directory structure summary

```
rawdata/
├── DATA-DICTIONARY.md
├── solar_data/
│   └── 216200061058 Detail Daily Energy Report YYYY-MM-DD to YYYY-MM-DD.xls   (~160+ files)
├── fortis_data/
│   └── June_01_2022_March_27_2026.csv     # Current hourly usage from Fortis portal
├── fortis_billing/
│   ├── billing_history.csv                # Manually transcribed bi-monthly bills
│   ├── billing.csv                        # [TODO: describe]
│   └── meter_paid.csv                     # [TODO: describe]
└── fortis_historical/
    └── Jan_01_2019_May_31_2022_fortis.csv  # Historical hourly usage (pre-solar)
```
