plan = drake_plan(
  processed_data = read_data(file_in('district-data-to-scrape.csv')),

  table_of_output = scrape_and_process_sites(
    list("2020-04-20",
         processed_data$district,
         processed_data$state,
         processed_data$nces_id,
         processed_data$url)),
  
  scraped_links = proc_links_and_attachments(table_of_output, "2020-04-20")
  
)