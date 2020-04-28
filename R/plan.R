source("R/packages.R")
source("R/functions.R")

my_date = "2020-04-25"

search_term = c("covid*", "coron*", "closure")

processed_data = read_data('district-data-to-scrape.csv')

# just for testing
processed_data <- processed_data[1:25, ]

my_date_proc = proc_my_date(my_date)

table_of_output = scrape_and_process_sites(
  my_date_proc, 
  list(processed_data$district,
       processed_data$state,
       processed_data$nces_id,
       processed_data$url),
  search_term = search_term)

table_of_links_proc = proc_table_of_output(table_of_output)
 
summary_of_table_of_links = create_summary_table(table_of_links_proc)

write_csv(summary_of_table_of_links, str_c("output/", my_date, "summary_of_table_of_links.csv"))

scraped_links = proc_links_and_attachments(table_of_links_proc, 
                                           my_date,
                                           which_to_scrape = "both")

write_csv(scraped_lnks, str_c("output/", my_date, "scraped_links.csv"))

# summary stats
t <- tibble(nces_id = processed_data$nces_id,
       scraping_succeeded = processed_data$nces_id %in% summary_of_table_of_links$nces_id)

t %>% 
  tabyl(scraping_succeeded)
