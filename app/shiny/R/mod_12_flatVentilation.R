
# ======================================================================
# season() aus mollierhx rauskopieren in helper-Functions
# ======================================================================


flatVentilationModuleUI <- function(id) {

  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Flat > Ventilation",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        box(
          width = 3,
          sliderInput(ns("slider"), "Time range", min = as.Date("2019-01-01"), max =as.Date("2020-01-01"), value=c(as.Date("2019-03-01"), as.Date("2019-09-01")), timeFormat="%b %Y")
        ),
        box(
          width = 2,
          selectInput(inputId = ns("dpVentilationFlat"), 
                      label = "Ventilator",
                      choices = NULL,
                      selectize = FALSE
          )
        )
      )
    ),
    tabsetPanel(
      id = "tabset1",
      tabPanel("Schedule",
               fluidRow(
                 box(
                   title="Ventilation Schedule",
                   status="primary",
                   width = 12,
                   plotlyOutput(ns("ventilationSchedulePlot"), height = "auto")
                 )
               )
      ),
      tabPanel("Overview",
               fluidRow(
                 box(
                   title="tbd",
                   status="primary",
                   width = 12,
                   plotlyOutput(ns("ventilationOverview"), height = "auto")
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatVentilation.md"))
                   )
                 )
               )
      )
    )
  )
}

flatVentilationModule <- function(input, output, session, aggData) {

  # date range slider
  sliderDate <- reactiveValues()

  observe({
    start <- as.POSIXct(input$slider[1], tz="Europe/Zurich")
    end <- as.POSIXct(input$slider[2], tz="Europe/Zurich")
    sliderDate$start <- as.character(start)
    sliderDate$end <- as.character(end)
  })

  observe({
    start <- as.Date(df.all()[1,1], tz = "Europe/Zurich")
    end <- as.Date(df.all()[nrow(df.all()),1], tz = "Europe/Zurich")
    updateSliderInput(session,
                      "slider",
                      min = start,
                      max = end,
                      value = c(start, end)
    )
  })

  observe({
    data <- dataPoints() %>% filter(dpType == "ventilationFlat") %>% select(abbreviation)
    # rename the set if there is only one value
    # https://stackoverflow.com/questions/43098849/display-only-one-value-in-selectinput-in-r-shiny-app
    if (nrow(data) == 1) {
      # data <- names(data) <- c(data$abbreviation[1])
      names(data) <- as.character(data[1,1])
    }
    data <- as.list(data)
    updateSelectInput(session, "dpVentilationFlat",
                      choices = data
    )
  })
  
  df.all <- reactive({
    req(input$dpVentilationFlat)
    req(aggData)
    withProgress(message = "Calculating", detail = "ventilationFlat.agg15m" , value = NULL, {
      
      # get time series
      data <- aggData %>% filter(abbreviation == input$dpVentilationFlat)
      # rename value column
      names(data)[2] <- "value"
      
      data<- as.data.frame(data)

      # cut in levels
      levelMin <- 0
      levelAway <- 15
      levelSt1 <- 35
      levelSt2 <- 50
      levelSt3 <- 75
      levelMax <- 100
      
      cuts <- c(levelMin,
                levelMin + ((levelAway - levelMin) / 2),
                levelAway + ((levelSt1 - levelAway) / 2),
                levelSt1 + ((levelSt2 - levelSt1) / 2),
                levelSt2 + ((levelSt3 - levelSt2) / 2),
                levelSt3 + ((levelMax - levelSt3) / 2),
                levelMax)
      
      # 1 = "Minimum", 2 = "Away", 3 = "Stage 1", 4 = "Stage 2", 5 = "Stage 3", 6 = "Maximum"
      labels = c(1,2,3,4,5,6)
      
      data <- data %>% mutate(stage = sapply(data$value, function(x) {
        as.numeric(cut(x, cuts, labels, include.lowest = TRUE))
      }))
      # print(data)

      data <- data %>% 
        mutate(
          hourMin = strftime(time, format="%H:%M"),
          weekDay = lubridate::wday(as.Date(time),week_start=1),
          weekDayName = factor(weekDay,levels=rev(1:7),
                           labels=rev(c("Mon","Tue","Wed","Thu","Fri","Sat","Sun")),
                           ordered=T),
          day = as.numeric(strftime(time, format="%d")),
          month = as.numeric(strftime(time, format="%m")),
          year = as.numeric(strftime(time, format="%Y"))
        )
    })
    return(data)
  })

# filter data according to time slider setting
df <- reactive({
  req(input$dpVentilationFlat)
  start <- as.Date(sliderDate$start, tz = "Europe/Zurich")
  end <- as.Date(sliderDate$end, tz = "Europe/Zurich")
  data.filtered <- df.all() %>% filter(time >= start & time <= end)
  data.agg <- data.filtered %>%
    ungroup() %>% 
    select(weekDay, weekDayName, hourMin, stage, day, month, year) %>% 
    group_by(weekDay, hourMin) %>%
    mutate(stageCalc = names(sort(table(stage), decreasing=TRUE)[1])) %>% 
    unique()

  data.agg <- data.agg %>% ungroup() %>% select(weekDayName, hourMin, stageCalc, day, month, year, stage)
  data.agg$stageCalcName <- c("Minimum", "Away", "Stage 1", "Stage 2", "Stage 3", "Maximum")[match(data.agg$stageCalc, c(1:6))]
  return(data.agg)
})

# Generate Plot
output$ventilationSchedulePlot <- renderPlotly({
  # Create a Progress object
  withProgress(message = 'Creating plot', detail = "ventilationSchedulePlot", value = NULL, {
    p <- plot_ly(df(),
                 x = ~weekDayName,
                 y = ~hourMin,
                 z = ~stageCalc,
                 zmin = 1,
                 zmax = 6,
                 type = "heatmap",
                 colorscale = "Viridis",
                 xgap = 5,
                 ygap = 0.1,
                 colorbar=list(title = "Fan Level", ypad = 30, tickmode = "array", tickvals = c(1, 2, 3, 4, 5, 6), ticktext=c("Minimum", "Away", "Stage 1", "Stage 2", "Stage 3", "Maximum")),
                 hoverinfo = "text",
                 hovertext = paste0(df()$weekDayName," ", df()$hourMin,
                                    "<br>", df()$stageCalcName)
      ) %>%
      layout(xaxis = list(title = "Weekday",
                          autorange = "reversed"
                          ),
             yaxis = list(title = "Hour of Day",
                          autorange = "reversed",
                          tick0 = 0,
                          dtick = 8
                          )
      ) %>% 
    plotly::config(modeBarButtons = list(list("toImage")), displaylogo = FALSE)

    
  })

})
output$ventilationOverview <- renderPlotly({
  # Create a Progress object
  # print(df())
  withProgress(message = 'Creating plot', detail = "ventilationOverview", value = NULL, {
    p <- ggplot(df(), aes(x=day,
                          y=hourMin,
                          fill = stage,
                          text = paste("</br>Day: ", weekDayName, "</br>Level: ", stage)
                          )
    ) +
      geom_tile(colour = "white") +
      labs(x="Day", y="Hour") +
      # scale_y_continuous(trans = "reverse", breaks = seq(0,23.75,1)) +
      theme_minimal() +
      scale_fill_viridis(discrete = FALSE) +
      facet_grid(year~month) 
    
    ggplotly(p)
  })
})

}


