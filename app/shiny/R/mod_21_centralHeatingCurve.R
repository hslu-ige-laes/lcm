centralHeatingCurveModuleUI <- function(id) {

  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Central > Heating Curve",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        box(
          width = 2,
          numericInput(inputId = ns("rangeRollMeanTOa"),
                       label = "Range Rolling Mean Temp. Outs. Air in hours",
                       min = 1,
                       max = 168,
                       step = 1,
                       value = 48
                       )
        ),
        box(
          width = 2,
          numericInput(inputId = ns("rangeRollMaxTSu"),
                       label = "Range Rolling Maximum Temp. Supply Heat in hours",
                       min = 1,
                       max = 48,
                       step = 1,
                       value = 24
          )
        ),
        box(
          width = 2,
          numericInput(inputId = ns("heatCrvRTempSp"),
                       label = "Heat Curve Room Temperature Setpoint in °C",
                       min = 16,
                       max = 26,
                       step = 1,
                       value = 20
          )
        ),
        box(
          width = 2,
          numericInput(inputId = ns("heatCrvLevelCorr"),
                       label = "Heat Curve Level Correction",
                       min = -5,
                       max = 5,
                       step = 0.5,
                       value = 0
          )
        ),
        box(
          width = 2,
          numericInput(inputId = ns("heatCrvSlope"),
                       label = "Heat Curve Slope",
                       min = 0.1,
                       max = 5,
                       step = 0.05,
                       value = 0.4
          )
        )
      )
    ),
    sidebarPanel(
      width = 2,
      selectInput(inputId = ns("tempOutsideAir"), 
                  label = "Temperature Outside Air",
                  choices = NULL,
                  selectize = FALSE
      ),
      selectInput(inputId = ns("tempSupplyHeat"), 
                  label = "Temperature Supply Heating",
                  choices = NULL,
                  selectize = FALSE
      ),
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
        id = "centralHeatingCurveVis",
        tabPanel("Visualizations",
                 fluidRow(
                   box(
                     title="Heating Curve ",
                     status="primary",
                     width = 12,
                     plotlyOutput(ns("centralHeatingCurvePlot"), height = "auto")
                   )
                 )
        )
      )
    ),
    tabsetPanel(
      id = "centralHeatingCurveDoc",
      tabPanel("Aims",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","centralHeatingCurve","aims.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","centralHeatingCurve","dataanalysis.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","centralHeatingCurve","userinterface.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","centralHeatingCurve","interpretation.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","centralHeatingCurve","recommendations.md"))
                   )
                 )
               )
      )
    )
  )
}

centralHeatingCurveModule <- function(input, output, session, aggData) {
  
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
    start <- as.Date(df.all()[1,1], tz = "Europe/Zurich")
    end <- as.Date(df.all()[nrow(df.all()),1], tz = "Europe/Zurich")
    updateSliderInput(session,
                      "slider",
                      min = start,
                      max = end,
                      value = c(start, end)
    )
  })

  # data fetching
  outsideTempData <- reactive({
    withProgress(message = 'Fetching data', detail = "tempOutsideAir", value = NULL, {
      data <- aggData() %>% filter(dpType == "tempOutsideAir")
    })
    return(data)
  })

  supplyTempData <- reactive({
    withProgress(message = 'Fetching data', detail = "tempSupplyHeat", value = NULL, {
      data <- aggData() %>% filter(dpType == "tempSupplyHeat")
    })
    return(data)
  })

  observe({
    dpList <- outsideTempData() %>% select(abbreviation) %>% unique()
    updateSelectInput(session, "tempOutsideAir",
                      choices = dpList$abbreviation
    )
  })

  observe({
    dpList <- supplyTempData() %>% select(abbreviation) %>% unique()
    updateSelectInput(session, "tempSupplyHeat",
                      choices = dpList$abbreviation
    )
  })

  # combine two data frames
  df.all <- reactive({
    req(supplyTempData())
    req(outsideTempData())
    req(input$tempOutsideAir)
    req(input$tempSupplyHeat)

    data <- inner_join(supplyTempData() %>% filter(abbreviation == input$tempSupplyHeat), outsideTempData() %>% filter(abbreviation == input$tempOutsideAir) , by="time") %>% na.omit()

    names(data)[1] <- "Date"
    names(data)[2] <- "TSuVal"
    names(data)[3] <- "TSuName"
    names(data)[7] <- "TOaVal"
    names(data)[8] <- "TOaName"
    
    data <- data %>% mutate(season = season(Date))
    
    rangeRollMeanTOa <- min(148, max(1, as.numeric(input$rangeRollMeanTOa)))
    rangeRollMaxTSu <- min(48, max(1, as.numeric(input$rangeRollMaxTSu)))

    data <- data %>% mutate(tempOaRollMean = rollmean(TOaVal, rangeRollMeanTOa, fill = NA, align = "right"))
    data <- data %>% mutate(tempSuRollMax = rollmax(TSuVal, rangeRollMaxTSu, fill = NA, align = "right"))
    
    # test
    data <- data %>% select(Date, tempSuRollMax, tempOaRollMean, season) %>% unique()
    # print(data)
    data <- data %>% na.omit()

    return(data)
  })

  
  df.season <- reactive({
    req(input$season)
    df.all() %>% filter(season %in% input$season)
  })
  
  
  # filter data according to time slider setting
  df <- reactive({
    start <- as.Date(sliderDate$start, tz = "Europe/Zurich")
    end <- as.Date(sliderDate$end, tz = "Europe/Zurich")
    data <- df.season() %>% filter(Date >= start & Date <= end)
    return(data)
  })
  
  df.winter <- reactive({
    df() %>% filter(season=="Winter")
  })
  
  df.spring <- reactive({
    df() %>% filter(season=="Spring")
  })
  
  df.summer <- reactive({
    df() %>% filter(season=="Summer")
  })
  
  df.fall <- reactive({
    df() %>% filter(season=="Fall")
  })
  
  
  df.heatCrv <- reactive({
    TOa <- seq(-20, 30, 0.1)
    df <- data.frame(TOa)
    df <- df %>% mutate(TSu = input$heatCrvSlope * 1.8317984 * (input$heatCrvRTempSp - TOa)^0.8281902 + input$heatCrvLevelCorr + input$heatCrvRTempSp)
    
    return(df)
  })
  
  # Generate Plot
  output$centralHeatingCurvePlot <- renderPlotly({
    # Create a Progress object
    withProgress(message = 'Creating plot', detail = "centralHeatingCurvePlot", value = NULL, {
      
      minY <- min(min(df.all()$tempSuRollMax) - 1, input$heatCrvRTempSp)
      maxY <- max(df.all()$tempSuRollMax) + 1
      
      p <- plot_ly() %>% 
        add_lines(data = df.heatCrv(),
                  x = ~TOa,
                  y = ~TSu,
                  name = "Temp Su Heat Curve"
        )
  
      if("Spring" %in% input$season){
        p <- p %>% add_markers(data = df.spring(),
                    x = ~tempOaRollMean,
                    y = ~tempSuRollMax,
                    marker = list(color = "#2db27d", opacity = 0.2),
                    name = "Spring",
                    hoverinfo = "text",
                    text = ~ paste("Outside Temp:  ", sprintf("%.1f \u00B0C", tempOaRollMean),
                                   "<br />Supply Temp: ", sprintf("%.1f \u00B0C", tempSuRollMax),
                                   "<br />Date:     ", df.spring()$Date,
                                   "<br />Season: ", df.spring()$season
                    )
        )
      }
      if("Summer" %in% input$season){
        p <- p %>% add_markers(data = df.summer(),
                  x = ~tempOaRollMean,
                  y = ~tempSuRollMax,
                  marker = list(color = "#fde725", opacity = 0.2),
                  name = "Summer",
                  hoverinfo = "text",
                  text = ~ paste("Outside Temp:  ", sprintf("%.1f \u00B0C", tempOaRollMean),
                                 "<br />Supply Temp: ", sprintf("%.1f \u00B0C", tempSuRollMax),
                                 "<br />Date:     ", df.summer()$Date,
                                 "<br />Season: ", df.summer()$season
                  )
        )
      }
      if("Fall" %in% input$season){
        p <- p %>% add_markers(data = df.fall(),
                    x = ~tempOaRollMean,
                    y = ~tempSuRollMax,
                    marker = list(color = "#440154", opacity = 0.2),
                    name = "Fall",
                    hoverinfo = "text",
                    text = ~ paste("Outside Temp:  ", sprintf("%.1f \u00B0C", tempOaRollMean),
                                   "<br />Supply Temp: ", sprintf("%.1f \u00B0C", tempSuRollMax),
                                   "<br />Date:     ", df.fall()$Date,
                                   "<br />Season: ", df.fall()$season
                    )
        )
      }
      if("Winter" %in% input$season){
        p <- p %>% add_markers(data = df.winter(),
                    x = ~tempOaRollMean,
                    y = ~tempSuRollMax,
                    marker = list(color = "#365c8d", opacity = 0.2),
                    name = "Winter",
                    hoverinfo = "text",
                    text = ~ paste("Outside Temp:  ", sprintf("%.1f \u00B0C", tempOaRollMean),
                                   "<br />Supply Temp: ", sprintf("%.1f \u00B0C", tempSuRollMax),
                                   "<br />Date:     ", df.winter()$Date,
                                   "<br />Season: ", df.winter()$season
                    )
        )
      }
  
      p <- p %>%
        layout(
          xaxis = list(title = paste0("Outside temperature in \u00B0C<br>(Rolling Mean last ", input$rangeRollMeanTOa, " hours)"),
                       range = c(min(-10,min(df.all()$tempOaRollMean)), max(35,max(df.all()$tempOaRollMean))),
                       zeroline = F
                       # type = "log"
                       ),
          yaxis = list(title = paste0("Supply temperature heating in \u00B0C<br>(Rolling Max last ", input$rangeRollMaxTSu, " hours)"),
                       range = c(minY, maxY)
                       ),
          showlegend = FALSE
        ) %>%
        plotly::config(modeBarButtons = list(list("toImage")), displaylogo = FALSE)
  
    })
  
  })

}


