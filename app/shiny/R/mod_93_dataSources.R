dataSourcesModuleUI <- function(id) {

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
          tabPanel("csv Files",
                   dataSourcesModuleCsvUI("datasources_csv")
          ),
          tabPanel("the things network",
                    dataSourcesModuleTtnUI("datasources_ttn")
          ),
          tabPanel("influxDB",
                   dataSourcesModuleInfluxdbUI("datasources_influxdb")
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

