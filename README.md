# covid-edu

## Background

This project is named {covidedu} because it was intended to be used to understand districts' responses to the COVID-19 pandemic.

The districts' websites were obtained primarily through the [National Center for Education Statistics], though this data only includes links for approximately 2/3 of districts, and so this data was augmented with data collected from other automated and manual means.

But, it can also be used to programmatically access other information from districts by changing the `search_term` (which defaults to `c("covid*", "corona*", "closure")`, but can easily be changed; see details in the how to use section below).

## Required packages

All of the required packages are listed in [`R/packages.R`](R/packages.R).

## How to use

1. Set two key parameters to set in [`R/plan.R`](R/plan.R):

- `my_date` (defaults to today's date if not changed, but can be changed for use in certain cases, e.g. if the scraper fails and you want to maintain the same file structure (which includes the date))
- `search_term` a character vector with one or more search terms; used as a regular expression, so e.g. wildcards are supported

2. To run the web-scraper, run the contents of [`R/plan.R`](R/plan.R). This may take a considerable period of time; if the scraper is halted, it can be re-started without re-downloading data (so long as `my_date` is the same for all of the data for the same data collection)

## Output

When complete, output will be in the sub-directory of the `output` directory with the value of `my_date` (e.g., `output/2020-04-26/`). 

### The results of programatically accessing districts' websites

- `homepages` (the XML for districts' homepages)
- `links` (XML pages containing any pages linked from districts' homepages containing the search term [either the link text or the underlying hyperlink])
- `attachments` (any PDF, PNG, DOC, or DOCX files linked from districts' homepages containing the search term [either the link text or the underlying hyperlink])

### Summary statistics

- `summary_of_table_of_links` (summary statistics for the districts for which sraping was successful; as of 2020-04-26, approximately 92% of districts' websites were accessible, and so this table should include rows for 92% of the districts with data available from the NCES)
- `scraped_links` (summary statistics for the links and attachents)
