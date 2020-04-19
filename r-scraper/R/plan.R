plan = drake_plan(
  processed_data = read_data(file_in('district-data-to-scrape.csv')),

  table_of_output = scrape_and_process_sites(
    list(Sys.Date(),
         processed_data$district,
         processed_data$state,
         processed_data$nces_id,
         processed_data$website_url
    )),
  
  analysis = rmarkdown::render(
    knitr_in("analysis.Rmd"),
    output_file = file_out("docs/analysis.html")
  ),
)