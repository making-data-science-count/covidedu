# covid-edu

## Background

While this project is named {covidedu} because it was intended to be used to understand districts' responses to the COVID-19 pandemic, it can also be used to programmatically access other information from districts by changing the `search_term` (see more below).

## Required packages

All of the required packages are listed in [`R/packages.R`](R/packages.R).

## How to use

1. Set two key parameters to set in [`R/plan.R`](R/plan.R):

- `my_date` (defaults to today's date if not changed, but can be changed for use in certain cases, e.g. if the scraper fails and you want to maintain the same file structure (which includes the date))
- `search_term` a character vector with one or more search terms; used as a regular expression, so e.g. wildcards are supported

2. To run the web-scraper, run the contents of [`R/plan.R`](R/plan.R). This may take a considerable period of time; if the scraper is halted, it can be re-started without re-downloading data (so long as `my_date` is the same for all of the data for the same data collection)

