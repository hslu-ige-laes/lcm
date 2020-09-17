dataSourcesModuleTtnUI <- function(id) {

  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title="TTN Application Overview",
        status="primary",
        width = 12,
        useShinyalert(), # Set up shinyalert
        helpText("Add THE THINGS Network applications to integrate LoRaWAN sensor data."),
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

dataSourcesModuleTtn <- function(input, output, session) {

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
    datatable(configFileTtn(),
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
                        textInput(ns("ttnAppId"), label = "Application ID", width = "200px", placeholder = "from thethingsnetwork.org Console")
                      ),
                      column(
                        width = 4,
                        textInput(ns("ttnAccessKey"), label = "Access Key", width = "500px", placeholder = "e.g. ttn-account-v2.XYZ...")
                      ),
                      column(
                        width = 2,
                        checkboxInput(ns("ttnFetchingEnabled"), label = "Fetching Enabled", width = "200px", value = TRUE)
                      )
                    ),
                    fluidRow(
                      column(
                        width = 2,
                        actionButton(ns("previewButton"), "1. Test settings and preview data")
                      )
                    ),
                    fluidRow(
                      tags$hr(),
                      column(
                        width = 2,
                        actionButton(ns("addNewButton"), label = "2. Add new data source")
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
  
  saveNewEntry <- function(){
    configTtn.old <- configFileTtn()
    configTtn.newItem <- data.frame(sourceName = input$sourceName,
                                    ttnAppId = input$ttnAppId,
                                    ttnAccessKey = input$ttnAccessKey,
                                    ttnFetchingEnabled = as.logical(input$ttnFetchingEnabled)
    )
    configTtn.new <- rbind(configTtn.old, configTtn.newItem)
    write_csv2(configTtn.new, here::here("app", "shiny", "config", "configTtn.csv"))
    
    # create new directory
    dir.create(here::here("app", "shiny", "data", "ttn", input$sourceName))
    ttnFetchServerData()
    
    shinyalert(
      title = "Data source folder",
      text = paste0("Files got saved here: ", here::here("app", "shiny", "data", "ttn", input$sourceName)),
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
  
  observeEvent(input$addNewButton, {
    
    # create list with source names to avoid duplicates
    sourceNameList <- do.call("rbind", 
                              list(configFileCsv() %>% select(sourceName),
                                   configFileTtn() %>% select(sourceName),
                                   configFileInfluxdb() %>% select(sourceName)
                              )
    )
    
    # verifiy whether all fields are filled out
    if((input$sourceName == "") | (input$ttnAppId == "") | (input$ttnAccessKey == "")){
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
      
    } else { # show warning if fetching is disabled
      if (input$ttnFetchingEnabled == FALSE) {
        shinyalert(
          title = "Warning",
          text = "Fetching is disabled. This means that no values are automatically queried and stored.",
          callbackR = function(x){
            if(x) saveNewEntry()
          },
          closeOnEsc = FALSE,
          closeOnClickOutside = FALSE,
          html = FALSE,
          type = "warning",
          showConfirmButton = TRUE,
          showCancelButton = TRUE,
          confirmButtonText = "OK",
          confirmButtonCol = "#AEDEF4",
          cancelButtonText = "go back",
          timer = 0,
          imageUrl = "",
          animation = TRUE
        )
      }
      # save settings
      if(input$ttnFetchingEnabled == TRUE){
        saveNewEntry()
      }
    }
  })
  
  output$previewTable <- renderDT({
    
    # Take a dependency on input$previewButton and prevent first running
    if (input$previewButton == 0)
      return()
    
    # Use isolate() to avoid dependency on input$xy
    data <- isolate(
      ttnReadServerData(appId=input$ttnAppId,
                        key = input$ttnAccessKey,
                        locTimeZone = configFileApp()[["bldgTimeZone"]],
                        range = "1d")
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
        text = "Good, the settings seem to be in order. The table shows the stored data of the last 24 hours. Don't forget to save the settings by pressing button nr. 2.",
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
  },
  class = 'cell-border stripe',
  selection = "none", 
  filter = list(position = 'top', clear = FALSE, plain = FALSE),
  options = list(pageLength = 5,
                 autoWidth = TRUE,
                 stateSave = TRUE,
                 scrollX = TRUE
  )
  )
  
  # Delete Entry Functionality.
  observeEvent(input$deleteButton,{
    showModal({
      ns <- session$ns

      # check if row is selected
      if(length(input$tableContent_rows_selected) >= 1 ){
        # check if selected data source is used in data/dataPoints.csv
        configuredSources <- dataPoints() %>% select(sourceName)
        sourceName <- configFileTtn()[input$tableContent_rows_selected,1]
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
    configTtn.old <- configFileTtn()
    configTtn.new <- configTtn.old[-c(input$tableContent_rows_selected), ]
    write_csv2(configTtn.new, here::here("app", "shiny", "config", "configTtn.csv"))
    removeModal()
    folderPath <- here::here("app", "shiny", "data", "ttn", configTtn.old[input$tableContent_rows_selected,1])
    shinyalert(
      title = "Delete folder and files?",
      text = paste0("Do you want to delete the folder and the corresponding files of  ", folderPath, " ?"),
      callbackR = function(x){
        if(x) unlink(folderPath, recursive = TRUE)
      },
      closeOnEsc = FALSE,
      closeOnClickOutside = FALSE,
      html = FALSE,
      type = "warning",
      showConfirmButton = TRUE,
      showCancelButton = TRUE,
      confirmButtonText = "Yes",
      confirmButtonCol = "#AEDEF4",
      cancelButtonText = "No, leave the files",
      timer = 0,
      imageUrl = "",
      animation = TRUE
    )
  }
}

