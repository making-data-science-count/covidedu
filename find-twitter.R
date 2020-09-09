# find-twitter

library(rvest)
library(tidyverse)

district_data_to_scrape <- read_csv("data/district-data-to-scrape.csv")

x <- district_data_to_scrape %>% filter(agency_type_district_2017_18 == "1-Regular local school district that is NOT a component of a supervisory union")

files <- list.files("output/2020-04-29/homepages/", full.names = TRUE)

f <- function(x) {
  link <- read_html(x) %>% 
    html_nodes("a") %>% 
    html_attr("href")
  
  id <- str_sub(x, start = -11, end = -5)
  
  data.frame(link = link, nces_id = id)
}

all_links <- files %>% 
  map(possibly(f, otherwise = data.frame(link = NA, nces_id = NA)))

all_links_df <- all_links %>% 
  map_df(~.) %>% 
  as_tibble() %>% 
  filter(!is.na(link), !is.na(nces_id)) %>% 
  mutate(link = tolower(link)) %>% 
  filter(str_detect(link, "twitter"))

all_links_df$username <- all_links_df$link %>% 
  str_extract_all("((https?://)?(www\\.)?twitter\\.com/)?(@|#!/)?([A-Za-z0-9_]{1,15})(/([-a-z]{1,20}))?") %>% 
  map(~.[[1]]) %>% 
  str_split("com/") %>% 
  map(possibly(~.[[2]], NULL)) %>% 
  str_remove("/status")

unique(all_links_df$username) %>% length() # n links
unique(all_links_df$username) %>% length() / length(files)

all_links_df %>% 
  distinct(username, .keep_all = TRUE) %>% 
  left_join(district_data_to_scrape) %>% 
  filter(!is.null(username),
         username != "NULL") %>% 
  mutate(username = str_remove(username, "@"),
         username = str_remove(username, "#!/")) %>% 
  mutate(processed_link = str_c("https://twitter.com/", username)) %>% 
  select(link, processed_link, everything()) %>% 
  write_csv("twitter-accounts-from-district-homepages.csv")

# for all SM

all_links_all_df <- all_links %>% 
  map_df(~.) %>% 
  as_tibble() %>% 
  filter(!is.na(link), !is.na(nces_id)) %>% 
  mutate(link = tolower(link)) %>% 
  mutate(twitter = str_detect(link, "twitter"),
         facebook = str_detect(link, "facebook"),
         instagram = str_detect(link, "instagram"),
         pinterest = str_detect(link, "pinterest"))

all_links_all_df %>% 
  select(nces_id, twitter:pinterest) %>% 
  group_by(nces_id) %>% 
  summarize_all(list(any_true = any)) %>% 
  select(-nces_id) %>%
  summarize_all(list(sum = sum)) %>% 
  gather(key, val) %>% 
  mutate(prop = val/nrow(district_data_to_scrape)) %>% 
  arrange(desc(prop))

district_data_to_merge <- tibble(nces_id = district_data_to_scrape$nces_id)
district_data_to_merge$frpl <- as.numeric(district_data_to_scrape$free_and_reduced_lunch_students_public_school_2017_18)/
  as.numeric(district_data_to_scrape$total_students_all_grades_excludes_ae_district_2017_18)

corrf <- function(x) {
  x %>% 
    select(frpl, val) %>% 
    corrr::correlate()
}

all_links_all_df %>% 
  select(nces_id, twitter:pinterest) %>% 
  group_by(nces_id) %>% 
  summarize_all(list(any_true = any)) %>% 
  left_join(district_data_to_merge) %>% 
  #mutate(frpl = ifelse(frpl > .5, 1, 0)) %>% 
  select(contains("_any_true"), frpl) %>% 
  mutate_if(is.logical, as.integer) %>% 
  gather(key, val, -frpl) %>% 
  split(.$key) %>% 
  map(corrf)

# twitter_accounts %>% 
#   str_extract_all("((https?://)?(www\.)?twitter\.com/)?(@|#!/)?([A-Za-z0-9_]{1,15})(/([-a-z]{1,20}))?")
# 
# accounts_a <- twitter_accounts %>% 
#   str_remove("@") %>% 
#   str_remove("https://twitter.com/") %>% 
#   str_remove("https://twitter.com/") %>% 
#   str_remove("http://twitter.com/") %>% 
#   str_remove("https://www.twitter.com/") %>% 
#   str_remove("http://www.twitter.com/") %>% 
#   str_remove("https://twitter.com")
# 
# # matching to NCES ID
# 
# twitter_accounts %>% length()
# accounts_a %>% length()
# 
# accounts_a %>% 
#   str_extract("^(.+?)?")
# 
# accounts <- accounts_a[!str_detect(accounts_a, "http")]
# accounts <- accounts[!str_detect(accounts, "statuses")]
# accounts <- accounts[!str_detect(accounts, "/")]
# accounts <- accounts[!str_detect(accounts, "container")]
# 
# accounts %>% length()
# 
# 
# a <- rtweet::lookup_users(accounts)
# adf <- rtweet::flatten(a)
# write_csv(adf, "~/documents/possible-accounts-from-districts.csv")
# 
# read_csv("~/documents/possible-accounts-from-districts.csv")
# 
# already_exists <- 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSpR47K9kXJCJ1kOSeXpFkcDprZYSWW7d7nkWva8ldb6SaFLpkc_o6kwGBnOVWYwdWrtF5dqsi3dOST/pub?output=csv' %>% 
#   read_csv()
# 
# proc_already_exists <- already_exists %>% 
#   pull(screen_name) %>% 
#   tolower()
#   
# proc_already_exists %in% tolower(a$screen_name) %>% 
#   table()
# 
# 
# v_links <- all_links %>% unlist()
# v_links <- v_links[!is.na(v_links)]
# contains_twitter <- str_detect(v_links, "facebook")
# 
# twitter_accounts <- v_links[contains_twitter] %>% 
#   unique() %>% 
#   tolower()
# 
# accounts <- twitter_accounts %>% 
#   # str_remove("@") %>% 
#   # str_remove("https://facebook.com/") %>% 
#   # str_remove("https://facebook.com/") %>% 
#   # str_remove("http://facebook.com/") %>% 
#   # str_remove("https://www.facebook.com/") %>% 
#   # str_remove("http://www.facebook.com/") %>% 
#   # str_remove("https://www.facebook.com/#") %>% 
#   # str_remove("http://www.facebook.com/#") %>%
#   unique()
# 
# length(accounts)
# 
#  accounts
#   
# 
