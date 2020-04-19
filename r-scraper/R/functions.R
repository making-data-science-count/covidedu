read_data <- function(f) {
  
  d <- read_csv(f)
  
  d <- d %>% filter(`website-url` != "NA")
  
  d <- rename(d, 
              district = "district-name",
              nces_id = "nces-id",
              website_url = "website-url")
  
  d <- d %>% 
    arrange(state, district)
  
  d
}

detector <- function(x) {
  str_detect(x, "coron*") |
    str_detect(x, "covid*") |
      str_detect(x, "closure")
}

access_site <- function(date, name, state, id, url, f) {
  
  h <- url %>% 
    read_html()
  
  base_dir <- str_c("output/", Sys.Date(), "/")
  
  file_name <- str_c(base_dir, "-", state, "-", name, "-", id, ".xml")
  
  write_xml(h, file_out(file_name))
  
  t <- h %>% 
    html_text()
  
  links <- h %>% 
    html_nodes("a")
  
  corona <- str_detect(tolower(t), "corona*")
  covid <- str_detect(tolower(t), "covid*")
  closure <- str_detect(tolower(t), "closure")
  
  link_found <- links %>% 
    html_text() %>% 
    tolower() %>% 
    detector() %>% 
    any()
  
  link_logical_to_index <- links %>% 
    html_text() %>%
    tolower() %>%
    detector()
  
  link_urls <- links %>%
    rvest::html_attr("href") %>% 
    str_c(url, .)
  
  link_urls <- link_urls[link_logical_to_index]
  
  print(str_c("Processed ", name, " (", state, ") --- corona = ", corona, "; covid = ", covid, "; closure = ", closure, ", LINK FOUND: ", link_found))
  
  tibble(district_name = name, state = state, nces_id = id, url = url, 
         corona = corona, covid = covid, closure = closure,
         scraping_failed = FALSE, 
         link_found = link_found, 
         link = list(link_urls))
  
}

scrape_and_process_sites <- function(list_of_args) {
  
  base_dir_exists <- fs::dir_exists(str_c("output/", Sys.Date(), "/"))
  
  if (!base_dir_exists) {
    fs::dir_create(str_c("output/", Sys.Date(), "/"))
  }
  
  output <- pmap(list(date = list_of_args[[1]], 
                      name = list_of_args[[2]], state = list_of_args[[3]],
                      id = list_of_args[[4]], url = list_of_args[[5]]), 
                 possibly(access_site,
                          otherwise = tibble(district_name = NA, 
                                             state = NA, 
                                             nces_id = NA, 
                                             url = NA, 
                                             corona = NA,
                                             covid = NA,
                                             closure = NA,
                                             scraping_failed = TRUE, 
                                             link_found = NA,
                                             link = NA)))
  
  output_df <- map_df(output, ~.)
  
  return(output_df)
  
}

# proc_xml <- function(f) {
#   
#   h <- f %>%
#     read_html()
#   
#   t <- h %>% 
#     html_text()
#   
#   links <- h %>% 
#     html_nodes("a")
#   
#   corona <- str_detect(tolower(t), "corona*")
#   covid <- str_detect(tolower(t), "covid*")
#   
#   link_found <- links %>% 
#     html_text() %>% 
#     tolower() %>% 
#     detector() %>% 
#     any()
#   
#   link_text <- links %>% 
#     html_text() %>%
#     tolower()
#   
#   link_logical_to_index <- link_text %>% 
#     detector()
#   
#   link_urls <- links %>%
#     rvest::html_attr("href") %>% 
#     as.character()
#   
#   link_urls <- link_urls[link_logical_to_index]
# 
#   tibble(district_name = f,
#          corona = corona, covid = covid,
#          link_found = link_found, link = list(link_urls))
#   
# }