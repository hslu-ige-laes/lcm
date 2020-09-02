server <- function(input, output, session) {
  
  # Create Optional Menu Bar Items
  output$roomTempHumMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "tempRoom") %>% unique()) > 0) & 
       (nrow(dataPoints() %>% filter(dpType == "humRoom") %>% unique()) > 0)){
      menuItem("Room > Temp vs. Hum", icon = icon("spa"), tabName = "roomTempHum")
    }
  })

  output$roomOutsideTempMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "tempRoom") %>% unique()) > 0) & 
       (nrow(dataPoints() %>% filter(dpType == "tempOutsideAir") %>% unique()) > 0)){
       menuItem("Room > Room vs. Outside Temp", icon = icon("spa"), tabName = "roomOutsideTemp")
    }
  })
  
  output$roomAirQualityMenuItem <- renderMenu({
    if(nrow(dataPoints() %>% filter(dpType == "aQualRoom") %>% unique()) > 0){
      menuItem("Room > Air Quality", icon = icon("spa"), tabName = "roomAirQuality")
    }
  })

  output$roomTempReductionMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "tempRoom") %>% unique()) > 0)){
      menuItem("Room > Temp Reduction", icon = icon("thermometer-quarter"), tabName = "roomTempReduction")
    }
  })
  
  output$flatHeatingMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "energyHeatFlat"))) > 0){
      menuItem("Flat > Heating", icon = icon("gripfire"), tabName = "flatHeating")   
    }
  })
  
  output$flatHotWaterMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "hotWaterFlat"))) > 0){
      menuItem("Flat > Hot Water", icon = icon("shower"), tabName = "flatHotWater")   
    }
  })
  
  output$flatVentilationMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "ventilationFlat"))) > 0){
      menuItem("Flat > Ventilation", icon = icon("atom"), tabName = "flatVentilation")   
    }
  })
  
  output$flatElectricityMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "eleFlat"))) > 0){
      menuItem("Flat > Electricity", icon = icon("bolt"), tabName = "flatElectricity")   
    }
  })

  output$centralHeatingSignatureMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "energyHeatCentral") %>% unique()) > 0) & 
       (nrow(dataPoints() %>% filter(dpType == "tempOutsideAir") %>% unique()) > 0)){
      menuItem("Central > Heating Signature", icon = icon("gripfire"), tabName = "centralHeatingSignature")   
    }
  })
  
  output$centralHeatingCurveMenuItem <- renderMenu({
    if((nrow(dataPoints() %>% filter(dpType == "tempSupplyHeat") %>% unique()) > 0) & 
       (nrow(dataPoints() %>% filter(dpType == "tempOutsideAir") %>% unique()) > 0)){
      menuItem("Central > Heating Curve", icon = icon("gripfire"), tabName = "centralHeatingCurve")   
    }
  })
  
  output$dataExplorerMenuItem <- renderMenu({
    if((nrow(dataPoints())) > 0){
      menuItem("Data Explorer", icon = icon("chart-line"), tabName = "dataexplorer")
    }
  })
  
  # ======================================================================
  # Modules
  callModule(roomTempHumModule, "roomTempHum", aggData = data_1d_mean())
  callModule(roomOutsideTempModule, "cmfTempROa", aggData = data_1h_mean())
  callModule(roomAirQualityModule, "cmfAQual", aggData = data_1h_mean())
  callModule(roomTempReductionModule, "roomTempReduction", aggData = data_1d_mean())
  callModule(flatHeatingModule,"flatHeating", aggData = data_1M_sum())
  callModule(flatHotWaterModule,"flatHotWater", aggData = data_1M_sum())
  callModule(flatVentilationModule,"flatVentilation", aggData = data_15m_max())
  callModule(flatElectricityModule,"flatElectricity", aggData1MSum = data_1M_sum(), aggData1hSum = data_1h_sum())
  callModule(centralHeatingSignatureModule,"centralHeatingSignature", aggDataTOa = data_1d_mean(), aggDataEnergyHeat = data_1d_sum())
  callModule(centralHeatingCurveModule,"centralHeatingCurve", aggData = data_1h_mean())
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
