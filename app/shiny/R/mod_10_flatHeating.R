
# ======================================================================

# ======================================================================

flatHeatingModuleUI <- function(id) {
  #' Name UI
  #'
  #' User-Interface for the 
  #' @param id id for ns()
  #' @export
  #' @author Reto Marek
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Flat > Heating",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        box(
          width = 3,
          sliderInput(ns("slider"), "Time Range", min = as.Date("2019-01-01"), max =as.Date("2020-01-01"), value=c(as.Date("2019-03-01"), as.Date("2019-09-01")), timeFormat="%b %Y")
        ),
        box(
          width = 2,
          selectInput(ns("selCalc"), 
                      label = "Calculation",
                      choices = list("Absolute (kWh)", "Relative (kWh/m2)"),
                      selected = list("Relative (kWh/m2)"),
                      width = "200px"
          )
        ),
        box(
          width = 2,
          radioButtons(ns("selLevel"), 
                       label = "Level",
                       choices = list("Building", "Flats"),
                       selected = list("Flats"),
                       width = "200px"
          )
        )
      )
    ),
    tabsetPanel(
      id = "flatHeatingTab",
      tabPanel("Overview by Year",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     plotlyOutput(ns("heatingFlatYear"), height = "auto", width = "auto")
                   )
                 )
               )
      ),
      tabPanel("Overview by Month",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     plotlyOutput(ns("heatingFlatMonth"), height = "auto", width = "auto")
                   )
                 )
               )
      )
      # tabPanel("Stream",
      #          fluidRow(
      #            box(
      #              status="primary",
      #              width = 12,
      #              column(
      #                width = 12,
      #                streamgraphOutput(ns("heatingFlatStream"), height = "400px", width = "100%")
      #              )
      #            )
      #          )
      # )
    ),
    tabsetPanel(
      id = "documentation",
      tabPanel("Aims",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","flatHeating","aims.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatHeating","dataanalysis.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatHeating","userinterface.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatHeating","interpretation.md"))
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
                     includeMarkdown(here::here("docs", "docs", "modules","flatHeating","recommendations.md"))
                   )
                 )
               )
      )
    )
  )
}

flatHeatingModule <- function(input, output, session, aggData) {
  #' Name
  #'
  #' Server-function for the 
  #' @param filename a String representing the filename inclusive extension.
  #' @export
  #' @author Reto Marek
  
  
  # date range slider
  sliderDate <- reactiveValues()
  
  observe({
    start <- as.POSIXct(input$slider[1], tz="Europe/Zurich")
    end <- as.POSIXct(input$slider[2], tz="Europe/Zurich")
    sliderDate$start <- as.character(start)
    sliderDate$end <- as.character(end)
  })
  
  observe({
    dates <- aggData %>% select(time) %>% arrange(time)
    start <- as.Date(dates[1,1], tz = "Europe/Zurich")
    end <- as.Date(dates[nrow(dates),1], tz = "Europe/Zurich")
    updateSliderInput(session,
                      "slider",
                      min = start,
                      max = end,
                      value = c(start, end)
    )
  })
  
  df.all <- reactive({
    data <- aggData %>% filter(dpType == "energyHeatFlat")
    
    sizeList <- bldgHierarchy() %>% select(flat, size)
    sizeList$size <- as.numeric(sizeList$size)
    data <- merge(data, sizeList, all.x = TRUE)
    
    return(data)
  })
  
  # filter data according to time slider setting
  # Consumption total
  df.abs.monthly <- reactive({
    data <- df.all() %>% filter(time >= sliderDate$start & time <= sliderDate$end)
    data$value <- round(data$value, digits = 1)
    # renaming names for proper hovertips
    colnames(data)[2] <- "Time"
    colnames(data)[3] <- "Consumption"

    
    # add separate columns for ggplot
    data$month <- lubridate::month(data$Time, label = TRUE)
    data$year <- lubridate::year(data$Time)
    data$dummy <- 1
   
    return(data)
  })
  
  df.abs.yearly <- reactive({
    data <- df.abs.monthly() %>% 
      group_by(year,  flat) %>% 
      mutate(Consumption = sum(Consumption)) %>%
      select(-Time, -month) %>% 
      unique() %>% 
      na.omit()
    data <- data %>% group_by(year) %>% mutate(average = median(Consumption))
    data <- data %>% group_by(year) %>% mutate(sum = sum(Consumption))
    data <- data %>% group_by(year) %>% mutate(percFlat = 100/sum*Consumption)

    return(data)
  })
  
  # Consumption per size
  df.size.monthly <- reactive({
    data <- df.all() %>% filter(time >= sliderDate$start & time <= sliderDate$end)
    data$value <- round(data$value/data$size, digits = 1)
    # renaming names for proper hovertips
    colnames(data)[2] <- "Time"
    colnames(data)[3] <- "Consumption"
    
    # add separate columns for ggplot
    data$month <- lubridate::month(data$Time, label = TRUE)
    data$year <- lubridate::year(data$Time)
    
    return(data)
  })
  
  df.size.yearly <- reactive({
    data <- df.abs.yearly()
    data$Consumption <- round(data$Consumption/data$size, digits = 1)
    data <- data %>% group_by(year) %>%  mutate(averageYear = median(Consumption))
    return(data)
  })
  
  df.size.yearly.perc <- reactive({
    data <- df.size.yearly()
    data <- data %>% group_by(year) %>% mutate(average = median(Consumption))
    data <- data %>% group_by(year) %>% mutate(sum = sum(Consumption))
    data <- data %>% group_by(year) %>% mutate(percFlat = 100/sum*Consumption)
    data <- data %>% group_by(year) %>% mutate(shareFlat = percFlat/100*average)
    return(data)
  })
  
  numFlats <- reactive({
    df.all() %>% select(flat) %>% unique() %>% nrow()
  })
  
  numYears <- reactive({
    df.abs.yearly() %>% ungroup() %>% select(year) %>% unique() %>% nrow()
  })
  
  
  plotHeight <- function(listNumRow) {
    # calculate values$facetCount
    rows <- ceiling(listNumRow/2)
    if(rows == 1){
      switch(listNumRow,
             {height = 350},
             {height = 300},
             {height = 250}
      )
    }
    else {
      height <- rows * 250
    }
    return(height)
  }
  
  # Generate Plot
  output$heatingFlatMonth <- renderPlotly({
    # Create a Progress object
    withProgress(message = 'Creating plot', detail = "heating flats monthly", value = NULL, {
      # start <- as.POSIXct(sliderDate$start, tz="Europe/Zurich")
      # end <- as.POSIXct(sliderDate$end, tz="Europe/Zurich")

      if((input$selCalc == "Relative (kWh/m2)") & (input$selLevel == "Flats")) {
        minY <- 0
        maxY <- max(df.size.monthly()$Consumption)
        p <- ggplot(df.size.monthly(), aes(lubridate::month(Time, label = TRUE, abbr = TRUE),
                                           Consumption,
                                           group = factor(lubridate::year(Time)),
                                           colour = factor(lubridate::year(Time)),
                                           text = paste("</br>Flat: ",flat ,"</br>q<sub>H</sub>:  ", format(round(Consumption, digits = 1), big.mark="'"), "kWh/(m<sup>2</sup> month)")
                                           )
          ) +
          geom_line() +
          geom_point() +
          ggtitle("Relative Heating Energy Flats per Month") +
          scale_colour_viridis(discrete = TRUE) +
          facet_wrap(~flat, ncol = 2, scales = "free")
        
        yAxisTitle <- "q<sub>H</sub> in kWh/(m<sup>2</sup> month)"
        
        height = plotHeight(numFlats())
      
      } else if((input$selCalc == "Relative (kWh/m2)") & (input$selLevel == "Building")) {
        minY <- 0
        maxY <- df.size.monthly() %>% group_by(month, year) %>% mutate(sum = sum(Consumption))
        maxY <- max(maxY$sum)
        p <- ggplot(df.size.monthly(), aes(lubridate::month(Time, label = TRUE, abbr = TRUE), 
                                           Consumption,
                                           group = flat,
                                           fill = flat,
                                           text = paste("</br>Flat: ",flat ,"</br>q<sub>H</sub>:  ", format(round(Consumption, digits = 1), big.mark="'"), "kWh/(m<sup>2</sup> month)")
                                           )
          ) +
          geom_area(alpha = 0.7) +
          ggtitle("Relative Heating Energy Building per Month") +
          scale_fill_viridis(discrete = TRUE) +
          facet_wrap(~year, ncol = 2, scales = "free")
        
        yAxisTitle <- "q<sub>H</sub> in kWh/(m<sup>2</sup> month)"
        
        height = plotHeight(numYears())
        
      } else if((input$selCalc == "Absolute (kWh)") & (input$selLevel == "Flats")) {
        minY <- 0
        maxY <- max(df.abs.monthly()$Consumption)
        p <- ggplot(df.abs.monthly(), aes(lubridate::month(Time, label = TRUE, abbr = TRUE),
                                          Consumption,
                                          group = factor(lubridate::year(Time)),
                                          colour = factor(lubridate::year(Time)),
                                          text = paste("</br>Flat: ",flat ,"</br>Q<sub>H</sub>:  ", format(round(Consumption, digits = 0), big.mark="'"), "kWh/month")
                                          )
          ) +
          geom_line() +
          geom_point() +
          ggtitle("Absolute Heating Energy Flats per Month") +
          scale_colour_viridis(discrete = TRUE) +
          facet_wrap(~flat, ncol = 2, scales = "free")
        
        yAxisTitle <- "Q<sub>H</sub> in kWh/month"
        
        height = plotHeight(numFlats())
        
      } else if((input$selCalc == "Absolute (kWh)") & (input$selLevel == "Building")) {
        minY <- 0
        maxY <- df.abs.monthly() %>% group_by(month, year) %>% mutate(sum = sum(Consumption))
        maxY <- max(maxY$sum)
        p <- ggplot(df.abs.monthly(), aes(lubridate::month(Time, label = TRUE, abbr = TRUE), 
                                           Consumption,
                                          group = flat,
                                          fill = flat,
                                          text = paste("</br>Flat: ",flat ,"</br>Q<sub>H</sub>:  ", format(round(Consumption, digits = 0), big.mark="'"), "kWh/month")
                                          )
          ) +
          geom_area(alpha = 0.7) +
          ggtitle("Absolute Heating Energy Building per Month") +
          scale_fill_viridis(discrete = TRUE) +
          facet_wrap(~year, ncol = 2, scales = "free")
        
        yAxisTitle <- "Q<sub>H</sub> in kWh/month"
        
        height = plotHeight(numYears())
        
      } else {
        p <- NULL
        height = plotHeight(1)
      }
      
      p <- p +
        labs(x="Month", colour="Year") +
        scale_y_continuous(labels = function(x) format(x, scientific = FALSE, big.mark = "'"),
                           limits=c(minY,maxY)) +
        theme_minimal() +
        theme(
          strip.text = element_text(size = 13, color = "darkgrey"),
          legend.position="right",
          panel.spacing.y = unit(2, "lines"),
          plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5)
        )
      
      yaxis <- list(
        title = yAxisTitle,
        automargin = TRUE,
        titlefont = list(size = 13, color = "darkgrey")
      )
      
      ggplotly(p + ylab(" ") + xlab(" "), height = height, tooltip = c("text")) %>%
        plotly::config(modeBarButtons = list(list("toImage")),
                       displaylogo = FALSE,
                       toImageButtonOptions = list(
                         format = "svg"
                       )
        ) %>% 
        layout(margin = list(t = 120), yaxis = yaxis)
    })
  })
  
  output$heatingFlatYear <- renderPlotly({
    # Create a Progress object
    withProgress(message = 'Creating plot', detail = "heating flats yearly", value = NULL, {
      # start <- as.POSIXct(sliderDate$start, tz="Europe/Zurich")
      # end <- as.POSIXct(sliderDate$end, tz="Europe/Zurich")
      
      if((input$selCalc == "Relative (kWh/m2)") & (input$selLevel == "Flats")) {
        p <- ggplot(df.size.yearly() %>% ungroup(),
                    aes(flat,
                        Consumption,
                        fill = flat,
                        text = paste("</br>Flat: ",flat ,"</br>q<sub>H</sub>:  ", format(round(Consumption, digits = 0), big.mark="'"), "kWh/(m<sup>2</sup> year)"))
                    ) +
          geom_bar(width = 0.8, position = "dodge", stat = "identity", alpha=0.7) +
          geom_hline(data = df.size.yearly() %>% filter(year == year),
                     aes(yintercept = averageYear),
                     color="darkorange",
                     linetype="dashed") +
          ggtitle("Relative Heating Energy Flats per Year")
        
        yAxisTitle <- "q<sub>H</sub> in kWh/(m<sup>2</sup> year)"
        
      } else if((input$selCalc == "Relative (kWh/m2)") & (input$selLevel == "Building")) {
        p <- ggplot(df.size.yearly.perc() %>% ungroup(),
                    aes(dummy,
                        shareFlat,
                        fill = flat,
                        text = paste("</br>Flat:    ",flat ,"</br>Share: ", sprintf("%.1f", round(shareFlat, digits = 1)), " %"))
                    ) +
          geom_col(alpha=0.7) +
          ggtitle("Relative Heating Energy Building per Year")
        
        yAxisTitle <- "q<sub>H</sub> in kWh/(m<sup>2</sup> year)"
        
      } else if((input$selCalc == "Absolute (kWh)") & (input$selLevel == "Flats")) {
        p <- ggplot(df.abs.yearly() %>% ungroup(),
                    aes(flat,
                        Consumption,
                        fill = flat,
                        text = paste("</br>Flat: ",flat ,"</br>Q<sub>H</sub>: " , format(round(Consumption, digits = 0), big.mark="'"), "kWh/year"))
                    ) +
          geom_bar(width = 0.8, position = "dodge", stat = "identity", alpha=0.7) +
          ggtitle("Absolute Heating Energy Flats per Year")
        
        yAxisTitle <- "Q<sub>H</sub> in kWh/year"
        
      } else if((input$selCalc == "Absolute (kWh)") & (input$selLevel == "Building")) {
        p <- ggplot(df.abs.yearly() %>% ungroup(),
                    aes(dummy,
                        Consumption,
                        fill = flat,
                        text = paste("</br>Flat:    ",flat ,"</br>Share:", sprintf("%.1f", round(percFlat, digits = 1)), " %"))
                    ) +
          geom_col(alpha=0.7) +
          ggtitle("Absolute Heating Energy Building per Year")
        
        yAxisTitle <- "Q<sub>H</sub> in kWh/year"
        
      } else {
        p <- NULL
      }
  
      p <- p +
        facet_wrap(~year, nrow = 1, strip.position = "bottom") +
        scale_y_continuous(labels = function(x) format(x, scientific = FALSE, big.mark = "'"),
                           expand = c(0,0)) +
        labs(fill="Flats") +
        scale_fill_viridis(discrete = TRUE) +
        theme_minimal()
      
      if(input$selLevel == "Building"){
        p <- p + 
          theme(
            strip.text = element_text(size = 13, color = "darkgrey"),
            legend.position ="right",
            axis.line.x = element_line(size = 2, color = "darkgrey", linetype = 1),
            axis.text.x = element_blank(),
            # axis.ticks.x=element_blank(),
            axis.title.x = element_blank(),
            panel.spacing.y = unit(2, "lines"),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.x = element_blank(),
            plot.title = element_text(hjust = 0.5),
            plot.subtitle = element_text(hjust = 0.5)
          )
      } else { # stacked
        p <- p + 
          theme(
            strip.text = element_text(size = 13, color = "darkgrey"),
            legend.position ="right",
            axis.line.x = element_line(size = 2, color = "darkgrey", linetype = 1),
            axis.text.x = element_blank(),
            # axis.ticks.x=element_blank(),
            axis.title.x = element_blank(),
            panel.spacing.y = unit(2, "lines"),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.x = element_blank(),
            plot.title = element_text(hjust = 0.5)
          )
      }
      
      yaxis <- list(
        title = yAxisTitle,
        automargin = TRUE,
        titlefont = list(size = 13, color = "darkgrey")
      )
      
      ggplotly(p + ylab(" ") + xlab(" "), tooltip = c("text")) %>%
        plotly::config(modeBarButtons = list(list("toImage")),
                       displaylogo = FALSE,
                       toImageButtonOptions = list(
                         format = "svg"
                       )
        ) %>% 
        layout(margin = list(t = 120), yaxis = yaxis)
    })
  })
 
  # output$heatingFlatStream <- renderStreamgraph({
  #   # Create a Progress object
  #   withProgress(message = 'Creating plot', detail = "heating flats stream", value = NULL, {
  #     stream_colors <- viridis_pal()(numFlats())
  #     
  #     if(input$selCalc == "Relative (kWh/m2)") {
  #       streamgraph(df.size.monthly(), key = flat, value = Consumption, date = Time, height = "400px") %>% 
  #         sg_fill_manual(stream_colors) %>% sg_axis_x(tick_interval = 1, tick_units = "year", tick_format = "%Y")
  #     } else {
  #       streamgraph(df.abs.monthly(), key = flat, value = Consumption, date = Time, height = "400px") %>% 
  #         sg_fill_manual(stream_colors) %>% sg_axis_x(tick_interval = 1, tick_units = "year", tick_format = "%Y")
  #     }
  #       
  #   })
  # })
  
}