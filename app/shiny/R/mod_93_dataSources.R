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
          tabPanel("influxDB v1.x",
                   dataSourcesModuleInfluxdbv1xUI("datasources_influxdbv1x")
          )
        )
      )
    )
  )
}

dataSourcesModule <- function(input, output, session) {


}
