source("R/packages.R")
source("R/functions.R")

# if scraping takes more than one day, it may be helpful to manually specify a date
my_date = ""

search_term = c("covid*", "coron*", "closure")

processed_data = read_data('district-data-to-scrape.csv')

# all states
processed_data %>% 
  count(state)

# select certain states
processed_data <- processed_data %>% 
  filter(state %in% c(c("alabama", "alaska", "arizona", "arkansas", "california", 
                        "colorado", "connecticut", "delaware", "district of columbia", 
                        "florida", "georgia", "hawaii", "idaho", "illinois", "indiana", 
                        "iowa", "kansas", "kentucky", "louisiana", "maine", "maryland", 
                        "massachusetts", "michigan", "minnesota", "mississippi", "missouri",
                        "montana", "nebraska", "nevada", "new hampshire", "new jersey", 
                        "new mexico", "new york", "north carolina", "north dakota", "ohio", 
                        "oklahoma", "oregon", "pennsylvania", "rhode island", "south carolina", 
                        "south dakota", "tennessee", "texas", "utah", "vermont", "virginia",
                        "washington", "west virginia", "wisconsin", "wyoming")))

my_date_proc = proc_my_date(my_date)

table_of_output = scrape_and_process_sites(
  my_date_proc, 
  list(processed_data$district,
       processed_data$state,
       processed_data$nces_id,
       processed_data$url),
  search_term = search_term)

table_of_links_proc = proc_table_of_output(table_of_output)
 
summary_of_table_of_links = create_summary_table(table_of_output)

write_csv(summary_of_table_of_links, str_c("output/", my_date, "/summary-of-table-of-links.csv"))

scraped_links = proc_links_and_attachments(table_of_links_proc, 
                                           my_date,
                                           which_to_scrape = "both") # scrape links and attachments

write_csv(scraped_links, str_c("output/", my_date, "/summary-of-scraped-links.csv"))

# summary stats
t <- tibble(nces_id = processed_data$nces_id,
       scraping_succeeded = processed_data$nces_id %in% summary_of_table_of_links$nces_id)

t %>% 
  tabyl(scraping_succeeded)
