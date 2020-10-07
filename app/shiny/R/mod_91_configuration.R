configurationModuleUI <- function(id) {

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
                       title="Title on top left",
                       status="primary",
                       width = 3,
                       textInput(ns("pageTitle"), "Page title", width = NULL, placeholder = NULL),
                       tags$br()
                     ),
                     box(
                       title="Building Type",
                       status="primary",
                       width = 3,
                       helpText("The building type is used for electrical consumption calculations."),
                       radioButtons(ns("bldgType"), "Type", choices = c("Single Family House" = "single","Multi Family House" = "multi", selected = NULL)),
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

  observeEvent(input$saveButton, {
    # the theme gets saved into the dataframe in configurationThemeModule.R
    # via an observeEvent on the drowdown
    saveConfigFile(here::here("app", "shiny", "config", "configApp.csv"), "pageTitle", input$pageTitle)
    saveConfigFile(here::here("app", "shiny", "config", "configApp.csv"), "bldgAltitude", input$bldgAltitude)
    saveConfigFile(here::here("app", "shiny", "config", "configApp.csv"), "bldgTimeZone", input$bldgTimeZone)
    saveConfigFile(here::here("app", "shiny", "config", "configApp.csv"), "bldgType", input$bldgType)
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
  
  observe({
    updateSelectInput(session = session, inputId = "bldgType", selected = configFileApp()[["bldgType"]])
  })
  
}

