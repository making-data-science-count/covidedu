library(shiny)
library(leaflet)
library(readr)

d <- read_csv("data-for-shiny.csv")

ui <- fluidPage(
  h2("U.S. School Districts' Responses to COVID-19"),
  p("This map represents an attempt to document U.S. school districts' responses to the COVID-19 pandemic."),
  leafletOutput("mymap"),
  p(),
  p("All of the data used is available for use and re-use at https://github.com/making-data-science-count/covidapp)."),
  p("Created by the Making Data Science Count Research Group at the University of Tennessee, Knoxville.")
)

server <- function(input, output, session) {
  
  # points <- eventReactive(input$recalc, {
  #   cbind(rnorm(40) * 2 + 13, rnorm(40) + 48)
  # }, ignoreNULL = FALSE)
  # 
  output$mymap <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>% 
      setView(-97, 39, zoom = 4) %>% 
      addCircleMarkers(data = d,
                       radius = .1,
                       fillOpacity = .5,
                       #layerId = ~ncessch,
                       lng = ~longitude_district_2017_18,
                       lat = ~latitude_district_2017_18,
                       label = ~lapply(district, htmltools::HTML),
                       popup = ~lapply(text_to_display, htmltools::HTML),
                       labelOptions = labelOptions(style = list(
                         "color" = "black",
                         "font-size" = "13px"
                       )))
  })
}

shinyApp(ui, server)