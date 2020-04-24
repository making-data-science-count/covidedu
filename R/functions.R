read_data <- function(f) {
  
  d <- read_csv(f)
  
  d <- d %>% 
    arrange(state, district)
  
  d
}

access_site <- function(my_date, name, state, id, url, search_term) {
  
  base_dir <- str_c("output/", my_date, "/homepages/")
  
  file_path <- str_c(base_dir, state, "-", name, "-", id, ".xml")
  
  if (fs::file_exists(file_path)) {
    
    print(str_c(state," ", name, " already exists; reading instead"))
    
    h <-  read_html(file_path)
    
  } else {
    h <- read_html(url)
    
    write_xml(h, file_path)
  }
  
  t <- h %>%
    html_text()
  
  links <- h %>%
    html_nodes("a")
  
  search_term_found <- any(str_detect(tolower(t), search_term))
  
  link_found <- links %>%
    html_text() %>%
    tolower() %>%
    any(str_detect(., search_term)) %>%
    any()
  
  link_logical_to_index <- links %>%
    html_text() %>%
    tolower() %>%
    any(str_detect(., search_term)) 
  
  link_urls <- links %>%
    rvest::html_attr("href")
  
  # adding base
  link_urls <- ifelse(str_detect(link_urls, "http"), link_urls, str_c(url, link_urls))
  
  link_urls <- link_urls[link_logical_to_index]
  
  print(str_c("Processed ", base_dir, "-", state, "-", name, "-", id, "; ",
              "found ", search_term, ": ", str_detect(tolower(t), search_term)))
  
  tibble(district_name = name, state = state, nces_id = id, url = url,
         search_term_found = search_term,
         scraping_failed = FALSE,
         link_found = link_found,
         link = list(link_urls))
  
}

scrape_and_process_sites <- function(my_date, list_of_args, search_term) {
  
  base_dir_exists <- fs::dir_exists(str_c("output/", list_of_args[[1]], "/"))
  
  if (!base_dir_exists) {
    fs::dir_create(str_c("output/", my_date, "/"))
    fs::dir_create(str_c("output/", my_date, "/homepages"))
  }
  
  output <- pmap(list(my_date = my_date, 
                      name = list_of_args[[1]], state = list_of_args[[2]],
                      id = list_of_args[[3]], url = list_of_args[[4]]), 
                 search_term = search_term, 
                 possibly(access_site,
                          otherwise = tibble(district_name = NA, 
                                             state = NA, 
                                             nces_id = NA, 
                                             url = NA, 
                                             search_term_found = NA,
                                             scraping_failed = TRUE, 
                                             link_found = NA,
                                             link = NA)))
  
  output_df <- map_df(output, ~.)
  
  return(output_df)
  
}

download_link <- function(link, district, state, nces_id, my_date, page_number) {
  print(str_c("processing link", link, "from ", nces_id))
  h <- read_html(link)
  
  base_dir <- str_c("output/", my_date, "/links/")
  
  f <-str_c(base_dir, "LINK-", state, "-", district, "-", nces_id, "-",page_number,".xml")
  
  if (!fs::file_exists(f)) {
    write_xml(h, f)
    print("downloaded xml")
  } else {
    print("already have, skipping")
  }
  tibble(link = link, district = district, state = state, nces_id = nces_id, page_number = page_number, type = "LINK", found = TRUE)
}

download_attachment <- function(link, district, state, nces_id, page_number, my_date) {
  print(str_c("processing attachment", link, "from ", nces_id))
  file_ext <- tools::file_ext(link)
  base_dir <- str_c("output/", my_date, "/attachments/")
  
  f <-str_c(base_dir, "ATTACHMENT-", state, "-", district, "-", nces_id, "-",page_number, ".", file_ext)
  if (!fs::file_exists(f)) {
    download.file(link, destfile = f)
    print("downloaded ", file_ext)
  } else {
    print("already have, skipping")
  }
  tibble(link = link, district = district, state = state, nces_id = nces_id, page_number = page_number, type = "ATTACHMENT", found = TRUE)
}

proc_links_and_attachments <- function(table_of_output, my_date, which_to_scrape = "both") {
  if (!fs::dir_exists(str_c("output/", my_date, "/links"))) fs::dir_create(str_c("output/", my_date, "/links"))
  if (!fs::dir_exists(str_c("output/", my_date, "/attachments"))) fs::dir_create(str_c("output/", my_date, "/attachments"))
  
  # table_of_output <- table_of_output %>% 
  #   unnest(link)
  
  table_of_output$file_ext <- tools::file_ext(table_of_output$link)
  
  attachments <- filter(table_of_output, file_ext %in% c("pdf", ".docx", ".png", ".doc"))
  all_other <- filter(table_of_output, !file_ext %in% c("pdf", ".docx", ".png", ".doc"))
  
  if (which_to_scrape == "attachments" | which_to_scrape == "both") {
    attachment_output <- pmap(list(link = attachments$link,
                                   district = attachments$district_name, 
                                   state = attachments$state,
                                   nces_id = attachments$nces_id,
                                   my_date = my_date,
                                   page_number = attachments$page_number),
                              possibly(download_attachment,
                                       otherwise = tibble(link = NA, district = NA, state = NA, nces_id = NA, 
                                                          page_number = NA,
                                                          type = "ATTACHMENT", found = FALSE)))
    
  }
  
  if (which_to_scrape == "links") {
    
    link_output <- pmap(list(link = all_other$link,
                             district = all_other$district_name, 
                             state = all_other$state,
                             nces_id = all_other$nces_id,
                             my_date = my_date,
                             page_number = all_other$page_number),
                        possibly(download_link,
                                 otherwise = tibble(link = NA, district = NA, state = NA, nces_id = NA, 
                                                    page_number = NA,
                                                    type = "LINK", found = FALSE)))
    output_df <- map_df(link_output, ~.)
    
  }
  attachment_df <- map_df(attachment_output, ~.)
  
  if (which_to_scrape == "both") {
    return(list(output_df, attachment_df))
  } else if (which_to_scrape == "attachments") {
    return(attachment_df)
  } else {
    return(output_df)
  }
}
# testing
# proc_links_and_attachments(table_of_output[1:10, ], my_date = Sys.Date())
