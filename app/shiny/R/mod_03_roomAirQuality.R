
# ======================================================================

# ======================================================================

roomAirQualityModuleUI <- function(id) {
  #' Comfort Air Quality UI
  #'
  #' User-Interface
  #' @param id id for ns()
  #' @export
  #' @author Reto Marek
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Room > Air Quality",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        # air quality classes according to EN 16798
        box(
          width = 2,
          numericInput(ns("iAQual1"), "Zone I (ppm)", min = 400, max = 2000, value = 1050, step = 50, width = "150px"),
        ),
        box(
          width = 2,
          numericInput(ns("iAQual2"), "Zone II (ppm)", min = 400, max = 2000, value = 1300, step = 50, width = "150px"),
        ),
        box(
          width = 2,
          numericInput(ns("iAQual3"), "Zone III (ppm)", min = 400, max = 4000, value = 1850, step = 50, width = "150px")
        )
      )
    ),
    tabsetPanel(
      id = "roomAirQualityTab",
      tabPanel("Overview",
               fluidRow(
                 box(
                   status="primary",
                   width = 2,
                   inputPanel(
                     sliderInput(inputId = ns("slider"),
                                 label = "Time Range",
                                 min = as.Date("2019-01-01"),
                                 max = as.Date("2020-01-01"),
                                 value = c(as.Date("2019-03-01"), as.Date("2019-09-01")),
                                 timeFormat = "%b %Y"
                     )
                   )
                 ),
                 box(
                   status="primary",
                   width = 10,
                   plotlyOutput(ns("aQualPlots"), height = "auto")
                 )
               )
      ),
      tabPanel("Info",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","roomAirQuality.md"))
                   )
                 )
               )
      )
    ),
    fluidRow(
      box(
        status="primary",
        width = 12,
        column(
          width = 12,
          includeMarkdown(here::here("docs", "docs", "interpretation","roomAirQuality.md"))
        )
      )
    )
  )
}

roomAirQualityModule <- function(input, output, session, aggData) {
  #' Comfort Air Quality
  #'
  #' Server-function
  #' @param filename a String representing the filename inclusive extension.
  #' @export
  #' @author Reto Marek
  # date range slider
  sliderDate <- reactiveValues()
  
  observe({
    start <- as.POSIXct(input$slider[1], tz="Europe/Zurich")
    end <- as.POSIXct(input$slider[2], tz="Europe/Zurich")
    sliderDate$start <- as.character(start)
    sliderDate$end <- as.character(end)
  })
  
  observe({
    dates <- df.all() %>% select(time) %>% arrange(time)
    start <- as.Date(dates[1,1], tz = "Europe/Zurich")
    end <- as.Date(dates[nrow(dates),1], tz = "Europe/Zurich")
    updateSliderInput(session,
                      "slider",
                      min = start,
                      max = end,
                      value = c(start, end)
    )
  })
  
  
  df.all <- reactive({
    withProgress(message = 'Calculating data', detail = "air quality plot", value = NULL, {
      req(aggData)
      
      data <- aggData %>% filter(dpType == "aQualRoom")
      # rename columns for plot title, not nice solution, but it works ;-)
      data <- data %>% mutate(room = paste0(flat," - ", room))
      
      # calculate indoor air quality class
      data <- data %>% mutate(iAQual =if_else(value < input$iAQual1,"1", 
                                             if_else(value < input$iAQual2,"2", 
                                                     if_else(value < input$iAQual3,"3", "4"))))
    })
    return(data)
  })
  
  # # filter according to room selection
  # df.room <- reactive({
  #   df.all() %>% filter(room == input$room)
  # })
  
  # filter according to time slider settings
  df <- reactive({
    data <- df.all() %>% filter(time >= sliderDate$start & time <= sliderDate$end)
    # renaming names for proper hovertips
    colnames(data)[1] <- "Date"
    colnames(data)[2] <- "CO2"
    return(data)
  })
  
  numRooms <- reactive({
    df.all() %>% select(room) %>% unique() %>% nrow()
  })
  
  plotHeight <- function(listNumRow) {
    # calculate values$facetCount
    rows <- ceiling(listNumRow/3)
    if(rows == 1){
      switch(listNumRow,
             {height = 500},
             {height = 450},
             {height = 350}
      )
    }
    else {
      height <- rows * 250
    }
    return(height)
  }
  
  # Generate Plot
  output$aQualPlots <- renderPlotly({
    # Create a Progress object
    withProgress(message = 'Creating plot', detail = "air quality plot", value = NULL, {
      start <- as.POSIXct(sliderDate$start, tz="Europe/Zurich")
      end <- as.POSIXct(sliderDate$end, tz="Europe/Zurich")
      co2MaxVal <- max(df() %>% select(CO2) %>% max(),input$iAQual4)
      
      # aQualZones <- data.frame(yMin = c(0,input$iAQual1, input$iAQual2, input$iAQual3, input$iAQual4),
      #                          yMax = c(input$iAQual1, input$iAQual2, input$iAQual3, input$iAQual4, co2MaxVal + 200 ),
      #                          xMin = rep(start, 5),
      #                          xMax = rep(end, 5)
      #                          )
      
      aQualColors <- c("1" = "#2db27d", "2" = "#365c8d", "3" ="#fde725", "4" = "#440154")

      p <- ggplot(df()) +
        geom_hline(aes(yintercept = input$iAQual1), linetype = "dotted", color = "#365c8d", alpha = 0.5) +
        geom_hline(aes(yintercept = input$iAQual2), linetype = "dotted", color = "#fde725", alpha = 0.8) +
        geom_hline(aes(yintercept = input$iAQual3), linetype = "dotted", color = "#440154", alpha = 0.5) +
        geom_line(aes(x = Date, y = CO2), size = 0.5, alpha = 0.3, color = "grey") +
        geom_point(aes(x = Date, y = CO2, color = iAQual), size = 0.7, alpha = 0.7) +
        scale_color_manual(values = aQualColors) +
        scale_y_continuous(breaks = seq(0, co2MaxVal, by = 400),
                           limits = c(0,co2MaxVal)) +
        scale_x_datetime(limits = c(start, end), date_labels = "%e. %b %Y") +
        ggtitle("CO<sub>2</sub>  Flats with Indoor Air Quality Zones") +
        facet_wrap(~room, ncol = 3, scales = "free") +
        theme_minimal() +
        theme( 
          strip.text = element_text(size = 13, color = "darkgrey"),
          legend.position="none",
          panel.spacing.y = unit(2, "lines"),
          panel.spacing.x = unit(0, "lines"),
          plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5)
        )
      
      yaxis <- list(
        title = "CO<sub>2 Flat</sub> in ppm",
        automargin = TRUE,
        titlefont = list(size = 14, color = "darkgrey")
      )
      
      ggplotly(p + ylab(" ") + xlab(" "), height = plotHeight(numRooms())) %>%
        plotly::config(modeBarButtons = list(list("toImage")),
                       displaylogo = FALSE,
                       toImageButtonOptions = list(
                       format = "svg"
                       )
        ) %>% 
        layout(margin = list(t = 120), yaxis = yaxis)
      })
    })
}