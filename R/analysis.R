library(tidyverse)
library(leaflet)

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

d <- d %>%
  select(nces_id, url, corona, covid, closure, scraping_failed)

dd <- district_data_to_scrape %>%
  left_join(d)

dlong <- read_csv("output/2020-04-19/table-of-output.csv")

dlong <- dlong %>% group_by(district_name, state, nces_id) %>% 
  summarize(link_string = toString(link),
            n_links = n())

dd<- dd %>%
  left_join(dlong)

dd <- dd %>% 
  mutate(scraping_failed = ifelse(is.na(scraping_failed), TRUE, scraping_failed)) %>% 
  mutate(covid_or_corona = ifelse(covid | corona, TRUE, FALSE)) %>%
  mutate(date_accessed = ifelse(!scraping_failed, "2020-04-19", "<em>Scraping failed</em>")) %>%
  mutate(district = tools::toTitleCase(district))

dd %>% 
  select(district:url, corona:n_links)

dd %>% 
  count(scraping_failed, covid_or_corona)

dd <- dd %>% 
  mutate(text_to_display = paste("<b><a href='", url, "'>", district, "</a></b> (", 
                                 tools::toTitleCase(state),")<br/>",
                                 "Site was last accessed: ", date_accessed, "<br/>",
                                 "COVID-19 mentioned on site: ", covid_or_corona, "<br/>",
                                 "Closure mentioned on site: ", closure, "<br/>",
                                 # "<hr/>",
                                 "No. of links mentioning COVID-19 or closure: ", n_links),
         n_links = ifelse(is.na(n_links) & !scraping_failed, 0, n_links)
  )

write_csv(dd, "data-for-shiny.csv")
write_csv(dd, "../covidapp/data-for-shiny.csv")

# leaflet() %>%
#   addProviderTiles("CartoDB.Positron") %>%
#   setView(-97, 39, zoom = 4) %>%
#   addCircleMarkers(data = dd,
#                    radius = .1,
#                    fillOpacity = .5,
#                    #layerId = ~ncessch,
#                    lng = ~longitude_district_2017_18,
#                    lat = ~latitude_district_2017_18,
#                    label = ~lapply(district, htmltools::HTML),
#                    popup = ~lapply(text_to_display, htmltools::HTML),
#                    labelOptions = labelOptions(style = list(
#                      "color" = "black",
#                      "font-size" = "13px"
#                    )))
