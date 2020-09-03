roomAirQualityModuleUI <- function(id) {

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
          numericInput(ns("iAQual1"), "Limit I (ppm)", min = 400, max = 2000, value = 600, step = 50, width = "150px"),
        ),
        box(
          width = 2,
          numericInput(ns("iAQual2"), "Limit II (ppm)", min = 400, max = 2000, value = 1000, step = 50, width = "150px"),
        ),
        box(
          width = 2,
          numericInput(ns("iAQual3"), "Limit III (ppm)", min = 400, max = 4000, value = 1500, step = 50, width = "150px")
        )
      )
    ),
    sidebarPanel(
      width = 2,
      sliderInput(inputId = ns("slider"),
                  label = "Time Range",
                  min = as.Date("2019-01-01"),
                  max = as.Date("2020-01-01"),
                  value = c(as.Date("2019-03-01"), as.Date("2019-09-01")),
                  timeFormat = "%b %Y"
      )
    ),
    mainPanel(
      width = 10,
      tabsetPanel(
        id = "roomAirQualityVis",
        tabPanel("Visualizations",
                 fluidRow(
                   box(
                     title="CO2 Flats with Indoor Air Quality Zones",
                     status="primary",
                     width = 12,
                     plotlyOutput(ns("aQualPlots"), height = "auto")
                   )
                 )
        )
      )
    ),
    tabsetPanel(
      id = "roomAirQualityDoc",
      tabPanel("Aims",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","roomAirQuality","aims.md"))
                   )
                 )
               )
      ),
      tabPanel("Data Analysis",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","roomAirQuality","dataanalysis.md"))
                   )
                 )
               )
      ),
      tabPanel("User Interface",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","roomAirQuality","userinterface.md"))
                   )
                 )
               )
      ),
      tabPanel("Interpretation",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","roomAirQuality","interpretation.md"))
                   )
                 )
               )
      ),
      tabPanel("Recommendations",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","roomAirQuality","recommendations.md"))
                   )
                 )
               )
      )
    )
  )
}

roomAirQualityModule <- function(input, output, session, aggData) {

  stopifnot(is.reactive(aggData))
  
  sliderDate <- reactiveValues()
  
  observe({
    start <- as.POSIXct(input$slider[1], tz="Europe/Zurich")
    end <- as.POSIXct(input$slider[2], tz="Europe/Zurich")
    sliderDate$start <- as.character(start)
    sliderDate$end <- as.character(end)
  })
  
  observe({
    dates <- as.data.frame(df.all() %>% select(time) %>% arrange(time))
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
      req(aggData())
      
      data <- aggData() %>% filter(dpType == "aQualRoom")
      # rename columns for plot title, not nice solution, but it works ;-)
      data <- data %>% mutate(room = paste0(flat," - ", room))
      
      # calculate indoor air quality class
      # data <- data %>% mutate(iAQual =if_else(value < input$iAQual1,"1", 
      #                                        if_else(value < input$iAQual2,"2", 
      #                                                if_else(value < input$iAQual3,"3", "4"))))
      
      # create day-column for later grouping
      data <- data %>% 
        mutate(
          day = lubridate::date(time)
        )

      # calculate daily statistics
      data <- data %>%
        group_by(day) %>%
        mutate(
          avg=mean(value, na.rm=T),
          upper=quantile(value, probs=0.95, na.rm=T), 
          lower=quantile(value, probs=0.05, na.rm=T)
        )
      data <- data %>% ungroup()
      
      # Narrow down table to daily entries
      data <- data %>% 
        select(day, avg, upper, lower, room ) %>% 
        # select(day, avg, upper, lower, room, iAQual ) %>% 
        unique()
      
      # renaming names
      colnames(data)[1] <- "time"

    })
    return(data)
  })

  # filter according to time slider settings
  df <- reactive({
    data <- df.all() %>% filter(time >= sliderDate$start & time <= sliderDate$end)
    
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
      start <- as.Date(sliderDate$start)
      end <- as.Date(sliderDate$end)
      co2MaxVal <- max(df() %>% select(upper) %>% max(),input$iAQual3) + 200
      
      aQualColors <- c("1" = "#2db27d", "2" = "#365c8d", "3" ="#fde725", "4" = "#440154")

      p <- ggplot(df()) +
        geom_rect(aes(xmin = start, xmax = end, ymin = 0, ymax = input$iAQual1, text = paste("Excellent")), fill = "#94D840FF", alpha = 0.1) +
        geom_rect(aes(xmin = start, xmax = end, ymin = input$iAQual1, ymax = input$iAQual2, text = paste("Good")), fill = "#56C667FF", alpha = 0.1) +
        geom_rect(aes(xmin = start, xmax = end, ymin = input$iAQual2, ymax = input$iAQual3, text = paste("Moderate")), fill = "#39558CFF", alpha = 0.1) +
        geom_rect(aes(xmin = start, xmax = end, ymin = input$iAQual3, ymax = co2MaxVal, text = paste("Too high")), fill = "#440154FF", alpha = 0.1) +
        geom_hline(aes(yintercept = input$iAQual1, text = paste("Limit 1")), linetype = "dotted", color = "#3F4788FF", alpha = 0.5) +
        geom_hline(aes(yintercept = input$iAQual2, text = paste("Limit 2")), linetype = "dotted", color = "#3F4788FF", alpha = 0.5) +
        geom_hline(aes(yintercept = input$iAQual3, text = paste("Limit 3")), linetype = "dotted", color = "#3F4788FF", alpha = 0.5) +
        geom_point(aes(x = time, y = avg
                      # ggplotly error https://github.com/ropensci/plotly/issues/1153
                      # text = paste("Date:       ", time,
                      #              "\nUpper:     ", sprintf("%.0f ppm", upper),
                      #              "\nAverage: ", sprintf("%.0f ppm", avg),
                      #              "\nLower:    ", sprintf("%.0f ppm", lower))
                      ), size = 0.5, alpha = 0.7, color = "red") +
        geom_ribbon(aes(x = time, y = avg, ymin = upper, ymax = lower,
                        # ggplotly error https://github.com/ropensci/plotly/issues/1153
                        text = paste("Date:       ", time,
                                     "<br />Upper:     ", sprintf("%.0f ppm", upper),
                                     "<br />Average:  ", sprintf("%.0f ppm", avg),
                                     "<br />Lower:     ", sprintf("%.0f ppm", lower))
                        ), alpha = 0.2, color = "red") +
        # geom_point(aes(x = time, y = avg, color = iAQual), size = 0.7, alpha = 0.7) +
        # scale_color_manual(values = aQualColors) +
        scale_y_continuous(breaks = seq(0, co2MaxVal, by = 200),
                           limits = c(0,co2MaxVal)) +
        # scale_x_date(limits = c(start, end), date_labels = "%e. %b %Y") +
        facet_wrap(~room, ncol = 3, scales = "free") +
        theme_minimal() +
        theme( 
          strip.text = element_text(size = 13, color = "darkgrey"),
          # legend.position="top",
          panel.spacing.y = unit(2, "lines"),
          panel.spacing.x = unit(0, "lines"),
          # plot.title = element_text(hjust = 0.5),
          # plot.subtitle = element_text(hjust = 0.5)
        )
      
      yaxis <- list(
        title = "CO<sub>2 Flat</sub> in ppm",
        automargin = TRUE,
        titlefont = list(size = 14, color = "darkgrey")
      )
      
      ggplotly(p + ylab(" ") + xlab(" "), height = plotHeight(numRooms()), tooltip = c("text")) %>%
        plotly::config(modeBarButtons = list(list("toImage")),
                       displaylogo = FALSE,
                       toImageButtonOptions = list(
                         format = "svg"
                       )
        ) %>% 
        layout(
          # margin = list(t = 120), 
          yaxis = yaxis)
      })
    })
}