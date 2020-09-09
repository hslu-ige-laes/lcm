flatHotWaterModuleUI <- function(id) {

  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Flat > Hot Water",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        box(
          width = 3,
          "no extended settings"
          )
      )
    ),
    sidebarPanel(
      width = 2,
      selectInput(ns("selCalc"), 
                  label = "Calculation",
                  choices = list("Absolute (ltr)", "Relative (ltr/(pers day))"),
                  selected = list("Relative (ltr/(pers day))"),
                  width = "200px"
      ),
      sliderInput(ns("slider"), "Time Range", min = as.Date("2019-01-01"), max =as.Date("2020-01-01"), value=c(as.Date("2019-03-01"), as.Date("2019-09-01")), timeFormat="%b %Y")
    ),
    mainPanel(
      width = 10,
      tabsetPanel(
        id = "flatHotWaterVis",
        tabPanel("Overview by Year",
                 fluidRow(
                   box(
                     status="primary",
                     width = 12,
                     column(
                       width = 12,
                       plotlyOutput(ns("hotWaterFlatYear"), height = "auto", width = "auto")
                     )
                   )
                 )
        ),
        tabPanel("Overview by Month",
                 fluidRow(
                   box(
                     status="primary",
                     width = 12,
                     column(
                       width = 12,
                       plotlyOutput(ns("hotWaterFlatMonth"), height = "auto", width = "auto")
                     )
                   )
                 )
        )
        # tabPanel("Stream",
        #          fluidRow(
        #            box(
        #              status="primary",
        #              width = 12,
        #              column(
        #                width = 12,
        #                # streamgraphOutput(ns("hotWaterFlatStream"), height = "400px", width = "100%")
        #                streamgraphOutput(ns("hotWaterFlatStream"))
        #                
        #              )
        #            )
        #          )
        # )
      )
    ),
    tabsetPanel(
      id = "flatHotWaterDoc",
      tabPanel("Aims",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","flatHotWater","aims.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatHotWater","dataanalysis.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatHotWater","userinterface.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatHotWater","interpretation.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatHotWater","recommendations.md"))
                   )
                 )
               )
      )
    )
  )
}

flatHotWaterModule <- function(input, output, session, aggData) {

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
    end <- as.Date(dates[nrow(dates),1], tz = "Europe/Zurich") + 1
    updateSliderInput(session,
                      "slider",
                      min = start,
                      max = end,
                      value = c(start, end)
    )
  })

  df.all <- reactive({
    data <- aggData() %>% filter(dpType == "hotWaterFlat")
    # convert m3 to ltr
    data <- data %>% mutate(value = value * 1000)

    return(data)
  })
  
  # filter data according to time slider setting
  # Consumption total
  df.abs.monthly <- reactive({
    data <- df.all() %>% filter(time >= sliderDate$start & time <= sliderDate$end)
    data$value <- round(data$value, digits = 1)
    # renaming names for proper hovertips
    colnames(data)[1] <- "Time"
    colnames(data)[2] <- "Consumption"
    
    # add separate columns for ggplot
    data$month <- lubridate::month(data$Time, label = TRUE)
    data$year <- lubridate::year(data$Time)
    data <- data %>% group_by(flat) %>% mutate(days = c(30, diff(Time)))
    occList <- bldgHierarchy() %>% select(flat, occupants)
    occList$occupants <- as.numeric(occList$occupants)
    data <- merge(data, occList, all.x = TRUE)

    return(data)
  })
  
  df.abs.yearly <- reactive({
    data <- df.abs.monthly() %>% 
      group_by(year,  flat) %>% 
      mutate(days  = sum(days), Consumption = sum(Consumption)) %>%
      select(-Time, -month) %>% 
      unique() %>% 
      na.omit()
      
    return(data)
  })
  

  # Consumption per Person and day, monthly aggregation
  df.ppd.monthly <- reactive({
    data <- df.abs.monthly() %>% na.omit()
    data$Consumption <- round(data$Consumption/(data$days * data$occupants), digits = 1)
    return(data)
  })
  
  # Consumption per Person per day, yearly aggregation
  df.ppd.yearly <- reactive({
    data <- df.abs.yearly()
    data$Consumption <- round(data$Consumption/(data$days * data$occupants), digits = 1)
    data <- data %>% group_by(year) %>%  mutate(averageYear = median(Consumption))

    return(data)
  })
  
  numFlats <- reactive({
    df.all() %>% select(flat) %>% unique() %>% nrow()
  })
  
  numYears <- reactive({
    df.abs.yearly() %>% ungroup() %>% select(year) %>% unique() %>% nrow()
  })
  
  
  plotHeight <- function(listNumRow) {
    # calculate values$facetCount
    rows <- ceiling(listNumRow/2)
    if(rows == 1){
      switch(listNumRow,
             {height = 350},
             {height = 300},
             {height = 250}
      )
    }
    else {
      height <- rows * 250
    }
    return(height)
  }
  
  # Generate Plots
  output$hotWaterFlatMonth <- renderPlotly({
    # Create a Progress object
    withProgress(message = 'Creating plot', detail = "hot water flats monthly", value = NULL, {
      # start <- as.POSIXct(sliderDate$start, tz="Europe/Zurich")
      # end <- as.POSIXct(sliderDate$end, tz="Europe/Zurich")
      
      if(input$selCalc == "Relative (ltr/(pers day))") {
        minY <- 0
        maxY <- max(df.ppd.monthly()$Consumption)
        p <- ggplot(df.ppd.monthly(),
                    aes(lubridate::month(Time,
                                         label = TRUE,
                                         abbr = TRUE),
                        Consumption,
                        group = factor(lubridate::year(Time)),
                        colour = factor(lubridate::year(Time)),
                        text = paste("</br>Year:     ", year ,"</br>Flat:      ",flat ,"</br>Vlm<sub>Hw</sub>: ", format(round(Consumption, digits = 1), big.mark="'"), "ltr/(pers day)")
                    )
          ) +
          ggtitle("Relative Hot Water Consumption Flat per Month")
        
        yAxisTitle <- "Vlm<sub>Hw</sub> in ltr/(pers day)"
        
      } else if(input$selCalc == "Absolute (ltr)") {
        minY <- 0
        maxY <- df.abs.monthly() %>% group_by(month, flat) %>% mutate(max = max(Consumption))
        maxY <- max(maxY$max)
        p <- ggplot(df.abs.monthly(), aes(lubridate::month(Time, label = TRUE, abbr = TRUE), 
                                          Consumption,
                                          group = factor(lubridate::year(Time)),
                                          colour = factor(lubridate::year(Time)),
                                          text = paste("</br>Year:     ", year ,"</br>Flat:      ",flat ,"</br>Vlm<sub>Hw</sub>: ", format(round(Consumption, digits = 0), big.mark="'"), "ltr/month")
                                          )
          ) +
          ggtitle("Absolute Hot Water Consumption Flat per Month")
        
        yAxisTitle <- "Vlm<sub>Hw</sub> in ltr/month"
        
      } else {
        p <- NULL  
      }
      
      p <- p +
        geom_line(alpha=0.7) +
        geom_point(alpha=0.7) +
        scale_y_continuous(labels = function(x) format(x, scientific = FALSE, big.mark = "'"),
                           limits=c(minY,maxY)) +
        labs(x="Month", colour="Year") +
        facet_wrap(~flat, ncol = 2, scales = "free") +
        theme_minimal() +
        scale_colour_viridis(discrete = TRUE) +
        theme(
          strip.text = element_text(size = 13, colour = "darkgrey"),
          legend.position="right",
          panel.spacing.y = unit(2, "lines"),
          plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5)
        )
      
      yaxis <- list(
        title = yAxisTitle,
        automargin = TRUE,
        titlefont = list(size = 14, color = "darkgrey")
      )
      
      ggplotly(p + ylab(" ") + xlab(" "), height = plotHeight(numFlats()), tooltip = c("text")) %>%
        plotly::config(modeBarButtons = list(list("toImage")),
                       displaylogo = FALSE,
                       toImageButtonOptions = list(
                         format = "svg"
                       )
        ) %>% 
        layout(margin = list(t = 120), yaxis = yaxis)
    })
  })
  
  output$hotWaterFlatYear <- renderPlotly({
    # Create a Progress object
    withProgress(message = 'Creating plot', detail = "hot water flats yearly", value = NULL, {
      # start <- as.POSIXct(sliderDate$start, tz="Europe/Zurich")
      # end <- as.POSIXct(sliderDate$end, tz="Europe/Zurich")

      if(input$selCalc == "Relative (ltr/(pers day))") {
        p <- ggplot(df.ppd.yearly() %>% ungroup(), aes(flat,
                                                       Consumption,
                                                       fill = flat,
                                                       text = paste("</br>Flat:     ",flat ,"</br>Vlm<sub>Hw</sub>: ", format(round(Consumption, digits = 1), big.mark="'"), "ltr/(pers day)")
                                                       )
          ) +
          geom_hline(data = df.ppd.yearly() %>% filter(year == year),
                     aes(yintercept = averageYear),
                     color="darkorange",
                     linetype="dashed") +
          ggtitle("Relative Hot Water Consumption Flat per Year")
        
        yAxisTitle <- "Vlm<sub>Hw</sub> in ltr/(pers day)"
        
      } else if(input$selCalc == "Absolute (ltr)") {
        p <- ggplot(df.abs.yearly() %>% ungroup(), aes(flat,
                                                       Consumption,
                                                       fill = flat,
                                                       text = paste("</br>Flat:     ",flat ,"</br>Vlm<sub>Hw</sub>: ", format(round(Consumption, digits = 0), big.mark="'"), "ltr/year")
                                                       )
          ) +
          ggtitle("Absolute Hot Water Consumption Flat per Year")
        
        yAxisTitle <- "Vlm<sub>Hw</sub> in ltr/year"
        
      } else {
        p <- NULL
      }
      
      
      p <- p +
        scale_y_continuous(labels = function(x) format(x, scientific = FALSE, big.mark = "'"),
                           expand = c(0,0)) +
        geom_bar(width = 0.8, position = "dodge", stat = "identity", alpha=0.7) +
        labs(fill="Flats") +
        facet_wrap(~year, nrow = 1) +
        theme_minimal() +
        scale_fill_viridis(discrete = TRUE) +
        theme(
          strip.text = element_text(size = 13, colour = "darkgrey"),
          legend.position="right",
          axis.text.x=element_blank(),
          axis.line.x = element_line(size = 2, colour = "darkgrey", linetype = 1),
          # axis.ticks.x=element_blank(),
          axis.title.x=element_blank(),
          panel.spacing.y = unit(2, "lines"),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5)
        )
      
      yaxis <- list(
        title = yAxisTitle,
        automargin = TRUE,
        titlefont = list(size = 14, color = "darkgrey")
      )
      
      ggplotly(p + ylab(" ") + xlab(" "), tooltip = c("text")) %>%
        plotly::config(modeBarButtons = list(list("toImage")),
                       displaylogo = FALSE,
                       toImageButtonOptions = list(
                         format = "svg"
                       )
        ) %>% 
        layout(margin = list(t = 120), yaxis = yaxis)
    })
  })
 
  # output$hotWaterFlatStream <- renderStreamgraph({
  #   # Create a Progress object
  #   withProgress(message = 'Creating plot', detail = "hot water flats stream", value = NULL, {
  #     stream_colors <- viridis_pal()(numFlats())
  #     if(input$selCalc == "Absolute (ltr)") {
  #       streamgraph(df.abs.monthly(), key = flat, value = Consumption, date = Time, height = "400px") %>% 
  #         sg_fill_manual(stream_colors) %>% sg_axis_x(tick_interval = 1, tick_units = "year", tick_format = "%Y")  
  #     } else {
  #       streamgraph(df.ppd.monthly(), key = flat, value = Consumption, date = Time, height = "400px") %>% 
  #         sg_fill_manual(stream_colors) %>% sg_axis_x(tick_interval = 1, tick_units = "year", tick_format = "%Y")   
  #     }
  #   })
  # })
  
}