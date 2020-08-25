# ======================================================================
# tbd: automatically refresh the page when pageTitle changes in csv
# ======================================================================
configurationModuleUI <- function(id) {
  #' Application Configuration UI
  #'
  #' User-Interface for the application configuration
  #' @param id id for ns()
  #' @export
  #' @author Reto Marek

  ns <- NS(id)

  
  tagList(
    fluidRow(
      box(
        title = "Settings > Configuration",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        tabsetPanel(
          id = "tabsetSettings",
          tabPanel("General",
                   fluidRow(
                     box(
                       solidHeader = FALSE,
                       status="primary",
                       width = 12,
                       actionButton(ns("saveButton"), "Save settings in configApp.csv")
                     )
                   ),
                   fluidRow(
                     tags$br(),
                     box(
                       title="Page Title",
                       status="primary",
                       width = 3,
                       textInput(ns("pageTitle"), "Page title", width = NULL, placeholder = NULL),
                       tags$br()
                     ),
                     box(
                       title="Building Altitude",
                       status="primary",
                       width = 3,
                       helpText("The altitude is used for the mollier hx diagram."),
                       numericInput(ns("bldgAltitude"), "Altitude (meters above sea level)", value = NULL, min = 0, max = 3000, step = 50, width = "200px"),
                       tags$br()
                     ),
                     box(
                       title="Time Zone",
                       status="primary",
                       width = 3,
                       helpText("Each data source can have different time zones which get configured in the data sources tab."),
                       helpText("The time zone below is the target to which all imported data get converted"),
                       helpText("Please note that a change doesnt change already imported data!"),
                       selectInput(inputId = ns("bldgTimeZone"), 
                                   label = "Time Zone of Building",
                                   choices = timeZoneList,
                                   selected = NULL,
                                   selectize = FALSE
                       )
                     )
                   )
          )
        )
      )
    )
  )
}

configurationModule <- function(input, output, session) {
  #' Application Configuration
  #'
  #' Server-function for the application configuration
  #' @param filename a String representing the filename inclusive extension.
  #' @export
  #' @author Reto Marek

  observeEvent(input$saveButton, {
    # the theme gets saved into the dataframe in configurationThemeModule.R
    # via an observeEvent on the drowdown
    saveConfigFile(here::here("app", "shiny", "data", "configApp.csv"), "pageTitle", input$pageTitle)
    saveConfigFile(here::here("app", "shiny", "data", "configApp.csv"), "bldgAltitude", input$bldgAltitude)
    saveConfigFile(here::here("app", "shiny", "data", "configApp.csv"), "bldgTimeZone", input$bldgTimeZone)
    shinyalert(
      title = "Success",
      text = "Settings applied",
      closeOnEsc = TRUE,
      closeOnClickOutside = TRUE,
      html = TRUE,
      type = "success",
      showConfirmButton = FALSE,
      showCancelButton = FALSE,
      timer = 2000,
      imageUrl = "",
      animation = TRUE
    )
  })
  
  observe({
    updateTextInput(session = session, inputId = "pageTitle", value = configFileApp()[["pageTitle"]])
  })
  
  observe({
    updateNumericInput(session = session, inputId = "bldgAltitude", value = configFileApp()[["bldgAltitude"]])
  })
  
  observe({
    updateSelectInput(session = session, inputId = "bldgTimeZone", selected = configFileApp()[["bldgTimeZone"]])
  })
  
}

