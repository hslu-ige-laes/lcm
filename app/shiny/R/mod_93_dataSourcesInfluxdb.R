dataSourcesModuleInfluxdbUI <- function(id) {

  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title="Influx Database Overview",
        status="primary",
        width = 12,
        useShinyalert(), # Set up shinyalert
        helpText("Get sensor data measurements from a locale Influx Database."),
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

dataSourcesModuleInfluxdb <- function(input, output, session) {

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
    datatable(configFileInfluxdb(),
              selection = "single",
              filter = "none",
              options = list(pageLength = 20, bFilter = 0, bLengthChange = 0, ordering = FALSE, bInfo = 0),
              escape = FALSE)
  })
  
  # Add New Entry Functionality
  observeEvent(input$addButton, {
    showModal({
      ns <- session$ns
      modalDialog(title = "Add new data source",
                  size = "l",
                  easyClose = FALSE,
                  fluidPage(
                    fluidRow(
                      column(
                        width = 3,
                        textInput(ns("sourceName"), label = "Source Name", width = "200px", placeholder = "user defined source name")
                      ),
                      column(
                        width = 3,
                        textInput(ns("influxdbHost"), "InfluxDB Host Address", width = 250, placeholder = "e.g. 192.168.1.13")
                      ),
                      column(
                        width = 2,
                        textInput(ns("influxdbPort"), "Port", width = 70, placeholder = "8086", value = "8086")
                      ),
                      column(
                        width = 2,
                        textInput(ns("influxdbUser"), "Username", width = 120, placeholder = "optional")
                      ),
                      column(
                        width = 2,
                        passwordInput(ns("influxdbPwd"), "Password", width = 120, placeholder = "optional")
                      )
                    ),
                    fluidRow(
                      column(
                        width = 2,
                        actionButton(ns("influxdbQueryDbButton"), "1. Query databases")
                      )
                    ),
                    fluidRow(
                      tags$hr(),
                      column(
                        width = 6,
                        selectInput(ns("influxdbDatabase"), "Select database", choices=NULL)
                      )
                    ),
                    fluidRow(
                      column(
                        width = 2,
                        actionButton(ns("previewButton"), "2. Test settings and preview data")
                      )
                    ),
                    fluidRow(
                      tags$hr(),
                      column(
                        width = 2,
                        actionButton(ns("addNewButton"), label = "3. Add new data source")
                      )
                    ),
                    fluidRow(
                      tags$hr(),
                      DTOutput(ns("previewTable"))
                    )
                  )
      )
    })
  })
  
  observeEvent(input$influxdbQueryDbButton, {
    withProgress(message = 'InfluxDB Connection', detail = "Query databases, please wait (timeout = 10s)", value = NULL, {
      
      influxDB.dbOverview <<- filter(influxdbGetDatabases(host = input$influxdbHost,
                                                          port = input$influxdbPort,
                                                          user = input$influxdbUser,
                                                          pwd = input$influxdbPwd), 
                                     name != "_internal")
    })
    
    updateSelectizeInput(session, 'influxdbDatabase',
                         choices = influxDB.dbOverview$name,
                         server = TRUE
    )
  })
  
  # tbd: delete entries if some inputs get changed

  output$previewTable <- renderDT({
    
    # Take a dependency on input$previewButton and prevent first running
    if (input$previewButton == 0)
      return()
    
    if(input$influxdbDatabase == ""){
      shinyalert(
        title = "Error",
        text = "Please query first the databases and select one.",
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
      return()
    }
    
    # Use isolate() to avoid dependency on input$xy
    data <- isolate(
      influxdbGetMeasurements(host = input$influxdbHost,
                              port = input$influxdbPort,
                              user = input$influxdbUser,
                              pwd = input$influxdbPwd,
                              database = input$influxdbDatabase)
    )

    if(is.null(data)){

      shinyalert(
        title = "Error",
        text = "Could not connect to data source, please verify settings.",
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

    }else{
      shinyalert(
        title = "Success",
        text = "Good, the settings seem to be in order. The table shows all measurements of the selected database. Don't forget to save the settings by pressing button nr. 3 !",
        closeOnEsc = TRUE,
        closeOnClickOutside = TRUE,
        html = TRUE,
        type = "success",
        showConfirmButton = FALSE,
        showCancelButton = FALSE,
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )
      return(data)
    }
  }, class = 'cell-border stripe',
     selection = "none",
     filter = "none",
     options = list(pageLength = 5, bFilter = 0, bLengthChange = 0, ordering = FALSE)
  )

  observeEvent(input$addNewButton, {
    
    # create list with source names to avoid duplicates
    sourceNameList <- do.call("rbind", 
                              list(configFileCsv() %>% select(sourceName),
                                   configFileTtn() %>% select(sourceName),
                                   configFileInfluxdb() %>% select(sourceName)
                              )
    )
    
    # verifiy whether all fields are filled out
    if((input$sourceName == "") | (input$influxdbHost == "") | (input$influxdbPort == "")| (input$influxdbDatabase == "")){
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
    } else if (input$sourceName %in% unlist(sourceNameList)) {
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
      configInfluxdb.old <- configFileInfluxdb()
      configInfluxdb.newItem <- data.frame(sourceName = input$sourceName,
                                           influxdbHost = input$influxdbHost,
                                           influxdbPort = input$influxdbPort,
                                           influxdbUser = input$influxdbUser,
                                           influxdbPwd = input$influxdbPwd,
                                           influxdbDatabase = input$influxdbDatabase
      )
      configInfluxdb.new <- rbind(configInfluxdb.old, configInfluxdb.newItem)
      write_csv2(configInfluxdb.new, here::here("app", "shiny", "config", "configInfluxdb.csv"))
      
      removeModal()
    }
  })
  
  # Delete Entry Functionality.
  observeEvent(input$deleteButton,{
    showModal({
      ns <- session$ns
      
      # check if row is selected
      if(length(input$tableContent_rows_selected) >= 1 ){
        # check if selected data source is used in data/dataPoints.csv
        configuredSources <- dataPoints() %>% select(sourceName)
        sourceName <- configFileInfluxdb()[input$tableContent_rows_selected,1]
        if(sourceName %in% unlist(configuredSources)) {
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
            text = paste0("Are you sure to delete the database entry  ", "'", sourceName, "'"),
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
    configInfluxdb.old <- configFileInfluxdb()
    configInfluxdb.new <- configInfluxdb.old[-c(input$tableContent_rows_selected), ]
    write_csv2(configInfluxdb.new, here::here("app", "shiny", "config", "configInfluxdb.csv"))
    removeModal()
  }
}

