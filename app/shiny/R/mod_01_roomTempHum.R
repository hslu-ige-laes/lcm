
# ======================================================================

# ======================================================================


roomTempHumModuleUI <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Room > Temperature versus Humidity",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        box(
          title="Mollier hx Diagram Properties",
          status="info",
          width = 6,
          box(
            width = 4,
            sliderInput(ns("sliderCmfTemp"), "Zone Temperature",
                        min = 15, max = 30, step = 0.5, value = c(20, 26), post = "\u00B0C")
          ),
          box(
            width = 4,
            sliderInput(ns("sliderCmfHumRel"), "Zone Rel. humidity",
                        min = 0, max = 100, step = 5, value = c(35, 65), post = "%rH")
          ),
          box(
            width = 4,
            sliderInput(ns("sliderCmfHumAbs"), "Zone Abs. humidity",
                        min = 0, max = 0.035, step = 0.0005, value = c(0, 0.0115), post = "kg/kg")
          ),
          box(
            width = 4,
            sliderInput(ns("sliderGraphTemp"), "Range Y-Axis",
                        min = -20, max = 40, step = 5, value = c(15, 30), post = "\u00B0C")
          ),
          box(
            width = 4,
            sliderInput(ns("sliderGraphHumAbs"), "Range X-Axis",
                        min = 0, max = 0.035, step = 0.0005, value = c(0, 0.02), post = "kg/kg")
          )
        )
      )
    ),
    tabsetPanel(
      id = "tempHum",
      tabPanel("Overview",
              fluidRow(
                box(
                  status="primary",
                  width = 2,
                  selectInput(ns("flat"), "Flat", choices = NULL),
                  selectInput(inputId = ns("room"),
                              label = "Room",
                                choices = NULL,
                                multiple=F
                  ),
                  inputPanel(
                      sliderInput(inputId = ns("slider"),
                                  label = "Time Range",
                                  min = as.Date("2019-01-01"),
                                  max = as.Date("2020-01-01"),
                                  value = c(as.Date("2019-03-01"), as.Date("2019-09-01")),
                                  timeFormat = "%b %Y"
                      )
                  ),
                  inputPanel(
                    checkboxGroupInput(inputId = ns("season"), 
                                       label = "Visible Seasons",
                                       choices = list("Winter", "Spring", "Summer", "Fall"),
                                       selected = list("Winter", "Spring", "Summer", "Fall")
                    )
                  )
                ),
                box(
                  title="Room Temperature vs. relative Humidity",
                  status="primary",
                  width = 5,
                  plotlyOutput(ns("tempHumPlot")),
                ),
                box(
                  title="Mollier hx Diagram",
                  status="primary",
                  width = 5,
                  d3Output(ns("mollierHxPlot"))
                )
              )
      )
      # tabPanel("Info",
      #          fluidRow(
      #            box(
      #              status="primary",
      #              width = 12,
      #              column(
      #                width = 12,
      #                includeMarkdown(here::here("docs", "docs", "modules","roomTempHum.md"))
      #              )
      #            )
      #          )
      # )
    ),
    tabsetPanel(
      id = "documentation",
      tabPanel("Goals",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","roomTempHum","goals.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","roomTempHum","dataanalysis.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","roomTempHum","userinterface.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","roomTempHum","interpretation.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","roomTempHum","recommendations.md"))
                   )
                 )
               )
      )
    )
    # fluidRow(
    #   box(
    #     status="primary",
    #     width = 12,
    #     column(
    #       width = 12,
    #       includeMarkdown(here::here("docs", "docs", "interpretation","roomTempHum.md"))
    #     )
    #   )
    # )
)}

roomTempHumModule <- function(input, output, session, aggData) {
  
  # date range slider
  sliderDate <- reactiveValues()
  
  observe({
    start <- as.POSIXct(input$slider[1], tz="Europe/Zurich")
    end <- as.POSIXct(input$slider[2], tz="Europe/Zurich")
    sliderDate$start <- as.character(start)
    sliderDate$end <- as.character(end)
  })
  
  observe({
    dates <- df.room() %>% select(time) %>% arrange(time)
    start <- as.Date(dates[1,1], tz = "Europe/Zurich")
    end <- as.Date(dates[nrow(dates),1], tz = "Europe/Zurich")
    updateSliderInput(session,
                      "slider",
                      min = start,
                      max = end,
                      value = c(start, end)
    )
  })
  
  # get separate temp and hum data and merge it
  df.all <- reactive({
    withProgress(message = 'Calculating data', detail = "temperature humidity plot", value = NULL, {
      req(aggData)
      data <- merge.data.frame(aggData %>% filter(dpType == "tempRoom"), aggData %>% filter(dpType == "humRoom"), by = c("time", "flat", "room"))
      names(data)[4] <- "temperature"
      names(data)[7] <- "humidity"
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
    data <- df.room() %>% mutate(season = season(time))
    data <- data %>% filter(season %in% input$season)
    return(data)
  })
 
  # filter according to time slider settings
  df <- reactive({
    data <- df.season() %>% filter(time >= sliderDate$start & time <= sliderDate$end)
    return(data)
  })

  # D3 mollier hx Graph
  output$mollierHxPlot <- renderD3(
    withProgress(message = 'Creating plot', detail = "mollier hx plot", value = NULL, { 
      pressure <- 101325 * (1+(-0.0065*as.numeric(configFileApp()[["bldgAltitude"]]))/288.15)^(-9.80665/(287.058*(-0.0065)))
      r2d3(
        data = as_d3_data(df()),
        script = here::here("app", "shiny", "R", "d3MollierGraph", "plot.js"),
        options = list(
          graphTempMin = input$sliderGraphTemp[1],
          graphTempMax = input$sliderGraphTemp[2],
          graphHumAbsMin = input$sliderGraphHumAbs[1],
          graphHumAbsMax = input$sliderGraphHumAbs[2],
          graphPressure = pressure,
          cmfZoneTempMin = input$sliderCmfTemp[1],
          cmfZoneTempMax = input$sliderCmfTemp[2],
          cmfZoneHumRelMin = input$sliderCmfHumRel[1],
          cmfZoneHumRelMax = input$sliderCmfHumRel[2],
          cmfZoneHumAbsMin = input$sliderCmfHumAbs[1],
          cmfZoneHumAbsMax = input$sliderCmfHumAbs[2]
        ),
        dependencies = c(
          here::here("app", "shiny", "R", "d3MollierGraph", "drawComfort.js"),
          here::here("app", "shiny", "R", "d3MollierGraph", "CoordinateGenerator.js"),
          here::here("app", "shiny", "R", "d3MollierGraph", "mollier_functions.js")
        )
      )
    })
  )
  
  
  # Temperature vs Humidity Plot
  miny <- 0.0
  maxy <- 100.0
  
  df.zoneYetComfortable <- data.frame(Temp = c(20,17,16,17,21.5,25,27,25.5,20),
                                      Hum = c(20,40,75,85,80,60,30,20,20),
                                      Zones = "yet comfortable")
  
  
  df.zoneComfortable <- data.frame(Temp = c(19,17.5,22.5,24,19),
                                   Hum = c(38,74,65,35,38),
                                   Zones = "comfortable")
  
  
  # Plot
  output$tempHumPlot <- renderPlotly({
    withProgress(message = 'Creating plot', detail = "temperature humidity plot", value = NULL, {

      # axis properties
      minx <- floor(min(14.0,min(df.all()$temperature)))
      maxx <- ceiling(max(28.0,max(df.all()$temperature)))

      # comfort zones
      df.zoneNotComfortable <- data.frame(Temp = c(minx,minx,maxx, maxx, minx),
                                          Hum = c(miny,maxy,maxy, miny, miny),
                                          Zones = "uncomfortable")

      df.zones <- rbind.fill(df.zoneNotComfortable, df.zoneYetComfortable)
      df.zones <- rbind.fill(df.zones, df.zoneComfortable)

      df() %>%
        # split(.$room) %>%
        # lapply(function(d){
        plot_ly(showlegend = FALSE) %>%
        # add_polygons(
        #   data = df.zoneNotComfortable, x = ~Temp, y = ~Hum, name = "Not comfortable", opacity = 0.1, color = I("red"), hoverinfo="skip"
        # ) %>%
        add_polygons(
          data = df.zoneYetComfortable, x = ~Temp, y = ~Hum, name = "Yet comfortable", opacity = 0.25, color = I("orange"), hoverinfo="skip"
        ) %>%
        add_polygons(
          data = df.zoneComfortable, x = ~Temp, y = ~Hum, name = "Comfortable", opacity = 0.4, color = I("yellowgreen"), hoverinfo="skip"
        ) %>% 
        add_markers(data = df() %>% filter(season == "Spring"),
                    x = ~temperature,
                    y = ~humidity,
                    marker = list(color = "#2db27d", opacity = 0.4),
                    hoverinfo = "text",
                    text = ~ paste("Temp:    ", sprintf("%.1f \u00B0C", temperature),
                                   "<br />Hum:     ", sprintf("%.1f %%rH", humidity),
                                   "<br />Date:     ", time,
                                   "<br />Season: ", season
                    )
        ) %>% 
        add_markers(data = df() %>% filter(season == "Summer"),
                    x = ~temperature,
                    y = ~humidity,
                    marker = list(color = "#febc2b", opacity = 0.4),
                    hoverinfo = "text",
                    text = ~ paste("Temp:    ", sprintf("%.1f \u00B0C", temperature),
                                   "<br />Hum:     ", sprintf("%.1f %%rH", humidity),
                                   "<br />Date:     ", time,
                                   "<br />Season: ", season
                    )
        ) %>%
        add_markers(data = df() %>% filter(season == "Fall"),
                    x = ~temperature,
                    y = ~humidity,
                    marker = list(color = "#440154", opacity = 0.4),
                    hoverinfo = "text",
                    text = ~ paste("Temp:    ", sprintf("%.1f \u00B0C", temperature),
                                   "<br />Hum:     ", sprintf("%.1f %%rH", humidity),
                                   "<br />Date:     ", time,
                                   "<br />Season: ", season
                    )
        ) %>%
        add_markers(data = df() %>% filter(season == "Winter"),
                    x = ~temperature,
                    y = ~humidity,
                    marker = list(color = "#365c8d", opacity = 0.4),
                    hoverinfo = "text",
                    text = ~ paste("Temp:    ", sprintf("%.1f \u00B0C", temperature),
                                   "<br />Hum:     ", sprintf("%.1f %%rH", humidity),
                                   "<br />Date:     ", time,
                                   "<br />Season: ", season
                    )
        ) %>% 
        layout(
          xaxis = list(title = "Room Temperature in \u00B0C",
                       range = c(minx, maxx),
                       tick0 = minx,
                       dtick = 2,
                       titlefont = list(size = 14, color = "darkgrey")),
          yaxis = list(title = "Relative Room Humidity in %rH",
                       range = c(miny, maxy),
                       titlefont = list(size = 14, color = "darkgrey")),
          hoverlabel = list(align = "left"),
          margin = list(l = 80, t = 50, r = 50, b = 10)
        ) %>%

        plotly::config(modeBarButtons = list(list("toImage")),
                       displaylogo = FALSE,
                       toImageButtonOptions = list(
                         format = "svg"
                       )
        )
    })
  })
}