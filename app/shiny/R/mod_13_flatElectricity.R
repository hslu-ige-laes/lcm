flatElectricityModuleUI <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Flat > Electricity",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        box(
         "no extended settings"
        )
      )
    ),
    sidebarPanel(
      width = 2,
      selectInput(ns("flat"), "Flat", choices = NULL),
      selectInput(inputId = ns("room"),
                  label = "Room",
                  choices = NULL,
                  multiple=F
      ),
      sliderInput(inputId = ns("slider"),
                  label = "Time Range",
                  min = as.Date("2019-01-01"),
                  max = as.Date("2020-01-01"),
                  value = c(as.Date("2019-03-01"), as.Date("2019-09-01")),
                  timeFormat = "%b %Y"
      ),
      checkboxGroupInput(inputId = ns("season"), 
                         label = "Visible Seasons",
                         choices = list("Winter", "Spring", "Summer", "Fall"),
                         selected = list("Winter", "Spring", "Summer", "Fall")
      )
    ),
    mainPanel(
      width = 10,
      tabsetPanel(
        id = "flatElectricityVis",
        tabPanel("Overview",
                 fluidRow(
                   box(
                     title="Daily Electric Energy Consumption and Standby Power",
                     status="primary",
                     width = 12,
                     plotlyOutput(ns("overviewPlot"))
                   )
                 )
        )
      )
    ),
    tabsetPanel(
      id = "flatElectricityDoc",
      tabPanel("Aims",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","flatElectricity","aims.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatElectricity","dataanalysis.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatElectricity","userinterface.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatElectricity","interpretation.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatElectricity","recommendations.md"))
                   )
                 )
               )
      )
    )
)}

flatElectricityModule <- function(input, output, session, aggData1hSum) {
  
  # date range slider
  sliderDate <- reactiveValues()
  
  observe({
    start <- as.POSIXct(input$slider[1], tz="Europe/Zurich")
    end <- as.POSIXct(input$slider[2], tz="Europe/Zurich")
    sliderDate$start <- as.character(start)
    sliderDate$end <- as.character(end)
  })
  
  observe({
    start <- as.Date(min(df.room()$time))
    end <- as.Date(max(df.room()$time))
    updateSliderInput(session,
                      "slider",
                      min = start,
                      max = end,
                      value = c(start, end)
    )
  })
  
  # get separate temp and hum data and merge it
  df.all <- reactive({
    withProgress(message = 'Calculating data', detail = "electricity plot", value = NULL, {
      req(aggData1hSum)
      
      # data <- merge.data.frame(aggData1dSum %>% filter(dpType == "eleFlat"), aggData1dMin %>% filter(dpType == "eleFlat"), by = c("time", "flat", "room"))
      data <- aggData1hSum %>% filter(dpType == "eleFlat")
      # data <- data_1h_sum
      locTimeZone <- configFileApp()[["bldgTimeZone"]]
      data$day <- as.Date(data$time, tz = locTimeZone)
      # data$day <- as.Date(data$time, tz = "Europe/Zurich")
      data$week <- lubridate::week(data$time)
      data$month <- lubridate::month(data$time)
      data$year <- lubridate::year(data$time)
      data <- data %>% mutate(season = season(time))
      
      # calculate sum and min per day
      data <- data %>% group_by(day) %>% mutate(sum = sum(value)) %>% ungroup()
      data <- data %>% group_by(day) %>% mutate(min = min(value)*1000) %>% ungroup()
      
    })
    return(data)
  })
  
  # flat pull down menu
  observe({
    data <- df.all() %>% select(flat) %>% unique()
    # rename the set if there is only one value
    # https://stackoverflow.com/questions/43098849/display-only-one-value-in-selectinput-in-r-shiny-app
    if (nrow(data) == 1) {
      data <- names(data) <- c(data$flat[1])
    }
    data <- as.list(data)
    updateSelectizeInput(session, 'flat',
                         choices = data,
                         server = TRUE
    )
  })
  
  # filter according to flat selection
  df.flat <- reactive({
    data <- df.all() %>% filter(flat == input$flat)
    return(data)
  })
  
  # room pull down menu
  observe({
    data <- df.flat() %>% select(room) %>% unique()
    # rename the set if there is only one value
    # https://stackoverflow.com/questions/43098849/display-only-one-value-in-selectinput-in-r-shiny-app
    if (nrow(data) == 1) {
      data <- names(data) <- c(data$room[1])
    }
    data <- as.list(data)
    updateSelectizeInput(session, 'room',
                         choices = data,
                         server = TRUE
    )
  })
  
  # filter according to room selection
  df.room <- reactive({
    data <- df.flat() %>% filter(room == input$room)
    return(data)
  })

  # filter data according to season settings
  df.season <- reactive({
    data <- df.room() %>% filter(season %in% input$season)
    return(data)
  })
 
  # filter according to time slider settings
  df <- reactive({
    data <- df.season() %>% filter(time >= sliderDate$start & time <= sliderDate$end)
    return(data)
  })
  
  df.agg1d <- reactive({

    data <- df() %>% select(day, sum, min, season) %>% unique()
    
    data <- data %>% mutate(ravgUsage = zoo::rollmean(x=sum, 7, fill = NA))
    data <- data %>% mutate(ravgStandby = zoo::rollmean(x=min, 7, fill = NA))
    
    
    return(data)
  })
  
  # Plot
  output$overviewPlot <- renderPlotly({
    withProgress(message = 'Creating plot', detail = "electricity overview", value = NULL, {
      minY <- 0
      maxYUsage <- max(df.all() %>% select(sum), na.rm=TRUE)
      maxYStandby <- max(df.all() %>% select(min), na.rm=TRUE)
      minX <- sliderDate$start
      maxX <- sliderDate$end
      averageUsage <- mean(df.agg1d()$sum, na.rm=TRUE)
      averageStandby <- mean(df.agg1d()$min, na.rm=TRUE)
      shareStandby <- nrow(df.agg1d() %>% select(sum) %>% na.omit()) * averageStandby * 24 / (1000 * sum(df.agg1d()$sum, na.rm=TRUE)) * 100
  
      l <- list(
        orientation = "h"
        )
      
      fig1 <- df.agg1d() %>%
        plot_ly(x = ~day, showlegend = TRUE) %>%
        add_trace(data = df.agg1d() %>% filter(season == "Spring"),
                  type = "bar",
                  y = ~sum,
                  name = "Spring",
                  marker = list(color = "#2db27d", opacity = 0.2),
                  hoverinfo = "text",
                  text = ~ paste("<br />daily usage:              ", sprintf("%.1f kWh/d", sum),
                                 "<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                 "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_trace(data = df.agg1d() %>% filter(season == "Summer"),
                  type = "bar",
                  y = ~sum,
                  name = "Summer",
                  marker = list(color = "#febc2b", opacity = 0.2),
                  hoverinfo = "text",
                  text = ~ paste("<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                 "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_trace(data = df.agg1d() %>% filter(season == "Fall"),
                  type = "bar",
                  y = ~sum,
                  name = "Fall",
                  marker = list(color = "#440154", opacity = 0.2),
                  hoverinfo = "text",
                  text = ~ paste("<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                 "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_trace(data = df.agg1d() %>% filter(season == "Winter"),
                  type = "bar",
                  y = ~sum,
                  name = "Winter",
                  marker = list(color = "#365c8d", opacity = 0.2),
                  hoverinfo = "text",
                  text = ~ paste("<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                 "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>%
        add_trace(data = df.agg1d(),
                  type = "scatter",
                  mode = "markers",
                  y = ~ravgUsage,
                  name = "Average (7 days)",
                  marker = list(color = "orange", opacity = 0.5, symbol = "circle"),
                  hoverinfo = "text",
                  text = ~ paste("<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                 "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_segments(x = ~sliderDate$start,
                     xend = ~sliderDate$end,
                     y = ~averageUsage,
                     yend = ~averageUsage,
                     name = "Average Total",
                     line = list(color = "orange", opacity = 1.0, dash = "dot"),
                     hoverinfo = "text",
                     text = ~ paste("<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                    "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                    "<br />Date:                        ", day,
                                    "<br />Season:                   ", season
                     )
      ) %>% 
      add_annotations(
        x = maxX,
        y = averageUsage,
        text = sprintf("%.1f kWh/d", averageUsage),
        xref = "x",
        yref = "y",
        showarrow = TRUE,
        arrowhead = 7,
        ax = -20,
        ay = -40,
        font = list(color = "orange")
        
      ) %>% 
      layout(
        xaxis = list(
          title = ""
        ),
        yaxis = list(title = "Consumption<br>(kWh/d)",
                     range = c(minY, maxYUsage),
                     titlefont = list(size = 14, color = "darkgrey")),
        hoverlabel = list(align = "left"),
        margin = list(l = 80, t = 50, r = 50, b = 10),
        legend = l
      )
      
      fig2 <- df.agg1d() %>%
        plot_ly(x = ~day, showlegend = TRUE) %>%
        add_trace(data = df.agg1d(),
                  type = "bar",
                  y = ~min,
                  name = "Standby",
                  marker = list(color = "darkgrey", opacity = 0.2),
                  hoverinfo = "text",
                  text = ~ paste("<br />daily standby:           ", sprintf("%.0f W", min),
                                 "<br />rolling average:        ", sprintf("%.0f W", ravgStandby),
                                 "<br />Average vis. points: ", sprintf("%.0f W", averageStandby),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_trace(data = df.agg1d(),
                  type = "scatter",
                  mode = "markers",
                  y = ~ravgStandby,
                  name = "Average (7 days)",
                  marker = list(color = "darkgrey", opacity = 0.5, symbol = "circle"),
                  hoverinfo = "text",
                  text = ~ paste("<br />daily standby:           ", sprintf("%.0f W", min),
                                 "<br />rolling average:        ", sprintf("%.0f W", ravgStandby),
                                 "<br />Average vis. points: ", sprintf("%.0f W", averageStandby),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_segments(x = ~sliderDate$start,
                     xend = ~sliderDate$end,
                     y = ~averageStandby,
                     yend = ~averageStandby,
                     name = "Average Total",
                     line = list(color = "darkgrey", opacity = 1.0, dash = "dot"),
                     hoverinfo = "text",
                     text = ~ paste("<br />daily standby:           ", sprintf("%.0f W", min),
                                    "<br />rolling average:        ", sprintf("%.0f W", ravgStandby),
                                    "<br />Average vis. points: ", sprintf("%.0f W", averageStandby),
                                    "<br />Date:                        ", day,
                                    "<br />Season:                   ", season
                     )
        ) %>% 
        add_annotations(
          x = maxX,
          y = averageStandby,
          text = sprintf("%.0f W", averageStandby),
          xref = "x",
          yref = "y",
          showarrow = TRUE,
          arrowhead = 7,
          ax = -20,
          ay = -15,
          font = list(color = "darkgrey")
        ) %>% 
        add_annotations(
          x = maxX,
          y = averageStandby,
          text = paste0(sprintf("%.1f %%", shareStandby), " of the consumption are standby losses"),
          xref = "x",
          yref = "y",
          showarrow = TRUE,
          arrowhead = 7,
          ax = -180,
          ay = 15,
          font = list(color = "darkgrey")
        ) %>% 
        layout(
          xaxis = list(
            title = ""
          ),
          yaxis = list(title = " Standby<br>(W)",
                       range = c(minY, maxYStandby),
                       titlefont = list(size = 14, color = "darkgrey"),
                       legend = list(orientation = 'h')),
          legend = l
        )
      
      # calculate ratio which is visual representative for comparison 
      ratio <- 1/maxYUsage * maxYStandby * 24 / 1000
      
      fig <- subplot(fig1, fig2, nrows = 2, shareX = TRUE, heights = c(1-ratio, ratio), titleY = TRUE) %>%
        plotly::config(modeBarButtons = list(list("toImage")),
                       displaylogo = FALSE,
                       toImageButtonOptions = list(
                         format = "svg"
                       )
        )
      
      return(fig)
    })
  })
}