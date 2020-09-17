dataexplorerModuleUI <- function(id) {

  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Data Explorer",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        box(
          width = 3,
          selectInput(ns("dataPointAbbr"), "Datapoint", choices=NULL)
        ),
        box(
          width = 2,
          selectInput(ns("func"), "Function", choices=c("raw", "mean", "min", "max", "median", "diffMax", "sum"), selected = "mean"),
          selectInput(ns("agg"), "Aggregation", choices=NULL),
          selectInput(ns("fill"), "Fill missing values with", choices=c("null", "previous"), selected = "null")
        ),
        box(
          width = 3,
          # Select whether to overlay smooth trend line
          checkboxInput(inputId = ns("smoother"), label = strong("Overlay trend line"), value = FALSE),
          
          # Display only if the smoother is checked
          conditionalPanel(condition = "input.smoother == true", ns = ns,
                           sliderInput(inputId = ns("smootherFactor"), label = "Smoother span:",
                                       min = 0.01, max = 1, value = 0.1, step = 0.01),
                           HTML("Higher values give more smoothness.")
          )
        ),
        box(
          width = 4,
          downloadButton(ns("exportDataCsv"), "Export csv-file"),
          downloadButton(ns("exportDataXlsx"), "Export Excel-file")
        )
      )
    ),
    fluidRow(
      box(
       title="Graph",
       status="primary",
       width = 12,
       dygraphOutput(ns("plot"))
      ),
      box(
        title="Data Summary",
        status="primary",
        width = 4,
        verbatimTextOutput(ns("summaryOfData"))
      ),
      box(
        title="Data Head (first 6 entries)",
        status="primary",
        width = 4,
        verbatimTextOutput(ns("headOfData"))
      ),
      box(
        title="Data Tail (last 6 entries)",
        status="primary",
        width = 4,
        verbatimTextOutput(ns("tailOfData"))
      )
    )
  )
}

dataexplorerModule <- function(input, output, session) {
  
  observe({
    dataPointList <- dataPoints() %>% dplyr::select(abbreviation)
    
    # rename the set if there is only one value
    # https://stackoverflow.com/questions/43098849/display-only-one-value-in-selectinput-in-r-shiny-app
    if (nrow(dataPointList) == 1) {
      names(dataPointList) <- as.character(dataPointList[1,1])
    }
    
    updateSelectInput(session, 'dataPointAbbr',
                         choices = dataPointList
    )
  })
 
  observe({
    if(input$func == "raw"){
      updateSelectInput(session, 'agg',
                        choices = c("")
      )
    }else{
      updateSelectInput(session, 'agg',
                        # choices = c("15m","1h", "1d", "1W", "1M", "1Y"),
                        choices = list("15 minutes" = "15m","1 hour" = "1h", "1 day" = "1d", "1 week" = "1W", "1 month" = "1M", "1 year" = "1Y"),
                        selected = "1d"
      )
    }
  })
  
  # data fetching
  raw <- reactive({
    withProgress(message = 'Fetching data', detail = input$dataPointAbbr, value = NULL, {
      data <- getTimeSeries(input$dataPointAbbr, datetimeStart = NULL, datetimeEnd = NULL, func = input$func, agg = input$agg, fill = input$fill)
      data <- data %>% na.omit()
      # print(data)
      # saveRDS(data, paste0(here::here(), "/app/shiny/temp/temp.rds"))

      if(input$smoother){
        smooth.df <- data.frame(lowess(x = data$time, y = data[, 2], f = input$smootherFactor))
        data$smooth <- smooth.df$y
      }
            
      return(data)
      })
  })
  
  # data fetching
  data <- reactive({
    withProgress(message = 'Smoothing data', detail = input$dataPointAbbr, value = NULL, {
      data <- raw()
      if(input$smoother){
        smooth.df <- data.frame(lowess(x = data$time, y = data[, 2], f = input$smootherFactor))
        data$smooth <- smooth.df$y
      }
      
      return(data)
    })
  })
  
  exportData <- reactive({
    withProgress(message = 'Creating Export data', detail = input$dataPointAbbr, value = NULL, {
      # locTimeZone <- configFileApp()[["bldgTimeZone"]]
      exportData <- data()
      # Excel can't handle timezones and write_xlsx converts automatically to PosixCt with UTC.
      exportData$time <- as.character(exportData$time, '%d.%m.%Y %H:%M:%S')
      # exportData$time <- force_tz(exportData$time, tzone = locTimeZone)
      
      if(input$smoother){
        names(exportData) <- c("time", input$dataPointAbbr, "smooth")
      } else {
        names(exportData) <- c("time", input$dataPointAbbr)
        
      }
      return(exportData)
    })
  })
  
  output$summaryOfData <- renderPrint({
    summary(data()[, 2])
  })
  
  output$headOfData <- renderPrint({
    head(data())
  })
  
  output$tailOfData <- renderPrint({
    tail(data())
  })

  output$plot <- renderDygraph({
    xts <- xts(data(), order.by = data()$time)
    
    list <- data.frame(lapply(dataPoints() %>% filter(abbreviation == input$dataPointAbbr), as.character), stringsAsFactors = FALSE)

    dpName <- list$name
    dpType <- list$dpType
    dpUnit <- list$unit
    
    # print(data())
    dygraph(xts, main = paste0(dpName, " - ", input$dataPointAbbr)) %>%
      dyAxis("y", label = paste0(input$dataPointAbbr, " (", dpUnit, ")"))  %>%
      dyRangeSelector()
  })
  
  
  fileName <- reactive({
    if(input$agg == "" | input$func == "raw"){agg <- "none"}else{agg <- input$agg}
    fileName <- paste0(input$dataPointAbbr, "_", input$func, "_", agg)
    # print(fileName)
    return(fileName)                
  })
  
  output$exportDataCsv <- downloadHandler(
    filename = function() {
      paste0(fileName(), ".csv")
    },
    content = function(file) {
      write.table(exportData(), file = file, row.names = FALSE, sep = ";")
    }
  )
  
  output$exportDataXlsx <- downloadHandler(
    filename = function() {
      paste0(fileName(), ".xlsx")
    },
    content = function(file) {
      write_xlsx(exportData(), path = file)
    }
  )

}


