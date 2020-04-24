# plan = drake_plan(
#   processed_data = read_data(file_in('district-data-to-scrape.csv')),
# 
#   table_of_output = scrape_and_process_sites(
#     list("2020-04-20",
#          processed_data$district,
#          processed_data$state,
#          processed_data$nces_id,
#          processed_data$url)),
#   
#   scraped_links = proc_links_and_attachments(table_of_output, "2020-04-20")
#   
# )

source("R/packages.R")  # Load your packages, e.g. library(drake).
source("R/functions.R") # Define your custom code as a bunch of functions.

# Scraping homepages
processed_data = read_data(file_in('district-data-to-scrape.csv'))

table_of_output = scrape_and_process_sites(
    list("2020-04-19",
         processed_data$district,
         processed_data$state,
         processed_data$nces_id,
         processed_data$url))

write_csv(select(table_of_output, -link), "output/2020-04-19/table-of-output-no-links.csv")

table_of_output <- table_of_output %>%
  mutate(link = map(link, ~as.character(.))) %>%
  unnest(link)

write_csv(table_of_output, "output/2020-04-19/table-of-output.csv")

# Processing links and attachments
table_of_output <- read_csv("output/2020-04-19/table-of-output.csv")
table_of_output

table_of_output <- read_csv("output/2020-04-19/table-of-output.csv")
table_of_output <- table_of_output %>% 
  group_by(district_name, state, nces_id) %>% 
  mutate(page_number = row_number())

scraped_links = proc_links_and_attachments(table_of_output, "2020-04-19", which_to_scrape = "attachments")

pdf_f <- list.files("output/2020-04-19/attachments", full.names = T)

l <- map(pdf_f, possibly(pdf_text, NULL))

names(l) <- pdf_f

pdf_d <- l %>% 
  map_df(~.)
