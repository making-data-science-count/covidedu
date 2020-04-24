# covid-edu

This project uses [{drake}](https://github.com/ropensci/drake) to facilitate the reproducibility of the analysis. While it is named {covidedu} because it was intended to be used to understand districts' responses to the COVID-19 pandemic, it can also be used to programmatically access other information from districts by changing the `search_term` (see more below).

## Required packages

All of the required packages are listed in [`R/packages.R`](R/packages.R).

## Parameters

There are two key parameters to set in [`R/plan.R`](R/plan.R):

- `my_date` (defaults to today's date, but can be changed for use in certain cases, e.g. if the scraper fails and you want to maintain the same file structure (which includes the date))
- `search_term` a character vector with one or more search terms; used as a regular expression, so e.g. wildcards are supported

## How to run

To run the web-scraper, run either:

- the contents of [`R/make.R`](R/make.R)
- or `drake::r_make()`
