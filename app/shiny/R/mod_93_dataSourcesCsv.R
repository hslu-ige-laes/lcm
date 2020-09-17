# import csv script functions and create list for pull down menu
csvScriptFiles <- as.data.frame(gsub("\\.R$","", list.files(here::here("app", "shiny", "csvScripts"), pattern="\\.R$")))
csvScriptList <- data.frame()
if(nrow(csvScriptFiles) > 0){
  for(row in 1:nrow(csvScriptFiles)){
    csvScriptFilePath <- paste0(here::here("app", "shiny", "csvScripts"), "/", csvScriptFiles[row,1], ".R")
    source(csvScriptFilePath)
    csvScriptList <- rbind(csvScriptList, as.data.frame(getFunctionsInFile(csvScriptFilePath)))
  }
}
names(csvScriptList)[1] <- "name"
csvScriptList <- csvScriptList %>% arrange(desc(name))

dataSourcesModuleCsvUI <- function(id) {

  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title="CSV File Overview",
        status="primary",
        width = 12,
        useShinyalert(), # Set up shinyalert
        helpText("Import sensor data from a csv-file."),
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

dataSourcesModuleCsv <- function(input, output, session) {

  # Add script to detect selected row.
  output$script<-renderUI({
    fluidPage(
      tags$script("$(document).on('click', '#tableContent button', function () {
                   Shiny.onInputChange('lastClickId',this.id);
                   Shiny.onInputChange('lastClick', Math.random()) });")
    ) 
  })
  
  # Create Table.
  output$tableContent <- renderDataTable({
    datatable(configFileCsv(),
              selection = "single",
              filter = "none",
              options = list(pageLength = 20, bFilter = 0, bLengthChange = 0, ordering = FALSE, bInfo = 0),
              escape = FALSE)
  })
  
  # Add New Entry Functionality
  observeEvent(input$addButton, {
    showModal({
      ns <- session$ns
      # tbd: see link
      # see: https://community.rstudio.com/t/shiny-upload-a-csv-file-choose-columns-and-let-it-make-a-boxplot-or-a-barplot/13723

      modalDialog(title = "Add new data source",
                  size = "l",
                  easyClose = FALSE,
                  fluidPage(
                    useShinyjs(),
                    fluidRow(
                      column(
                        width = 3,
                        textInput(ns("sourceName"), label = "Source Name", width = "200px", placeholder = "user defined source name")
                      ),
                      column(
                        width = 3,
                        selectInput(inputId = ns("csvScript"), 
                                    label = "Parsing Script",
                                    choices = rbind(data.frame(name = "none"), csvScriptList)$name,
                                    selected = "none",
                                    selectize = FALSE
                        )
                      ),
                      column(
                        width = 6,
                        fileInput(ns("csvFileName"),
                                  label = "Choose CSV File",
                                  multiple = FALSE,
                                  accept = c("text/csv",
                                             "text/comma-separated-values,text/plain",
                                             ".csv"),
                                  placeholder = "No file selected"
                        )
                      )
                    ),
                    fluidRow(
                      tags$hr(),
                      column(
                        width = 3,
                        radioButtons(ns("csvSep"), "Separator",
                                     choices = c(Comma = ",",
                                                 Semicolon = ";",
                                                 Tab = "\t"),
                                     selected = ";")
                      ),
                      column(
                        width = 3,
                        radioButtons(ns("csvQuote"), "Quote",
                                     choices = c(None = "",
                                                 "Double Quote" = '"',
                                                 "Single Quote" = "'"),
                                     selected = ""),
                      ),
                      column(
                        width = 3,
                        selectInput(inputId = ns("sourceTimeZone"), 
                                    label = "Time Zone Source Data",
                                    choices = timeZoneList,
                                    selected = timeZoneList[2,],
                                    selectize = FALSE
                        )
                      ),
                      column(
                        width = 3,
                        selectInput(inputId = ns("colnameTime"), 
                                    label = "Time Column",
                                    choices = NULL,
                                    selected = NULL,
                                    selectize = FALSE
                        )
                      )
                    ),
                    fluidRow(
                      tags$hr(),
                      column(
                        width = 2,
                        actionButton(ns("addNewButton"), label = "Add new data source")
                      )
                    ),
                    fluidRow(
                      tags$hr(),
                      textOutput(ns("timeZoneInfo")),
                      DTOutput(ns("previewTable"))
                    )
                  )
      )
    })
  })
  
  observeEvent(input$addNewButton, {
    
    # create list with source names to avoid duplicates
    sourceNameList <- do.call("rbind", 
                              list(configFileCsv() %>% select(sourceName),
                                   configFileTtn() %>% select(sourceName),
                                   configFileInfluxdb() %>% select(sourceName)
                              )
    )
      
    # verifiy whether all fields are filled out
    if((input$sourceName == "") | (length(input$csvFileName$name) == 0)){
      shinyalert(
        title = "Error",
        text = "One or more fields seem to be empty, please verify the inputs.",
        closeOnEsc = TRUE,
        closeOnClickOutside = TRUE,
        html = TRUE,
        type = "error",
        showConfirmButton = FALSE,
        showCancelButton = FALSE,
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )
    } else if(input$sourceName %in% unlist(sourceNameList)) {
      shinyalert(
        title = "Error",
        text = paste0("The source name ", "'", input$sourceName, "'", " already exists. Please choose another one."),
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
      configCsv.old <- configFileCsv()
      configCsv.newItem <- data.frame(sourceName = input$sourceName,
                                      csvFileName = paste0(input$sourceName, "_", input$csvFileName$name),
                                      timeZone = input$sourceTimeZone
      )
      configCsv.new <- rbind(configCsv.old, configCsv.newItem)
      write_csv2(configCsv.new, here::here("app", "shiny", "config", "configCsv.csv"))
      
      # save csv file
      write_csv2(csvData(), here::here("app", "shiny", "data", "csv", paste0(input$sourceName, "_", input$csvFileName$name)))
      
      shinyalert(
        title = "Data source folder",
        text = paste0("The file '", paste0(input$sourceName, "_", input$csvFileName$name), "' got saved into this folder: '", here::here("app", "shiny", "data", "csv"), "'"),
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
      
      removeModal()
    }
  })
    
  csvDataRaw <- reactive({
    req(input$csvFileName)
    
    data <- read_delim(input$csvFileName$datapath,
                       delim = input$csvSep,
                       quote = input$csvQuote
    )
    # implement scripts
    if(input$csvScript != "none"){
      tryCatch({
        data <- do.call(input$csvScript, list(filePath = input$csvFileName$datapath))
      },
      error = function(e){
        shinyalert(
          title = "Error",
          text = "Could not read file.",
          closeOnEsc = TRUE,
          closeOnClickOutside = TRUE,
          html = FALSE,
          type = "error",
          showConfirmButton = TRUE,
          showCancelButton = FALSE,
          confirmButtonText = "OK",
          confirmButtonCol = "#AEDEF4",
          timer = 0,
          imageUrl = "",
          animation = TRUE
        )
      }
      )
    }

    if(is.null(data)){
      shinyalert(
        title = "Error",
        text = "Could not read file.",
        closeOnEsc = TRUE,
        closeOnClickOutside = TRUE,
        html = FALSE,
        type = "error",
        showConfirmButton = TRUE,
        showCancelButton = FALSE,
        confirmButtonText = "OK",
        confirmButtonCol = "#AEDEF4",
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )
      return(NULL)
    }
    return(data)
  })
  
  # hide elements if script is selected
  observe({
    toggle(id = "csvSep", condition = (input$csvScript == "none"))
    toggle(id = "csvQuote", condition = (input$csvScript == "none"))
  })
  
  observe({
    updateSelectInput(session = session, inputId = "colnameTime", choices = as.list(colnames(csvDataRaw())))
  })
  
  csvData <- reactive({
    req(input$colnameTime)
    locTimeZone <- configFileApp()[["bldgTimeZone"]]
    
    data <- csvDataRaw()
    
    colnames(data) = gsub(input$colnameTime, "time", colnames(data))
    data <- data %>% select(time, everything())
    # make timezone conversion
    # data$time <- parse_datetime(data$time, locale = locale(tz = input$sourceTimeZone))
    # data$time <- parse_date_time(data$time, "YmdHM0S", tz = input$sourceTimeZone)
    data$time <- force_tz(data$time, input$sourceTimeZone)
    data$time <- with_tz(data$time, locTimeZone)
    data$time <- round_date(data$time, unit = "second")
    data$time <- as.POSIXct(data$time, tz = locTimeZone)
    
    return(data)
  })

  observe({
    updateSelectInput(session,"colnameTime", choices=colnames(csvData))    
  })
  
  output$timeZoneInfo <- renderText({
    req(input$csvFileName)
    paste0("Preview with time converted to configured time zone '",
           configFileApp()[["bldgTimeZone"]],
           "' (see tab Configuration / Building Time Zone Setting)")
  })
  
  output$previewTable <- renderDT({
      locTimeZone <- configFileApp()[["bldgTimeZone"]]
      data <- csvData()
      datatable(data,
                class = 'cell-border stripe',
                selection = "none", 
                filter = "none",
                options = list(pageLength = 5, bFilter = 0, bLengthChange = 0, ordering = FALSE, bInfo = 0, scrollX = TRUE)) %>%
        formatDate(1, method = 'toLocaleString',  params = list("de-ch",list(timeZone = locTimeZone, hour12 = FALSE)))
  })

  # Delete Entry Functionality.
  observeEvent(input$deleteButton,{
    showModal({
      ns <- session$ns
      
      # check if row is selected
      if(length(input$tableContent_rows_selected) >= 1 ){
        # check if selected data source is used in data/dataPoints.csv
        configuredSources <- dataPoints() %>% select(sourceName)
        sourceName <- configFileCsv()[input$tableContent_rows_selected,1]
        if(sourceName %in% unlist(configuredSources)){
          shinyalert(
            title = "Warning",
            text = "One or more configured data points are still connected to this data source. Please delete these first in the section 'Data Points.'",
            closeOnEsc = TRUE,
            closeOnClickOutside = TRUE,
            html = FALSE,
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
          
          shinyalert(
            title = "Warning",
            text = paste0("Are you sure to delete the application  ", "'", sourceName, "'"),
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
        }
      }else{
        shinyalert(
          title = "No data source selected",
          text = "Please select first a row in the data sources table.",
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
    configCsv.old <- configFileCsv()
    configCsv.new <- configCsv.old[-c(input$tableContent_rows_selected), ]
    write_csv2(configCsv.new, here::here("app", "shiny", "config", "configCsv.csv"))
    removeModal()
    filePath <- here::here("app", "shiny", "data", "csv", configCsv.old[input$tableContent_rows_selected,2])
    shinyalert(
      title = "Delete file?",
      text = paste0("Do you want to delete the file '", filePath, "' ?"),
      callbackR = function(x){
        if(x) unlink(filePath, recursive = FALSE)
      },
      closeOnEsc = FALSE,
      closeOnClickOutside = FALSE,
      html = FALSE,
      type = "warning",
      showConfirmButton = TRUE,
      showCancelButton = TRUE,
      confirmButtonText = "Yes",
      confirmButtonCol = "#AEDEF4",
      cancelButtonText = "No, leave the file",
      timer = 0,
      imageUrl = "",
      animation = TRUE
    )
  }
}

