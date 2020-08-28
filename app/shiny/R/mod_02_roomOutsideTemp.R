
# ======================================================================

# ======================================================================


roomOutsideTempModuleUI <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Room > Room versus Outside Temperature",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        box(
          width = 2,
          selectInput(inputId = ns("tempOutsideAir"), 
                      label = "Temperature Outside Air",
                      choices = NULL,
                      multiple=F
          )
        )
      )
    ),
    tabsetPanel(
      id = "tempROa",
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
                  title="Room vs. Outside Temperature",
                  status="primary",
                  width = 8,
                  plotlyOutput(ns("tempROaPlot"))
                )
              )
      ),
      tabPanel("Info",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","roomOutsideTemp.md"))
                   )
                 )
               )
      )
    ),
    fluidRow(
      box(
        status="primary",
        width = 12,
        column(
          width = 12,
          includeMarkdown(here::here("docs", "docs", "interpretation","roomOutsideTemp.md"))
        )
      )
    )
)}

roomOutsideTempModule <- function(input, output, session, aggData) {

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
  
  # get separate temp and outside air data and merge it
  df.all <- reactive({
    withProgress(message = 'Calculating data', detail = "temperature room outside air plot", value = NULL, {
      # saveRDS(aggData, paste0(here::here("app", "shiny", "temp", "temp.rds")))
      data <- aggData %>% filter(dpType %in% c("tempRoom", "tempOutsideAir"))
    })
    return(data)
  })

  # flat pull down menu
  observe({
    data <- aggData %>% filter(dpType == "tempRoom") %>% select(flat) %>% unique()
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
    data <- aggData %>% filter(dpType == "tempRoom") %>% select(room) %>% unique()
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

  observe({
    data <- aggData %>% filter(dpType == "tempOutsideAir") %>% select(abbreviation) %>% unique()
    # rename the set if there is only one value
    # https://stackoverflow.com/questions/43098849/display-only-one-value-in-selectinput-in-r-shiny-app

    if (nrow(data) == 1) {
      data <- names(data) <- c(data$abbreviation[1])
    }
    data <- as.list(data)
    updateSelectizeInput(session, "tempOutsideAir",
                         choices = data,
                         server = TRUE
    )
  })
  
  # filter according to room selection
  df.room <- reactive({
    data <- df.flat() %>% filter(room == input$room)
    #saveRDS(data, paste0(here::here("app", "shiny", "temp", "dfRoom.rds")))
    
    return(data)
  })

  df.tempOutsideAir <- reactive({
    data <- df.all() %>% filter(abbreviation == input$tempOutsideAir)
    # saveRDS(data, paste0(here::here("app", "shiny", "temp", "dftempOutsideAir.rds")))
    return(data)
  })
  
  df.combined <- reactive({
    withProgress(message = 'Calculating data', detail = "for indoor vs. outdoor temperature plot", value = NULL, {
      req(df.room())
      req(df.tempOutsideAir())
      data <- inner_join(df.room(), df.tempOutsideAir() , by="time") %>% na.omit()
      
      names(data)[1] <- "time"
      names(data)[2] <- "tempR"
      names(data)[3] <- "Sensor TR"
      names(data)[4] <- "flat"
      names(data)[5] <- "room"
      names(data)[7] <- "tempOa"
      names(data)[8] <- "Sensor TOa"
      
      data <- data %>% mutate(tempOaRollMean = rollmean(tempOa, 48, fill = NA, align = "right"))
      data <- data %>% na.omit()
    })
  })
  
  # filter data according to season settings
  df.season <- reactive({
    withProgress(message = 'Calculating data', detail = "for indoor vs. outdoor temperature plot", value = NULL, {
      data <- df.combined() %>% mutate(season = season(time))
      data <- data %>% filter(season %in% input$season)
    })
    return(data)
  })
 
  # filter according to time slider settings
  df <- reactive({
    data <- df.season() %>% filter(time >= sliderDate$start & time <= sliderDate$end)
    return(data)
  })

  # Temperature Room vs Outside Air Plot
   output$tempROaPlot <- renderPlotly({
    withProgress(message = 'Creating plot', detail = "indoor vs. outdoor temperature plot", value = NULL, {

      # axis properties
      minx <- floor(min(-4,min(df.all()$tempOaRollMean)))
      maxx <- ceiling(max(32,max(df.all()$tempOaRollMean)))
      
      miny <- floor(min(18.0,min(df.all()$tempR)))-1
      maxy <- ceiling(max(32.0,max(df.all()$tempR)))+1

      # line setpoint heat
      df.heatSp <- data.frame(tempOa = c(minx, 19, 23.5, maxx), tempR = c(20.5, 20.5, 22, 22))
      
      # line setpoint cool according to SIA 180:2014 Fig. 3
      df.coolSp1 <- data.frame(tempOa = c(minx, 12, 17.5, maxx),tempR = c(24.5, 24.5, 26.5, 26.5))
      
      # line setpoint cool according to SIA 180:2014 Fig. 4
      df.coolSp2 <- data.frame(tempOa = c(minx, 10, maxx),tempR = c(25, 25, 0.33 * maxx + 21.8))
      
      df() %>%
        # split(.$room) %>%
        # lapply(function(d){
        plot_ly(showlegend = FALSE) %>%
        add_lines(data = df.heatSp, x = ~tempOa, y = ~tempR, opacity = 0.7, color = "#440154FF", hoverinfo="skip") %>%
        add_lines(data = df.coolSp1, x = ~tempOa, y = ~tempR, opacity = 0.7, color = "#1E9B8AFF", hoverinfo="skip") %>%
        add_lines(data = df.coolSp2, x = ~tempOa, y = ~tempR, opacity = 0.7, color = "#FDE725FF", hoverinfo="skip") %>%
        add_markers(data = df() %>% filter(season == "Spring"),
                    x = ~tempOaRollMean,
                    y = ~tempR,
                    marker = list(color = "#2db27d", opacity = 0.2),
                    hoverinfo = "text",
                    text = ~ paste("TempR:   ", sprintf("%.1f \u00B0C", tempR),
                                   "<br />TempOa: ", sprintf("%.1f \u00B0C", tempOaRollMean),
                                   "<br />Date:       ", time,
                                   "<br />Season:  ", season
                    )
        ) %>%
        add_markers(data = df() %>% filter(season == "Summer"),
                    x = ~tempOaRollMean,
                    y = ~tempR,
                    marker = list(color = "#febc2b", opacity = 0.2),
                    hoverinfo = "text",
                    text = ~ paste("TempR:   ", sprintf("%.1f \u00B0C", tempR),
                                   "<br />TempOa: ", sprintf("%.1f \u00B0C", tempOaRollMean),
                                   "<br />Date:       ", time,
                                   "<br />Season:  ", season
                    )
        ) %>%
        add_markers(data = df() %>% filter(season == "Fall"),
                    x = ~tempOaRollMean,
                    y = ~tempR,
                    marker = list(color = "#440154", opacity = 0.2),
                    hoverinfo = "text",
                    text = ~ paste("TempR:   ", sprintf("%.1f \u00B0C", tempR),
                                   "<br />TempOa: ", sprintf("%.1f \u00B0C", tempOaRollMean),
                                   "<br />Date:       ", time,
                                   "<br />Season:  ", season
                    )
        ) %>%
        add_markers(data = df() %>% filter(season == "Winter"),
                    x = ~tempOaRollMean,
                    y = ~tempR,
                    marker = list(color = "#365c8d", opacity = 0.2),
                    hoverinfo = "text",
                    text = ~ paste("TempR:   ", sprintf("%.1f \u00B0C", tempR),
                                   "<br />TempOa: ", sprintf("%.1f \u00B0C", tempOaRollMean),
                                   "<br />Date:       ", time,
                                   "<br />Season:  ", season
                    )
        ) %>%
        layout(
          xaxis = list(title = "Outside Air Temperature in \u00B0C (Rolling Mean last 48 hours)",
                       range = c(minx, maxx),
                       zeroline = FALSE,
                       tick0 = minx,
                       dtick = 2,
                       titlefont = list(size = 14, color = "darkgrey")),
          yaxis = list(title = "Room Temperature in \u00B0C",
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