
# ======================================================================
# season() aus mollierhx rauskopieren in helper-Functions
# ======================================================================


centralHeatingSignatureModuleUI <- function(id) {

  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Central > Heating Signature",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        box(
          width = 3,
          sliderInput(ns("slider"), "Time range", min = as.Date("2019-01-01"), max =as.Date("2020-01-01"), value=c(as.Date("2019-03-01"), as.Date("2019-09-01")), timeFormat="%b %Y")
        ),
        box(
          width = 2,
          checkboxGroupInput(ns("season"), 
                             label = "Visible Seasons",
                             choices = list("Winter", "Spring", "Summer", "Fall"),
                             selected = list("Winter")
          )
        ),
        box(
          width = 2,
          selectInput(inputId = ns("tempOutsideAir"), 
                      label = "Temperature Outside Air",
                      choices = NULL,
                      selectize = FALSE
          )
        ),
        box(
          width = 2,
          selectInput(inputId = ns("energyHeatCentral"), 
                      label = "Energy Heat Meter Central",
                      choices = NULL,
                      selectize = FALSE
          )
        ),
        box(
          width = 2,
          numericInput(ns("limRegLine"), "Threshold to exclude low values for regression line", min = 0, max = 100000, value = 15, step = 1)
        )
      )
    ),
    tabsetPanel(
      id = "tabset1",
      tabPanel("Overview",
               fluidRow(
                 box(
                   title="Heating Signature",
                   status="primary",
                   width = 12,
                   plotlyOutput(ns("energySignaturePlot"), height = "auto")
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
                     column(
                       width = 12,
                       includeMarkdown(here::here("docs", "docs", "modules","centralHeatingSignature.md"))
                     )
                   )
                 )
               )
      )
    ),
    fluidRow(
      box(
        title = "Interpretation",
        solidHeader = TRUE,
        width = 12,
        background = "light-blue",
        "A box with a solid light-blue background"
      )
    )
  )
}

centralHeatingSignatureModule <- function(input, output, session, aggDataEnergyHeat, aggDataTOa) {

  # date range slider
  sliderDate <- reactiveValues()

  observe({
    start <- as.POSIXct(input$slider[1], tz="Europe/Zurich")
    end <- as.POSIXct(input$slider[2], tz="Europe/Zurich")
    sliderDate$start <- as.character(start)
    sliderDate$end <- as.character(end)
  })

  observe({
    start <- as.Date(df.all()[1,1], tz = "Europe/Zurich")
    end <- as.Date(df.all()[nrow(df.all()),1], tz = "Europe/Zurich")
    updateSliderInput(session,
                      "slider",
                      min = start,
                      max = end,
                      value = c(start, end)
    )
  })
  
  observe({
    dpList <- aggDataTOa %>% filter(dpType == "tempOutsideAir") %>% select(abbreviation) %>% unique()
    updateSelectInput(session, "tempOutsideAir",
                      choices = dpList$abbreviation
    )
  })

  observe({
    dpList <- aggDataEnergyHeat %>% filter(dpType == "energyHeatCentral")  %>% select(abbreviation) %>% unique()
    updateSelectInput(session, "energyHeatCentral",
                      choices = dpList$abbreviation
    )
  })

  # combine two data frames
  df.all <- reactive({
    req(input$tempOutsideAir)
    req(input$energyHeatCentral)
    
    data <- inner_join(aggDataTOa %>% filter(abbreviation == input$tempOutsideAir), aggDataEnergyHeat %>% filter(abbreviation == input$energyHeatCentral) , by="time") %>% na.omit()
 
    names(data)[1] <- "Date"
    names(data)[2] <- "TOa"
    names(data)[3] <- "Sensor"
    names(data)[7] <- "Q_Heat"
    names(data)[8] <- "Meter"

    data <- data %>% mutate(season = season(Date))

    return(data)
  })

df.season <- reactive({
  df.all() %>% filter(season %in% input$season)
})


# filter data according to time slider setting
df <- reactive({
  start <- as.Date(sliderDate$start, tz = "Europe/Zurich")
  end <- as.Date(sliderDate$end, tz = "Europe/Zurich")
  data <- df.season() %>% filter(Date >= start & Date <= end)
  return(data)
})

df.winter <- reactive({
  df() %>% filter(season=="Winter")
})

df.spring <- reactive({
  df() %>% filter(season=="Spring")
})

df.summer <- reactive({
  df() %>% filter(season=="Summer")
})

df.fall <- reactive({
  df() %>% filter(season=="Fall")
})

lim <- reactive({
  max <- df() %>% select(Q_Heat) %>% max()
  lim <- min(max(input$limRegLine,1), max)
  return(lim)
})

fit <- reactive({lm(Q_Heat ~ TOa, data = filter(df(), Q_Heat >= lim()))})

# Generate Plot
output$energySignaturePlot <- renderPlotly({
  # Create a Progress object
  withProgress(message = 'Creating plot', detail = "energySignaturePlot", value = NULL, {

    p <- plot_ly()

    if("Spring" %in% input$season){
      p <- p %>% add_markers(data = df.spring(),
                  x = ~TOa,
                  y = ~Q_Heat,
                  marker = list(color = "#2db27d", opacity = 0.7),
                  name = "Spring",
                  hoverinfo = "text",
                  text = ~ paste("Temp:    ", sprintf("%.1f \u00B0C", TOa),
                                 "<br />Q_Heat:", sprintf("%.0f kWh/d", Q_Heat),
                                 "<br />Date:     ", df.spring()$Date,
                                 "<br />Season: ", df.spring()$season
                  )
      )
    }
    if("Summer" %in% input$season){
      p <- p %>% add_markers(data = df.summer(),
                x = ~TOa,
                y = ~Q_Heat,
                marker = list(color = "#fde725", opacity = 0.7),
                name = "Summer",
                hoverinfo = "text",
                text = ~ paste("Temp:    ", sprintf("%.1f \u00B0C", TOa),
                               "<br />Q_Heat:", sprintf("%.0f kWh/d", Q_Heat),
                               "<br />Date:     ", df.summer()$Date,
                               "<br />Season: ", df.summer()$season
                )
      )
    }
    if("Fall" %in% input$season){
      p <- p %>% add_markers(data = df.fall(),
                  x = ~TOa,
                  y = ~Q_Heat,
                  marker = list(color = "#440154", opacity = 0.7),
                  name = "Fall",
                  hoverinfo = "text",
                  text = ~ paste("Temp:    ", sprintf("%.1f \u00B0C", TOa),
                                 "<br />Q_Heat:", sprintf("%.0f kWh/d", Q_Heat),
                                 "<br />Date:     ", df.fall()$Date,
                                 "<br />Season: ", df.fall()$season
                  )
      )
    }
    if("Winter" %in% input$season){
      p <- p %>% add_markers(data = df.winter(),
                  x = ~TOa,
                  y = ~Q_Heat,
                  marker = list(color = "#365c8d", opacity = 0.7),
                  name = "Winter",
                  hoverinfo = "text",
                  text = ~ paste("Temp:    ", sprintf("%.1f \u00B0C", TOa),
                                 "<br />Q_Heat:", sprintf("%.0f kWh/d", Q_Heat),
                                 "<br />Date:     ", df.winter()$Date,
                                 "<br />Season: ", df.winter()$season
                  )
      )
    }

    p <- p %>%
      add_lines(data = filter(df(), Q_Heat >= lim()), x = ~TOa, y = fitted(fit()), name = "Regression line",
                color = "orange",
                hoverinfo = "skip"
      ) %>%
      add_markers(x = fit()["coefficients"]$coefficients[1]*-1/fit()["coefficients"]$coefficients[2], y = 0,
                  marker = list(color = 'orange', opacity = 1, size = 15, symbol = "x", line = list(color = 'rgba(7, 7, 7, .8)',width = 1)),
                  hoverinfo = "text",
                  text = ~ paste("Temp:    ", sprintf("%.1f \u00B0C", fit()["coefficients"]$coefficients[1]*-1/fit()["coefficients"]$coefficients[2])
                  ),
                  name = "Base temperature"
      ) %>%
      layout(
        shapes=list(type='line', x0= -5, x1= 35, y0=max(1,input$limRegLine), y1=max(1,input$limRegLine), line=list(dash="dash", width=1, color="darkgrey")),
        xaxis = list(title = "Outside temperature (\u00B0C)", range = c(min(-5,min(df.all()$TOa)), max(35,max(df.all()$TOa))), zeroline = F),
        yaxis = list(title = "Daily energy consumption (kWh/d)", range = c(-5, max(df.all()$Q_Heat) + 10)),
        showlegend = FALSE
      ) %>%
      plotly::config(modeBarButtons = list(list("toImage")), displaylogo = FALSE)

  })

})

}


