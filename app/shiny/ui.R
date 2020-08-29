# ======================================================================
# header
header <- dashboardHeader(
  title = textOutput("pageTitle"),
  titleWidth = 250,
  tags$li(actionLink("updateButton", label = " Update data", icon = icon("sync")), class = "dropdown")
)

# ======================================================================
# sidebar
sidebar <- dashboardSidebar(
  width = 250,
  sidebarMenu(
    tags$li(a(href = "https://www.hslu.ch/laes", target = "_blank",
              img(src = "hsluLogo.png", width = "180px"),
              style = "padding-top:15px; padding-left:14px; padding-bottom:0px;"),
            class = "dropdown"),
    tags$hr(),
    # Setting the id ensures input$tabs knows the names of currently selected tab
    # icons from https://fontawesome.com/icons?d=gallery&m=free
    id = "tabs",
    menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
    menuItemOutput("roomTempHumMenuItem"),
    menuItemOutput("roomOutsideTempMenuItem"),
    menuItemOutput("roomAirQualityMenuItem"),
    menuItemOutput("roomTempReductionMenuItem"),
    menuItemOutput("flatVentilationMenuItem"),
    menuItemOutput("flatHeatingMenuItem"),
    menuItemOutput("flatHotWaterMenuItem"),
    menuItemOutput("centralHeatingSignatureMenuItem"),
    menuItemOutput("centralHeatingCurveMenuItem"),
    menuItemOutput("dataExplorerMenuItem"),
    menuItem("Settings", icon = icon("cog"), startExpanded = FALSE,
             menuSubItem("App Configuration", icon = icon("user-cog"), tabName = "configuration"),
             menuSubItem("Building Hierarchy", icon = icon("home"), tabName = "bldgHierarchy"),
             menuSubItem("Data Sources", icon = icon("database"), tabName = "datasources"),
             menuSubItem("Data Points", icon = icon("list-ul"), tabName = "datapoints")
    )
  )
)
# ======================================================================
# body (connects the sidebar with the body and calls the according module)
body <- dashboardBody(
  # style adaptions
  # remove space below forms (e.g. from input-checkboxgroup), it uses too much space
  tags$head(tags$style(HTML(".form-group {margin-bottom: 0px;}"))),
  tags$head(tags$style(HTML(".checkbox {margin-bottom: 0px;}"))),
  tags$head(tags$style(HTML(".well {padding-top: 10px; padding-right: 30px; padding-left: 30px; padding-bottom: 10px;}"))),

  # left-align title top left
  tags$head(tags$style(HTML(".main-header .logo {text-align: left;}"))),
  
  # place the notification boxes from withProgress() function top right and change color
  tags$head(
    tags$style(
      HTML(".shiny-notification {
             background-color:#ffd023;
             position:fixed;
             right:calc(1%);
             top:calc(7%);
             }
             "
      )
    )
  ),
  # body content
  tabItems(
    tabItem(tabName = "overview",
            "content tbd"
    ),

    tabItem(tabName = "roomTempHum",
            roomTempHumModuleUI("roomTempHum")
    ),
    
    tabItem(tabName = "roomOutsideTemp",
            roomOutsideTempModuleUI("cmfTempROa")
    ),
    
    tabItem(tabName = "roomAirQuality",
            roomAirQualityModuleUI("cmfAQual")
    ),

    tabItem(tabName = "roomTempReduction",
            roomTempReductionModuleUI("roomTempReduction")
    ),
        
    tabItem(tabName = "flatVentilation",
            flatVentilationModuleUI("flatVentilation")
    ),
    
    tabItem(tabName = "flatHotWater",
            flatHotWaterModuleUI("flatHotWater")
    ),
    
    tabItem(tabName = "flatHeating",
            flatHeatingModuleUI("flatHeating")
    ),
    
    tabItem(tabName = "centralHeatingSignature",
            centralHeatingSignatureModuleUI("centralHeatingSignature")
    ),
    
    tabItem(tabName = "centralHeatingCurve",
            centralHeatingCurveModuleUI("centralHeatingCurve")
    ),
    
    tabItem(tabName = "dataexplorer",
            dataexplorerModuleUI("dataexplorer")
    ),
    
    tabItem(tabName = "configuration",
            configurationModuleUI("app_configuration")
    ),
    
    tabItem(tabName = "bldgHierarchy",
            bldgHierarchyModuleUI("bldgHierarchy")
    ),
    
    tabItem(tabName = "datasources",
            dataSourcesModuleUI("datasources")
    ),
    
    tabItem(tabName = "datapoints",
            dataPointsModuleUI("datapoints")
    )
  )
)

# ======================================================================
# Put all parts together into ui
ui <- dashboardPage(title = "Low Cost Monitoring",
                    skin = "blue",
                    header,
                    sidebar,
                    body
)

