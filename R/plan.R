source("R/packages.R")  # Load your packages, e.g. library(drake).
source("R/functions.R") # Define your custom code as a bunch of functions.

my_date = "2020-04-25"

search_term = c("covid*", "coron*", "closure")

processed_data = read_data('district-data-to-scrape.csv')

my_date_proc = proc_my_date(my_date)

table_of_output = scrape_and_process_sites(
  my_date_proc, 
  list(processed_data$district,
       processed_data$state,
       processed_data$nces_id,
       processed_data$url),
  search_term = search_term)

table_of_output_processed = proc_table_of_output(table_of_output)

scraped_links = proc_links_and_attachments(table_of_output_processed, 
                                           my_date,
                                           which_to_scrape = "both")