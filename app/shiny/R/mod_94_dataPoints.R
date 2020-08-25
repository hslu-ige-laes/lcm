
# ======================================================================


# ======================================================================

dataPointsModuleUI <- function(id) {
  #' Data Points Module UI
  #'
  #' User-Interface for the module data points
  #' @param id id for ns()
  #' @export
  #' @author Reto Marek
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title="Settings > Data Points",
        status="primary",
        solidHeader = TRUE,
        width = 12,
        useShinyalert(), # Set up shinyalert
        helpText("Configure data points from data sources."),
        tags$hr(),
        actionButton(ns("addButton"),label = "Add new"),
        actionButton(ns("deleteButton"),label = "Delete selected"),
        tags$br(),
        tags$hr(),
        dataTableOutput(ns("tableContent")),
        uiOutput(ns("script"))
      )
    )
  )
}

dataPointsModule <- function(input, output, session) {
  #' Data Points Module
  #'
  #' Server-function for the module data points
  #' @export
  #' @author Reto Marek
  #'

  # tbd: abfangen wenn dataPoints.csv leer ist oder nicht existiert... dito andere files.
  # tbd: braucht es oben in ui das noch: uiOutput(ns("script")) ?
  
  # Read Config File.
  ## define separate function to read because of encoding
  # readFunc <- function(x){read_csv2(x, locale = locale(encoding = "UTF-8"))}
  # configDataPoints <- reactiveFileReader(500, session, here::here("app", "shiny", "config","dataPoints.csv"), readFunc)
  
  # Create Table.
  output$tableContent <- renderDataTable({
    datatable(dataPoints(),
              selection = "single",
              filter = "none",
              options = list(pageLength = 15, bFilter = 0, bLengthChange = 0, bInfo = 1),
              escape = FALSE)
  })
  
  # Add New Entry Functionality
  observeEvent(input$addButton, {
    sourceNameList <- do.call("rbind", 
                              list(configFileCsv() %>% select(sourceName),
                                   configFileTtn() %>% select(sourceName),
                                   configFileInfluxdb() %>% select(sourceName)
                              )
    )
    
    # rename the set if there is only one value
    # https://stackoverflow.com/questions/43098849/display-only-one-value-in-selectinput-in-r-shiny-app
    if (nrow(sourceNameList) == 1) {
      names(sourceNameList) <- as.character(sourceNameList[1,1])
    }
    
    showModal({
      ns <- session$ns
      modalDialog(title = "Add new data point",
                  size = "l",
                  easyClose = FALSE,
                  fluidPage(
                    fluidRow(
                      column(
                        width = 4,
                        textInput(ns("dpAbbreviation"), label = "Abbreviation", placeholder = "user defined short name")
                      ),
                      column(
                        width = 4,
                        textInput(ns("dpName"), label = "Name", placeholder = "user defined long name")
                      ),
                      column(
                        width = 4,
                        selectInput(inputId = ns("dpType"), 
                                    label = "Datapoint Type",
                                    choices = c("select type" = "",
                                                "Room Temperature" = "tempRoom",
                                                "Room Humidity" = "humRoom",
                                                "Room Air Quality CO2" = "aQualRoom",
                                                "Flat Hot Water" = "hotWaterFlat",
                                                "Flat Heat Energy" = "heatEnergyFlat",
                                                "Flat Ventilation" = "ventilationFlat",
                                                "Flat Electricity" = "eleFlat",
                                                "Outside Temperature" = "tempOutsideAir",
                                                "Central Energy Heat" = "energyHeatCentral",
                                                "Central Supply Temperature Heat" = "tempSupplyHeat",
                                                "Central Return Temperature Heat" = "tempReturnHeat"),
                                    selectize = FALSE
                        )
                      )
                    ),
                    fluidRow(
                      column(
                        width = 4,
                        textInput(ns("dpUnit"), label = "Unit", placeholder = paste0("e.g. ", intToUtf8(176), "C"))
                      ),
                      column(
                        width = 4,
                        selectInput(ns("dpFlat"), "Locality", choices=c("Building",bldgHierarchy()$flat))
                      ),
                      column(
                        width = 4,
                        selectInput(ns("dpRoom"), "Room", choices=NULL)
                      )
                    ),
                    fluidRow(
                      column(
                        width = 4,
                        selectInput(inputId = ns("dpSourceName"), 
                                    label = "Data Source",
                                    choices = c("select data source" = "",
                                                sourceNameList),
                                    selectize = FALSE
                        )
                      ),
                      column(
                        width = 4,
                        selectInput(inputId = ns("dpSourceReference"), 
                                    label = "Data Point",
                                    choices = NULL,
                                    selectize = FALSE
                        )
                      ),
                      column(
                        width = 4,
                        selectInput(inputId = ns("dpFieldKey"), 
                                    label = "Field Key (InfluxDB only)",
                                    choices = NULL,
                                    selectize = FALSE
                        )
                      )
                    ),
                    fluidRow(
                      column(
                        width = 4,
                        numericInput(inputId = ns("valueFactor"), 
                                     label = "Factor",
                                     value = 1,
                                     min = 0.0000000000000000001,
                                     max = 10000000000000000000,
                                     step = 0.000000001
                        )
                      ),
                      column(
                        width = 4,
                        selectInput(inputId = ns("valueType"), 
                                    label = "Value Type",
                                    choices = c("absolute Value" = "absVal",
                                                "Counter Reading" = "counterVal"),
                                    selected = "absVal",
                                    selectize = FALSE
                        )
                      )
                    ),
                    fluidRow(
                      column(
                        width = 6,
                        actionButton(ns("previewButton"), "1. Test settings and preview data")
                      ),
                      column(
                        width = 6,
                        actionButton(ns("addNewButton"), label = "2. Add new data point")
                      )
                    ),
                    fluidRow(
                      tags$hr(),
                      dygraphOutput(ns("previewPlot"), height = "300px")
                    )
                  )
      )
    })
  })

  observeEvent(input$dpFlat, {
    
    # Central is always available, on Building as well in flats
    rooms <- data.frame("Central")
    names(rooms) <- "rooms"
    if(input$dpFlat != "Building"){
      rooms <- rbind(rooms, getRoomsOfFlat(input$dpFlat))
    }
    # rename the set if there is only one value
    # https://stackoverflow.com/questions/43098849/display-only-one-value-in-selectinput-in-r-shiny-app
    if (nrow(rooms) == 1) {
      names(rooms) <- as.character(rooms[1,1])
    }
    updateSelectizeInput(session, "dpRoom",
                         choices = as.list(rooms),
                         server = TRUE
    )
  })
  
  # Update data point pull down according to selected dpSourceName
  observeEvent(input$dpSourceName, {
    withProgress(message = "Updating data", detail = input$dpSourceName, value = NULL, { 
      dpList <- list()
      dpNames <- getDataPointNames(input$dpSourceName)
      if(!is.null(dpNames)){
        for(i in 1:nrow(dpNames)){
          dpList[as.character(dpNames[i,1])] <- as.character(dpNames[i,1])
        }
      }
      
      if(length(dpList) > 1){
        dpList <- append(list("select data point" = ""), dpList)
      }
      
      updateSelectInput(session, "dpSourceReference",
                        choices = dpList
      )
    })
  })
  
  # Update field key pull dowm according to selected dpSourceReference (only for influxDB data sources)
  observeEvent(input$dpSourceReference, {
    withProgress(message = 'Updating data', detail = input$dpSourceReference, value = NULL, {
      
      dpFieldKeyList <- list()
      
      # check if source is influx
      if((input$dpSourceName %in% configFileInfluxdb()$sourceName) & (input$dpSourceReference != "")){
        list <- configFileInfluxdb() %>% filter(sourceName == input$dpSourceName)
        
        dpFieldKeys <- influxdbGetFieldKeys(host = list$influxdbHost,
                                            port = list$influxdbPort,
                                            user = list$influxdbUser,
                                            pwd = list$influxdbPwd,
                                            database = list$influxdbDatabase,
                                            datapoint = input$dpSourceReference
        )
        if(!is.null(dpFieldKeys)){
          for(i in 1:nrow(dpFieldKeys)){
            dpFieldKeyList[as.character(dpFieldKeys[i,1])] <- as.character(dpFieldKeys[i,1])
          }
        }

        if(length(dpFieldKeyList) > 1){
          dpFieldKeyList <- append(list("select field key" = ""), dpFieldKeyList)
        }
      } else {
        dpFieldKeyList <- list("no field key required" = "")
      }
      
      updateSelectInput(session, "dpFieldKey",
                        choices = dpFieldKeyList
      )
    })
  })
  
  observeEvent(input$addNewButton, {
    
    # create list with abbreviations to avoid duplicates
    abbreviationList <- dataPoints() %>% select(abbreviation)
    
    # verifiy whether all fields are filled out
    if((input$dpAbbreviation == "") | (input$dpName == "") | (input$dpRoom == "") | (input$dpType == "") | (input$dpSourceName == "") | (input$dpUnit == "")){
      
      shinyalert(
        title = "Error",
        text = "One or more fields seem to be empty, please verify the inputs.",
        closeOnEsc = TRUE,
        closeOnClickOutside = TRUE,
        html = TRUE,
        type = "error",
        showConfirmButton = TRUE,
        showCancelButton = FALSE,
        confirmButtonText = "OK",
        confirmButtonCol = "#AEDEF4",
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )
    } else if(input$dpAbbreviation %in% unlist(abbreviationList)) {
      shinyalert(
        title = "Error",
        text = paste0("The abbreviation ", "'", input$dpAbbreviation, "'", " already exists. Please choose another one."),
        closeOnEsc = TRUE,
        closeOnClickOutside = TRUE,
        html = TRUE,
        type = "error",
        showConfirmButton = TRUE,
        showCancelButton = FALSE,
        confirmButtonText = "OK",
        confirmButtonCol = "#AEDEF4",
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )
      
    } else {
      # save settings
      dataPoints.old <- dataPoints()

      dataPoints.newItem <- data.frame(abbreviation = input$dpAbbreviation,
                                       name = input$dpName,
                                       flat = input$dpFlat,
                                       room = input$dpRoom,
                                       dpType = as.character(input$dpType),
                                       sourceName = as.character(input$dpSourceName),
                                       sourceReference = as.character(input$dpSourceReference),
                                       unit = as.character(input$dpUnit),
                                       fieldKey = as.character(input$dpFieldKey),
                                       valueType = as.character(input$valueType),
                                       valueFactor = as.numeric(input$valueFactor)
                                       )

      dataPoints.new <- rbind(dataPoints.old, dataPoints.newItem)
      write_csv2(dataPoints.new, here::here("app", "shiny", "config", "dataPoints.csv"))
      
      removeModal()
      
    }
  })
  
  output$previewPlot <- renderDygraph({
    # Take a dependency on input$previewButton and prevent first running
    if ((input$previewButton == 0) | is.null(input$previewButton))
      return()

    # Use isolate() to avoid dependency on input$xy
    p <- isolate({
      req(input$dpSourceName)
      req(input$dpSourceReference)

      withProgress(message = 'Fetching data and create plot', detail = paste0(input$dpSourceName, " : ", input$dpSourceReference), value = NULL, { 
        
        plotData <- getTimeSeries(dpSource = input$dpSourceName, dpSourceRef = input$dpSourceReference, dpFieldKey = input$dpFieldKey, valueFactor = input$valueFactor, valueType = input$valueType)
 
        xts <- xts(plotData[,-1], order.by = plotData$time)
      
        dygraph(xts, main = input$dpName) %>%
          dyAxis("y", label = paste0(input$dpType, " (", input$dpUnit, ")"))  %>%
          dyRangeSelector()
      })
    })
    return(p)
  })
  
  # Delete Entry Functionality.
  observeEvent(input$deleteButton,{
    showModal({
      ns <- session$ns
      
      dataPoint <- dataPoints()[input$tableContent_rows_selected,1]
      
      # check if row is selected
      if(length(input$tableContent_rows_selected) >= 1 ){
        shinyalert(
          title = "Warning",
          text = paste0("Are you sure to delete the datapoint  ", "'", dataPoint, "'"),
          callbackR = function(x){
            if(x) deleteEntry()
          },
          closeOnEsc = FALSE,
          closeOnClickOutside = FALSE,
          html = FALSE,
          type = "warning",
          showConfirmButton = TRUE,
          showCancelButton = TRUE,
          confirmButtonText = "Yes",
          confirmButtonCol = "#AEDEF4",
          cancelButtonText = "No, go back",
          timer = 0,
          imageUrl = "",
          animation = TRUE
        )
      }else{
        shinyalert(
          title = "No data point selected",
          text = "Please select first a row in the data points table.",
          closeOnEsc = TRUE,
          closeOnClickOutside = TRUE,
          html = FALSE,
          type = "info",
          showConfirmButton = TRUE,
          showCancelButton = FALSE,
          confirmButtonText = "OK",
          confirmButtonCol = "#AEDEF4",
          timer = 0,
          imageUrl = "",
          animation = TRUE
        )
      }
    })
  })
  
  deleteEntry <- function(){
    dataPoints.old <- dataPoints()
    dataPoints.new <- dataPoints.old[-c(input$tableContent_rows_selected), ]
    write_csv2(dataPoints.new, here::here("app", "shiny", "config", "dataPoints.csv"))
    removeModal()
  }
}
