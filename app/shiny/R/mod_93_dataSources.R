
# ======================================================================

# ======================================================================

dataSourcesModuleUI <- function(id) {
  #' Data Sources Module UI
  #'
  #' User-Interface for the module data sources
  #' @param id id for ns()
  #' @export
  #' @author Reto Marek
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Settings > Data Sources",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        tabsetPanel(
          id = "tabsetDataSources",
          tabPanel("the things network",
                    dataSourcesModuleTtnUI("datasources_ttn")
          ),
          tabPanel("influxDB",
                   dataSourcesModuleInfluxdbUI("datasources_influxdb")
          ),
          tabPanel("csv Files",
                   dataSourcesModuleCsvUI("datasources_csv")
          )
        )
      )
    )
  )
}

dataSourcesModule <- function(input, output, session) {
  #' Data Sources Module
  #'
  #' Server-function for the module data sources
  #' @export
  #' @author Reto Marek
  #'
  
  # ======================================================================


}

