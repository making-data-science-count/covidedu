library(tidyverse)

d <- read_csv("output/2020-04-19/table-of-output-no-links.csv")

d %>% 
  janitor::tabyl(scraping_failed)

d %>% 
  mutate(mentioned_any = ifelse(corona | covid | closure, 1, 0)) %>% 
  janitor::tabyl(mentioned_any)

d %>% 
  mutate(mentioned_any = ifelse(corona | covid, 1, 0)) %>% 
  janitor::tabyl(mentioned_any)

d %>% 
  distinct(nces_id, .keep_all = T)

d %>% 
  janitor::tabyl(corona)

d %>% 
  janitor::tabyl(covid)

d %>% 
  janitor::tabyl(closure)

district_data_to_scrape <- read_csv("district-data-to-scrape.csv")

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>% 
  setView(-97, 39, zoom = 4) %>% 
  addCircleMarkers(data = district_data_to_scrape,
                   radius = .5,
                   fillOpacity = .5,
                   #layerId = ~ncessch,
                   lng = ~longitude_district_2017_18,
                   lat = ~latitude_district_2017_18,
                   label = ~lapply(district, htmltools::HTML),
                   popup = ~lapply(district, htmltools::HTML))
