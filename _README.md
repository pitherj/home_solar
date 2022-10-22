# home_solar

This site describes an extra-curricular project: analysing our home energy consumption and solar production data.

The 

The repository includes the following folders:

/scripts
/rawdata
/outdata
/images

The "scripts" folder includes the main R Markdown script that generates the project webpage.

The "rawdata" folder includes:  
- the raw data files downloaded from the [AP Systems website](https://www.apsystemsema.com)
  - these are in Excel format, are in "wide" format, include hourly energy production data
  - they each include 7 days of hourly data, and filenames include date ranges
- the raw data files downloaded from the [Fortis BC](https://www.fortisbc.com)
  - these are in CSV format, are in "long" format
  - they include 60 days of hourly data
  - filenames are generic
  
The "outdata" folder includes any output from data wrangling/analysis.
 
The "images" folder includes some pictures of our solar array for reference.

## Data dictionary

### Solar data

The raw Excel files downloaded from the AP Systems portal include the following:

"Hour" - the hour of the data (24h), integer value

Then seven columns, each holding one day of data, with the column heading being the date (YYYY-MM-DD), with "(kWh)" appended at the end

The last row in each data file includes a "total" row.  This will be eliminated.

### Energy consumption data

The raw CSV files downloaded from the Fortis portal include the following:

"Date" in DD/MM/YYYY format
"Time" : hourly, in integer format with "a.m." or "p.m." appended (!!)
"kWh delivered": numeric variable describing energy delivered to house from grid
"kWh received": numeric variable describing energy delivered to grid from solar


