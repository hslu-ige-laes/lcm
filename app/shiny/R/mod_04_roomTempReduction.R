roomTempReductionModuleUI <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Room > Temperature Reduction",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        box(
          width = 2,
          numericInput(ns("temperatureSetpoint"), "Temperature setpoint", min = 15, max = 28, value = 21, step = 0.5)
        )
      )
    ),
    sidebarPanel(
      width = 2,
      sliderInput(ns("slider"), "Time Range", min = as.Date("2019-01-01"), max =as.Date("2020-01-01"), value=c(as.Date("2019-03-01"), as.Date("2019-09-01")), timeFormat="%b %Y"),
      checkboxGroupInput(ns("season"), 
                         label = "Visible Seasons",
                         choices = list("Winter", "Spring", "Summer", "Fall"),
                         selected = list("Winter")
      )
    ),
    mainPanel(
      width = 10,
      tabsetPanel(
        id = "roomTempReductionVis",
        tabPanel("Overview",
                 fluidRow(
                   box(
                     status="primary",
                     width = 12,
                     plotlyOutput(ns("temperaturePlots"), height = "auto")
                   )
                 )
        ),
        tabPanel("Boxplot",
                 fluidRow(
                   box(
                     status="primary",
                     width = 12,
                     column(
                       width = 12,
                       plotlyOutput(ns("boxPlot"), height = "auto")
                     )
                   )
                 )
        )
      )
    ),
    tabsetPanel(
      id = "roomTempReductionDoc",
      tabPanel("Aims",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","roomTempReduction","aims.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","roomTempReduction","dataanalysis.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","roomTempReduction","userinterface.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","roomTempReduction","interpretation.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","roomTempReduction","recommendations.md"))
                   )
                 )
               )
      )
    )
  )
}

roomTempReductionModule <- function(input, output, session, aggData) {

  stopifnot(is.reactive(aggData))
  
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
    withProgress(message = 'Calculating data', detail = "temperature reduction plot", value = NULL, {

      req(aggData())
      data <- aggData() %>% filter(dpType == "tempRoom")
      # rename columns for ggplot title, not nice solution, but it works ;-)
      data <- data %>% mutate(room = paste0(flat," - ", room))
      
      data$value <- round(data$value, digits = 1)
      
      colnames(data)[2] <- "Temp"
    })
    return(data)
  })

  # filter data according to season settings
  df.season <- reactive({
    data <- df.all() %>% mutate(season = season(time))
    data <- data %>% filter(season %in% input$season)
    return(data)
  })
  
  # filter data according to time slider setting
  df <- reactive({
    data <- df.season() %>% filter(time >= sliderDate$start & time <= sliderDate$end)
    # renaming names for proper hovertips
    colnames(data)[1] <- "Date"
    
    return(data)
  })

  calculations <- reactive({
    data <- df() %>% group_by(room) %>% dplyr::summarise(meanValue = mean(Temp))
    data$difference <- with(data, data$meanValue - input$temperatureSetpoint)

    return(data)
  })

  numRooms <- reactive({
    df.season() %>% select(room) %>% unique() %>% nrow()
  })

  plotHeight <- function(listNumRow) {
    # calculate values$facetCount
    rows <- ceiling(listNumRow/3)
    if(rows == 1){
      switch(listNumRow,
        {height = 450},
        {height = 400},
        {height = 350}
      )
    }
    else {
      height <- rows * 250
    }
    return(height)
  }

  # Generate Plots
  output$temperaturePlots <- renderPlotly({
    
    if(nrow(df()) == 0){
      return(NULL)
    }

    # Create a Progress object
    withProgress(message = 'Creating plot', detail = "temperature plot", value = NULL, {
      
      start <- as.POSIXct(sliderDate$start, tz="Europe/Zurich")
      end <- as.POSIXct(sliderDate$end, tz="Europe/Zurich")
      textPosX <- as.POSIXct(start + difftime(end, start, units = "days")/2, tz="Europe/Zurich")
      textPosYMax <- df() %>% select(Temp)
      textPosYMax <- max(ceiling(max(textPosYMax$Temp)) + 0.5, input$temperatureSetpoint)
      minY <- df() %>% select(Temp)
      minY <- min(floor(min(minY$Temp)) %>% floor() - 0.5, input$temperatureSetpoint - 1)
      maxY <- textPosYMax + 1
      # seasonColors <- c(Winter = "blue", Spring = "darkgreen", Summer ="red", Fall = "brown")
      seasonColors <- c(Winter = "#365c8d", Spring = "#2db27d", Summer ="#febc2b", Fall = "#440154")
      
      p <- ggplot(df()) +
        geom_hline(aes(yintercept = input$temperatureSetpoint), linetype=1, color="darkorange", alpha=0.5) +
        geom_hline(data = calculations(), aes(yintercept = meanValue), linetype=2, color="red", alpha=0.5) +
        geom_point(aes(x = as.Date(Date),
                       y = Temp,
                       color = season,
                       text = paste("</br>Date:  ", as.Date(Date), "</br>Temp: ", Temp, "\u00B0C")),
                   size = 0.7, alpha = 0.7) +
        scale_color_manual(values = seasonColors) +
        geom_text(data = calculations(),
                  aes(x = as.Date(textPosX),
                      y = textPosYMax + 0.5,
                      label = paste0("Average = ", sprintf('%0.1f', round(meanValue, digits = 1)), "\u00B0C")),
                  color = "red") +
        geom_text(data = calculations(),
                  aes(x = as.Date(textPosX),
                      y = textPosYMax -0.5,
                      label = paste0("Difference = ", sprintf('%0.1f', round(difference, digits = 1)), "K")),
                  color = "darkorange") +
        ggtitle("Temperature Flats with Average, Setpoint and resulting Difference") +
        scale_x_date(limits = c(as.Date(start), as.Date(end)), date_labels = "%e. %b %Y") +
        scale_y_continuous(limits=c(minY,maxY)) +
        facet_wrap(~room, ncol = 3, scales = "free") +
        theme_minimal() +
        theme(
          strip.text = element_text(size = 13, color = "darkgrey"),
          legend.position="none",
          panel.spacing.y = unit(2, "lines"),
          plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5)
        )
      
      yaxis <- list(
        title = "Temp<sub>Room</sub> in \u00B0C",
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
        layout(margin = list(t = 120), 
               yaxis = yaxis)

      })
  })
  
  output$boxPlot <- renderPlotly({
    withProgress(message = 'Creating plot', detail = "Boxplot", value = NULL, {
      minY <- df.all() %>% select(Temp)
      minY <- min(floor(min(minY$Temp)) %>% floor() - 1, input$temperatureSetpoint - 1)
      maxY <- df.all() %>% select(Temp)
      maxY <- max(ceiling(max(maxY$Temp)) + 1, input$temperatureSetpoint + 1) 

      p <- ggplot(df(), aes(x = room, y = Temp)) +
        geom_hline(aes(yintercept = input$temperatureSetpoint), linetype=1, color="darkorange", alpha=0.5) +
        geom_hline(aes(yintercept = median(Temp)), linetype=2, color="red", alpha=0.5) +
        geom_boxplot(outlier.alpha = 0.01, outlier.shape = 1, outlier.colour = "darkgrey") +
        scale_y_continuous(limits=c(minY,maxY), breaks = seq(minY, maxY, by = 2)) +
        ggtitle("Boxplot per Flat/Room") +
        theme_minimal() +
        theme(
          legend.position="none",
          plot.title = element_text(hjust = 0.5)
        )

      yaxis <- list(
        title = "Temp<sub>Room</sub> in \u00B0C",
        automargin = TRUE,
        titlefont = list(size = 14, color = "darkgrey")
      )
        
      ggplotly(p + ylab(" ") + xlab(" ")) %>%
        plotly::config(modeBarButtons = list(list("toImage")),
                       displaylogo = FALSE,
                       toImageButtonOptions = list(
                         format = "svg"
                       )
        ) %>%
        layout(yaxis = yaxis)
    })
  })
}