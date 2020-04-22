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

# f1 <- list.files("output/2020-04-19", full.names = F)
# f2 <- str_sub(f1, start = 2)
# 
# f1 <- str_c("output/2020-04-19/", f1)
# f2 <- str_c("output/2020-04-19/", f2)
# 
# head(f1)
# head(f2)
# 
# file.copy(f1, f2)

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

# Scraping links
table_of_output <- read_csv("output/2020-04-19/table-of-output.csv")
scraped_links = proc_links_and_attachments(table_of_output, "2020-04-19")
