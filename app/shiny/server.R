# ======================================================================
# Server function
# ======================================================================
server <- function(input, output, session) {
  
  # Create Optional Menu Bar Items
  output$tempReductionMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "tempRoom") %>% unique()) > 0)){
      menuItem("Temperature Reduction", icon = icon("thermometer-quarter"), tabName = "tempReduction")
    }
  })
  
  output$comfortTempHumMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "tempRoom") %>% unique()) > 0) & 
       (nrow(dataPoints() %>% filter(dpType == "humRoom") %>% unique()) > 0)){
      menuItem("Comfort Temp/Hum", icon = icon("spa"), tabName = "comfortTempHum")
    }
  })

  output$comfortTempROaMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "tempRoom") %>% unique()) > 0) & 
       (nrow(dataPoints() %>% filter(dpType == "tempOutsideAir") %>% unique()) > 0)){
       menuItem("Comfort TempR/Oa", icon = icon("spa"), tabName = "comfortTempROa")
    }
  })
  
  output$comfortAqualMenuItem <- renderMenu({
    if(nrow(dataPoints() %>% filter(dpType == "aQualRoom") %>% unique()) > 0){
      menuItem("Comfort AQual", icon = icon("spa"), tabName = "comfortAQual")
    }
  })
  
  output$ventilationFlatsMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "ventilationFlat"))) > 0){
      menuItem("Ventilation Flats", icon = icon("atom"), tabName = "ventilationFlats")   
    }
  })
  
  output$hotWaterFlatsMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "hotWaterFlat"))) > 0){
      menuItem("Hot Water Flats", icon = icon("shower"), tabName = "hotWaterFlats")   
    }
  })
  
  output$heatingFlatsMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "energyHeatFlat"))) > 0){
      menuItem("Heating Flats", icon = icon("gripfire"), tabName = "heatingFlats")   
    }
  })
  
  output$heatingCentralMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "energyHeatCentral") %>% unique()) > 0) & 
       (nrow(dataPoints() %>% filter(dpType == "tempOutsideAir") %>% unique()) > 0)){      menuItem("Heating Central", icon = icon("gripfire"), tabName = "heatingCentral")   
    }
  })
  
  output$heatingCurveMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "tempSupplyHeat") %>% unique()) > 0) & 
       (nrow(dataPoints() %>% filter(dpType == "tempOutsideAir") %>% unique()) > 0)){
      menuItem("Heating Curve", icon = icon("gripfire"), tabName = "heatingCurve")   
    }
  })
  
  output$dataExplorerMenuItem <- renderMenu({
    if((nrow(dataPoints())) > 0){
      menuItem("Data Explorer", icon = icon("chart-line"), tabName = "dataexplorer")
    }
  })
  
   # ======================================================================
  # Modules
  callModule(tempReductionModule, "tempReduction", aggData = data_1d_mean())
  callModule(comfortTempHumModule, "cmfTempHum", aggData = data_1d_mean())
  # 
  callModule(comfortTempROaModule, "cmfTempROa", aggData = data_1h_mean())
  callModule(comfortAQualModule, "cmfAQual", aggData = data_1h_mean())
  callModule(ventilationFlatsModule,"ventilationFlats", aggData = data_15m_max())
  callModule(hotWaterFlatsModule,"hotWaterFlats", aggData = data_1M_sum())
  callModule(heatingFlatsModule,"heatingFlats", aggData = data_1M_sum())
  callModule(heatingCentralModule,"heatingCentral", aggDataTOa = data_1d_mean(), aggDataEnergyHeat = data_1d_sum())
  callModule(heatingCurveModule,"heatingCurve", aggData = data_1h_mean())
  callModule(dataexplorerModule,"dataexplorer")
  
  # ======================================================================
  # Settings
  callModule(configurationModule, "app_configuration")
  callModule(bldgHierarchyModule, "bldgHierarchy")
  callModule(dataSourcesModule, "datasources")
  callModule(dataSourcesModuleTtn, "datasources_ttn")
  callModule(dataSourcesModuleInfluxdb, "datasources_influxdb")
  callModule(dataSourcesModuleCsv, "datasources_csv")
  callModule(dataPointsModule, "datapoints")

  # ======================================================================
  # server functions
  observe({
    output$pageTitle <- renderText({as.character(configFileApp()[["pageTitle"]])})
  })
  
  # data fetcher
  observe({
    if(exists("prevTab") == FALSE){
      prevTab <<- "none"
    }

    curTab <- input$tabs
    if((curTab != "datapoints") && (prevTab == "datapoints")){
      print("Update Data because of tab-change")
      withProgress(message = "Fetching data", detail = "this might take a while..." , value = NULL, { 
        tic("etlAggFilterData")
        ttnFetchServerData()
        etlAggFilterData()
        toc()
      })
    }
    if((curTab != "datapoints") && (prevTab == "datasources")){
      print("Update Data because of tab-change")
      withProgress(message = "Fetching data", detail = "this might take a while..." , value = NULL, { 
        tic("ttnFetchServerData")
        ttnFetchServerData()
        toc()
      })
    }
    prevTab <<- curTab
  })

  observeEvent(input$updateButton, {
    print("Update Data because of pressing button")
    withProgress(message = "Fetching data", detail = "this might take a while..." , value = NULL, {
      tic("ttnFetchServerData")
      ttnFetchServerData()
      toc()
      tic("etlAggFilterData")
      etlAggFilterData()
      toc()
    })
  })
  
  # Close the app when the session completes
  if(!interactive()) {
    session$onSessionEnded(function() {
      stopApp()
      q("no")
    })
  }
}
