flatElectricityModuleUI <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Flat > Electricity",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        box(
          width = 2,
          numericInput(inputId = ns("occupants"),
                       label = "Occupants",
                       value = NULL,
                       min = 1,
                       max = 6,
                       step = 0.5
          )
        ),
        box(
          width = 2,
          numericInput(inputId = ns("rooms"),
                       label = "Rooms",
                       value = NULL,
                       min = 1,
                       max = 10,
                       step = 0.5
          )
        ),
        box(
          width = 4,
          selectInput(inputId = ns("dishwasher"),
                      label = "Dishwasher",
                      choices = c("none" = "none", "classic" = "classic", "with hot water supply" = "hotWaterSupply"),
                      multiple = F,
                      selected = "classic"
          )
        ),
        box(
          width = 3,
          selectInput(inputId = ns("freezer"),
                      label = "Freezer",
                      choices = c("none" = "none", "classic" = "classic"),
                      multiple = F,
                      selected = "none"
          )
        ),
        box(
          width = 4,
          selectInput(inputId = ns("cookingBaking"),
                      label = "Cooking & Baking",
                      choices = c("occasionally" = "occasionally", "normal" = "normal", "intensive" = "intensive"),
                      multiple = F,
                      selected = "normal"
          )
        ),
        box(
          width = 4,
          selectInput(inputId = ns("effLighting"),
                      label = "Efficient Lighting",
                      choices = c("minority of lamps" = "minority", "mix" = "mix", "majority of lamps" = "majority"),
                      multiple = F,
                      selected = "mix"
          )
        ),
        box(
          width = 4,
          selectInput(inputId = ns("dryer"),
                      label = "Clothes Dryer",
                      choices = c("none" = "none", "room air dryer" = "roomAir", "heat pump dryer" = "heatPump", "classic dryer" = "classic"),
                      multiple = F,
                      selected = "classic"
          )
        ),
        box(
          width = 4,
          selectInput(inputId = ns("laundry"),
                      label = "Washing Machine",
                      choices = c("none" = "none", "classic" = "classic", "with hot water supply" = "hotWaterSupply"),
                      multiple = F,
                      selected = "classic"
          )
        ),
        box(
          width = 4,
          selectInput(inputId = ns("waterHeater"),
                      label = "Water Heater",
                      choices = c("none" = "none", "Electric Boiler" = "electric", "Heat Pump" = "heatpump"),
                      multiple = F,
                      selected = "none"
          )
        ),
        box(
          width = 4,
          selectInput(inputId = ns("eleCommon"),
                      label = "Common electricity (building equipment, common lighting)",
                      choices = c("excluded" = "excluded", "included" = "included"),
                      multiple = F,
                      selected = NULL
          )
        )
       
 
      )
    ),
    sidebarPanel(
      width = 2,
      selectInput(ns("flat"), "Flat", choices = NULL),
      selectInput(inputId = ns("room"),
                  label = "Room",
                  choices = NULL,
                  multiple=F
      ),
      sliderInput(inputId = ns("slider"),
                  label = "Time Range",
                  min = as.Date("2019-01-01"),
                  max = as.Date("2020-01-01"),
                  value = c(as.Date("2019-03-01"), as.Date("2019-09-01")),
                  timeFormat = "%b %Y"
      ),
      checkboxGroupInput(inputId = ns("season"), 
                         label = "Visible Seasons",
                         choices = list("Winter", "Spring", "Summer", "Fall"),
                         selected = list("Winter", "Spring", "Summer", "Fall")
      )
    ),
    mainPanel(
      width = 10,
      tabsetPanel(
        id = "flatElectricityVis",
        tabPanel("Overview",
                 fluidRow(
                   box(
                     title="Daily Electric Energy Consumption and Standby Power",
                     status="primary",
                     width = 12,
                     plotlyOutput(ns("overviewPlot"), height = "auto")
                   )
                 )
        )
      )
    ),
    tabsetPanel(
      id = "flatElectricityDoc",
      tabPanel("Aims",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","flatElectricity","aims.md"))
                   )
                 )
               )
      ),
      tabPanel("Data Analysis",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","flatElectricity","dataanalysis.md"))
                   )
                 )
               )
      ),
      tabPanel("User Interface",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","flatElectricity","userinterface.md"))
                   )
                 )
               )
      ),
      tabPanel("Interpretation",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","flatElectricity","interpretation.md"))
                   )
                 )
               )
      ),
      tabPanel("Recommendations",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","flatElectricity","recommendations.md"))
                   )
                 )
               )
      )
    )
)}

flatElectricityModule <- function(input, output, session, aggData) {

  stopifnot(is.reactive(aggData))
  
  # read typical electricitiy values
  typEleValTable <- read.csv2(here::here("app", "shiny", "config", "typicalHousholdPowerConsumption.csv"), stringsAsFactors = FALSE, dec = ".")
  
  
  # default values of settings tab
  observe({
    occCnt <- as.numeric(bldgHierarchy() %>% filter(flat == input$flat) %>% select(occupants))
    updateNumericInput(session,
                       "occupants",
                       value = occCnt
    )
  })
  
  observe({
    roomCnt <- as.numeric(typEleValTable %>% filter(bldgType == configFileApp()[["bldgType"]]) %>% filter(occupants == input$occupants) %>% select(roomDefault))
    updateNumericInput(session,
                       "rooms",
                       value = roomCnt
    )
  })
  
  observe({
    
    if(configFileApp()[["bldgType"]] == "single"){
      eleCommonSel <- "included"
    } else {
      eleCommonSel <- "excluded"
    }
    
    updateNumericInput(session,
                       "eleCommon",
                       value = eleCommonSel
    )
  })
  
  
  # date range slider
  sliderDate <- reactiveValues()
  
  observe({
    start <- as.POSIXct(input$slider[1], tz="Europe/Zurich")
    end <- as.POSIXct(input$slider[2], tz="Europe/Zurich")
    sliderDate$start <- as.character(start)
    sliderDate$end <- as.character(end)
  })
  
  observe({
    start <- as.Date(min(df.room()$time))
    end <- as.Date(max(df.room()$time))
    updateSliderInput(session,
                      "slider",
                      min = start,
                      max = end,
                      value = c(start, end)
    )
  })
  
  # get separate temp and hum data and merge it
  df.all <- reactive({
    withProgress(message = 'Calculating data', detail = "electricity plot", value = NULL, {
      req(aggData())
      
      # keep only eleFlat
      data <- aggData() %>% filter(dpType == "eleFlat")
      
      # determine date related parameters for later filtering
      # locTimeZone <- "Europe/Zurich"
      locTimeZone <- configFileApp()[["bldgTimeZone"]]
      data$day <- as.Date(data$time, tz = locTimeZone)
      data$week <- lubridate::week(data$time)
      data$month <- lubridate::month(data$time)
      data$year <- lubridate::year(data$time)
      
      # data cleansing
      # tag NA
      data <- data %>% mutate(deleteNA = ifelse(is.na(value),1,0))
      
      # tag values below 0 and higher than 9.2 kW
      data <- data %>% mutate(deleteHiLoVal = ifelse(value > 9.2,1, ifelse(value < 0,1,0)))
      # Assumption max. fuse 40 ampere (higher fuses for single family houses)
      # this results in continuous power 9.2 kW
      # this results in an hourly consumption of 9.2kWh
      # over 24h = approx. 221 kWh max. consumption per day
      
      # tag whole days which have one or more values to delete, keep only whole valid days
      data <- data %>% group_by(day, flat, room) %>% mutate(delete = sum(deleteNA, na.rm = TRUE) + sum(deleteHiLoVal, na.rm = TRUE))
      data <- data %>% ungroup()
      
      # delete full days with invalid data
      data <- data %>% filter(delete == 0) %>% select(-deleteNA, -deleteHiLoVal, -delete)

      # determine season for later filtering
      data <- data %>% mutate(season = season(time))
      
      # calculate sum and min per day
      data <- data %>% group_by(day, flat, room) %>% mutate(sum = sum(value))
      data <- data %>% group_by(day, flat, room) %>% mutate(min = min(value)*1000)
      data <- data %>% ungroup()

    })
    return(data)
  })
  
  # flat pull down menu
  observe({
    data <- df.all() %>% select(flat) %>% unique()
    # rename the set if there is only one value
    # https://stackoverflow.com/questions/43098849/display-only-one-value-in-selectinput-in-r-shiny-app
    if (nrow(data) == 1) {
      data <- names(data) <- c(data$flat[1])
    }
    data <- as.list(data)
    updateSelectizeInput(session, 'flat',
                         choices = data,
                         server = TRUE
    )
  })
  
  # filter according to flat selection
  df.flat <- reactive({
    data <- df.all() %>% filter(flat == input$flat)
    return(data)
  })
  
  # room pull down menu
  observe({
    data <- df.flat() %>% select(room) %>% unique()
    # rename the set if there is only one value
    # https://stackoverflow.com/questions/43098849/display-only-one-value-in-selectinput-in-r-shiny-app
    if (nrow(data) == 1) {
      data <- names(data) <- c(data$room[1])
    }
    data <- as.list(data)
    updateSelectizeInput(session, 'room',
                         choices = data,
                         server = TRUE
    )
  })
  
  # filter according to room selection
  df.room <- reactive({
    data <- df.flat() %>% filter(room == input$room)
    return(data)
  })

  # filter data according to season settings
  df.season <- reactive({
    data <- df.room() %>% filter(season %in% input$season)
    return(data)
  })
 
  # filter according to time slider settings
  df <- reactive({
    data <- df.season() %>% filter(time >= sliderDate$start & time <= sliderDate$end)
    return(data)
  })
  
  df.agg1d <- reactive({

    data <- df() %>% select(day, sum, min, season) %>% unique()
    
    data <- data %>% mutate(ravgUsage = zoo::rollmean(x=sum, 7, fill = NA))
    data <- data %>% mutate(rminStandby = -1 * zoo::rollmaxr(x = -1 * min, 7, fill = NA))

    return(data)
  })
  
  # calculate electricity consumption of a typical household for comparison
  # Source: Nipkov, J. (2013). Typischer Haushalt-Stromverbrauch. Schlussbericht. Bundesamt für Energie (BFE). [https://www.aramis.admin.ch/Default.aspx?DocumentID=61764]
   typEleConsVal <- reactive({
    req(input$rooms)
    table <- typEleValTable %>% filter(bldgType == configFileApp()[["bldgType"]]) %>% filter(occupants == input$occupants)
    
    # Base value
    value <- as.numeric(table %>% select(baseVal))
    
    # Correction room size
    if(input$rooms < table$roomCntLoLi){
      value <- value - table$roomCntCorr
    }
    if(input$rooms > table$roomCntHiLi){
      value <- value + table$roomCntCorr
    }
    
    # Dishwasher
    switch(input$dishwasher,
      none = {value <- value - table$dishwasherValue},
      classic = {value <- value},
      hotWaterSupply = {value <- value - table$dishwasherHotWaterCorr}
    )
    
    # Freezer
    if(input$freezer == "classic"){
      value <- value + table$freezerVal
    }
    
    # Cooking & Baking
    switch(input$cookingBaking,
           occasionally = {value <- value - table$cookingCorr},
           normal = {value <- value},
           intensive = {value <- value + table$cookingCorr}
    )
    
    # Efficient Lighting
    switch(input$effLighting,
           minority = {value <- value + table$effLightingCorr},
           mix = {value <- value},
           majority = {value <- value - table$effLightingCorr}
    )
    
    # Dryer
    switch(input$dryer,
           none = {value <- value - (table$dryerCorrVal)},
           roomAir = {value <- value - ((table$laundryCorrVal + table$dryerCorrVal) * 0.25)},
           heatPump = {value <- value - ((table$laundryCorrVal + table$dryerCorrVal) * 0.25)},
           classic = {value <- value}
    )
    
    # Laundry 
    switch(input$laundry,
           none = {value <- value - (table$laundryCorrVal)},
           classic = {value <- value},
           hotWaterSupply = {value <- value - ((table$laundryCorrVal + table$dryerCorrVal) * 0.25)}
    )
    
    # Water Heater
    switch(input$waterHeater,
           none = {value <- value},
           electric = {value <- value + table$electricWaterHeater},
           heatPump = {value <- value + table$heatPumpWaterHeater}
    )
    
    # common electricity
    if(input$eleCommon == "excluded"){
      value <- value - table$electricityCommonVal
    }
    return(value)
  })

  # Plot
  output$overviewPlot <- renderPlotly({
    
    req(df.agg1d())
    withProgress(message = 'Creating plot', detail = "electricity overview", value = NULL, {
      minY <- 0
      maxYUsage <- max(df.all() %>% select(sum), na.rm=TRUE)
      maxYUsage <- max(maxYUsage, typEleConsVal()/365)
      maxYStandby <- max(max(df.all() %>% select(min), na.rm=TRUE), 0.25*maxYUsage/24*1000)
      minX <- sliderDate$start
      maxX <- sliderDate$end
      averageUsage <- mean(df.agg1d()$sum, na.rm=TRUE)
      averageStandby <- mean(df.agg1d()$rminStandby, na.rm=TRUE)
      shareStandby <- nrow(df.agg1d() %>% select(sum) %>% na.omit()) * averageStandby * 24 / (1000 * sum(df.agg1d()$sum, na.rm=TRUE)) * 100
  
      # legend
      l <- list(
        orientation = "h",
        tracegroupgap = "20",
        font = list(size = 8),
        xanchor = "center",
        x = 0.5,
        itemclick = FALSE
      )
      
      fig1 <- df.agg1d() %>%
        plot_ly(x = ~day, showlegend = TRUE) %>%
        add_trace(data = df.agg1d() %>% filter(season == "Spring"),
                  type = "bar",
                  y = ~sum,
                  name = "Spring",
                  legendgroup = "group1",
                  marker = list(color = "#2db27d", opacity = 0.2),
                  hoverinfo = "text",
                  text = ~ paste("<br />daily usage:              ", sprintf("%.1f kWh/d", sum),
                                 "<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                 "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_trace(data = df.agg1d() %>% filter(season == "Summer"),
                  type = "bar",
                  y = ~sum,
                  name = "Summer",
                  legendgroup = "group1",
                  marker = list(color = "#febc2b", opacity = 0.2),
                  hoverinfo = "text",
                  text = ~ paste("<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                 "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_trace(data = df.agg1d() %>% filter(season == "Fall"),
                  type = "bar",
                  y = ~sum,
                  name = "Fall",
                  legendgroup = "group1",
                  marker = list(color = "#440154", opacity = 0.2),
                  hoverinfo = "text",
                  text = ~ paste("<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                 "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_trace(data = df.agg1d() %>% filter(season == "Winter"),
                  type = "bar",
                  y = ~sum,
                  name = "Winter",
                  legendgroup = "group1",
                  marker = list(color = "#365c8d", opacity = 0.2),
                  hoverinfo = "text",
                  text = ~ paste("<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                 "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>%
        add_trace(data = df.agg1d(),
                  type = "scatter",
                  mode = "markers",
                  y = ~ravgUsage,
                  name = "Average Cons. (7 days)",
                  legendgroup = "group2",
                  marker = list(color = "orange", opacity = 0.4, symbol = "circle"),
                  hoverinfo = "text",
                  text = ~ paste("<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                 "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_segments(x = ~sliderDate$start,
                     xend = ~sliderDate$end,
                     y = ~averageUsage,
                     yend = ~averageUsage,
                     name = "Average Cons. Total",
                     legendgroup = "group2",
                     line = list(color = "orange", opacity = 1.0, dash = "dot"),
                     hoverinfo = "text",
                     text = ~ paste("<br />rolling average:        ", sprintf("%.1f kWh/d", ravgUsage),
                                    "<br />Average vis. points: ", sprintf("%.1f kWh/d", averageUsage),
                                    "<br />Date:                        ", day,
                                    "<br />Season:                   ", season
                     )
        ) %>% 
        add_segments(x = ~sliderDate$start,
                     xend = ~sliderDate$end,
                     y = ~averageStandby*24/1000,
                     yend = ~averageStandby*24/1000,
                     name = "Average Standby Total",
                     legendgroup = "group3",
                     showlegend = FALSE,
                     line = list(color = "black", opacity = 1.0, dash = "dot"),
                     hoverinfo = "text",
                     text = ~ paste("<br />Average standby power:          ", sprintf("%.0f W", averageStandby),
                                    "<br />equals to daily energy:         ", sprintf("%.1f kWh", averageStandby*24/1000),
                                    "<br />Standby percent of total cons.: ", sprintf("%.0f %%", shareStandby)
                     )
        ) %>% 
        add_segments(x = ~sliderDate$start,
                     xend = ~sliderDate$end,
                     y = ~typEleConsVal()/365,
                     yend = ~typEleConsVal()/365,
                     name = "typical household",
                     legendgroup = "group4",
                     line = list(color = "#481567FF", opacity = 1.0, dash = "dot"),
                     hoverinfo = "text",
                     text = ~ paste("<br />typical household:           ", sprintf("%.0f kWh/year", typEleConsVal()),
                                    "<br />equals to daily energy:      ", sprintf("%.1f kWh/day", typEleConsVal()/365),
                                    "<br />consumption of current flat: ", sprintf("%.1f kWh/day", averageUsage)
                     )
        ) %>% 
        add_annotations(
          x = minX,
          y = typEleConsVal()/365,
          text = paste0("typical comparable household ", sprintf("%.1f kWh/d", typEleConsVal()/365)),
          xref = "x",
          yref = "y",
          showarrow = TRUE,
          arrowhead = 7,
          ax = 100,
          ay = -20,
          font = list(color = "#481567FF")
        ) %>% 
        add_annotations(
          x = maxX,
          y = averageUsage,
          text = paste0("Average consumption ", sprintf("%.1f kWh/d", averageUsage)),
          xref = "x",
          yref = "y",
          showarrow = TRUE,
          arrowhead = 7,
          ax = -100,
          ay = -60,
          font = list(color = "orange")
        ) %>% 
        add_annotations(
          x = maxX,
          y = averageStandby*24/1000,
          text = paste0(sprintf("%.1f %%", shareStandby), " of the consumption are standby-losses"),
          xref = "x",
          yref = "y",
          showarrow = TRUE,
          arrowhead = 7,
          ax = -160,
          ay = -15,
          font = list(color = "black")
        ) %>% 
        layout(
          xaxis = list(
            title = ""
          ),
          yaxis = list(title = "Consumption<br>(kWh/d)",
                       range = c(minY, maxYUsage),
                       titlefont = list(size = 14, color = "darkgrey")),
          hoverlabel = list(align = "left"),
          margin = list(l = 80, t = 50, r = 50, b = 10),
          legend = l
        )
      
      fig2 <- df.agg1d() %>%
        plot_ly(x = ~day, showlegend = TRUE) %>%
        add_trace(data = df.agg1d(),
                  type = "bar",
                  y = ~min,
                  name = "Daily standby-losses",
                  legendgroup = "group3",
                  marker = list(color = "darkgrey", opacity = 0.2),
                  hoverinfo = "text",
                  text = ~ paste("<br />daily standby:           ", sprintf("%.0f W", min),
                                 "<br />rolling average:        ", sprintf("%.0f W", rminStandby),
                                 "<br />Average vis. points: ", sprintf("%.0f W", averageStandby),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_trace(data = df.agg1d(),
                  type = "scatter",
                  mode = "markers",
                  y = ~rminStandby,
                  name = "Average Standby (7 days)",
                  legendgroup = "group3",
                  marker = list(color = "darkgrey", opacity = 0.5, symbol = "circle"),
                  hoverinfo = "text",
                  text = ~ paste("<br />daily standby:           ", sprintf("%.0f W", min),
                                 "<br />rolling average:        ", sprintf("%.0f W", rminStandby),
                                 "<br />Average vis. points: ", sprintf("%.0f W", averageStandby),
                                 "<br />Date:                        ", day,
                                 "<br />Season:                   ", season
                  )
        ) %>% 
        add_segments(x = ~sliderDate$start,
                     xend = ~sliderDate$end,
                     y = ~averageStandby,
                     yend = ~averageStandby,
                     name = "Average Standby Total",
                     legendgroup = "group3",
                     line = list(color = "black", opacity = 1.0, dash = "dot"),
                     hoverinfo = "text",
                     text = ~ paste("<br />Average standby power:          ", sprintf("%.0f W", averageStandby),
                                    "<br />equals to daily energy:         ", sprintf("%.1f kWh", averageStandby*24/1000),
                                    "<br />Standby percent of total cons.: ", sprintf("%.0f %%", shareStandby)
                     )
        ) %>% 
        add_annotations(
          x = maxX,
          y = averageStandby,
          text = paste0(sprintf("%.0f W", averageStandby), " standby-losses"),
          xref = "x",
          yref = "y",
          showarrow = TRUE,
          arrowhead = 7,
          ax = -60,
          ay = -20,
          font = list(color = "black")
        ) %>% 
        layout(
          xaxis = list(
            title = ""
          ),
          yaxis = list(title = " Standby<br>(W)",
                       range = c(minY, maxYStandby),
                       titlefont = list(size = 14, color = "darkgrey"),
                       legend = list(orientation = 'h')),
          legend = l
        )
      
      # calculate ratio which is visual representative for comparison 
      ratio <- 1/maxYUsage * maxYStandby * 24 / 1000
      # browser()
      fig <- subplot(fig1, fig2, nrows = 2, shareX = TRUE, heights = c(1-ratio, ratio), titleY = TRUE) %>%
        plotly::config(modeBarButtons = list(list("toImage")),
                       displaylogo = FALSE,
                       toImageButtonOptions = list(
                         format = "svg"
                       )
        )
      
      return(fig)
    })
  })
}