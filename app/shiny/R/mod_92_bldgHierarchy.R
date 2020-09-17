bldgHierarchyModuleUI <- function(id) {

  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title="Settings > Building Hierarchy",
        status="primary",
        solidHeader = TRUE,
        width = 12,
        useShinyalert(), # Set up shinyalert
        helpText("Set up flats and rooms to assign later on the data points to it."),
        tags$hr(),
        actionButton(ns("addButton"),label = "Add new"),
        actionButton(ns("deleteButton"),label = "Delete selected"),
        tags$br(),
        tags$hr(),
        dataTableOutput(ns("tableContent"))
      )
    )
  )
}

bldgHierarchyModule <- function(input, output, session) {

  # Create Table.
  output$tableContent <- renderDataTable({
    datatable(bldgHierarchy(),
              selection = "single",
              filter = "none",
              options = list(pageLength = 15, bFilter = 0, bLengthChange = 0, bInfo = 1),
              escape = FALSE)
  })
  
  # Add New Entry Functionality
  observeEvent(input$addButton, {
    showModal({
      ns <- session$ns
      modalDialog(title = "Add new flat",
                  size = "l",
                  easyClose = FALSE,
                  fluidPage(
                    fluidRow(
                      column(
                        width = 3,
                        textInput(ns("flat"), label = "Flat Name", placeholder = "user defined name for flat")
                      ),
                      column(
                        width = 3,
                        numericInput(ns("size"), label = "Size in square meters", value = NULL)
                      ),
                      column(
                        width = 3,
                        numericInput(ns("occupants"), label = "Number of occupants", value = NULL)
                      )
                    ),
                    fluidRow(
                      column(
                        width = 12,
                        textInput(ns("rooms"), label = "Rooms (comma-separated)", placeholder = "Dormitory,Living Room,Shower", width = "700px")
                      )
                    ),
                    fluidRow(
                      tags$hr(),
                      column(
                        width = 2,
                        actionButton(ns("addNewButton"), label = "Add new flat")
                      )
                    )
                  )
      )
    })
  })
  
  
  observeEvent(input$addNewButton, {
    
    # create list with flat names to avoid duplicates
    flatNameList <- bldgHierarchy() %>% select(flat)
    
    # verifiy whether all fields are filled out
    if((input$flat == "") | (input$size == "") | (input$occupants == "") | (input$rooms == "")){
      
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
    } else if (input$flat %in% unlist(flatNameList)) {
      shinyalert(
        title = "Error",
        text = paste0("The flat name ", "'", input$flat, "'", " already exists. Please choose another one."),
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
      bldgHierarchy.old <- bldgHierarchy()
      roomsChecked <- input$rooms
      roomsChecked <- str_replace_all(roomsChecked,";",",")
      roomsChecked <- str_replace_all(roomsChecked,"\\s\\,\\s",",")
      roomsChecked <- str_replace_all(roomsChecked,"\\,\\s",",")
      roomsChecked <- str_replace_all(roomsChecked,"\\s\\,",",")
      
      bldgHierarchy.newItem <- data.frame(flat = input$flat,
                                          size = input$size,
                                          occupants = input$occupants,
                                          rooms = roomsChecked
      )
      
      bldgHierarchy.new <- rbind(bldgHierarchy.old, bldgHierarchy.newItem)
      write_csv2(bldgHierarchy.new, here::here("app", "shiny", "config", "bldgHierarchy.csv"))
      
      removeModal()
      
    }
  })
  
  # Delete Entry Functionality.
  observeEvent(input$deleteButton,{
    
    showModal({
      ns <- session$ns
      # check if selected data source is used in data/dataPoints.csv
      flat <- bldgHierarchy()[input$tableContent_rows_selected,1]
      configuredFlats <- dataPoints() %>% select(flat) %>% unique()
      if(length(input$tableContent_rows_selected) >= 1 ){
        if(flat %in% unlist(configuredFlats)){
          shinyalert(
            title = "Warning",
            text = "One or more configured data points are still connected to this flat. Please delete these first in the section 'Data Points.'",
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
            text = paste0("Are you sure to delete the flat  ", "'", flat, "'"),
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
      } else {
        shinyalert(
          title = "No flat selected",
          text = "Please select first a row in the building hierarchy table.",
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
    bldgHierarchy.old <- bldgHierarchy()
    bldgHierarchy.new <- bldgHierarchy.old[-c(input$tableContent_rows_selected), ]
    write_csv2(bldgHierarchy.new, here::here("app", "shiny", "config", "bldgHierarchy.csv"))
    removeModal()
  }
  
}

