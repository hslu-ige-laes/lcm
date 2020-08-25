# ======================================================================
# header
header <- dashboardHeader(
  title = textOutput("pageTitle"),
  tags$li(actionLink("updateButton", label = " Update data", icon = icon("sync")),class = "dropdown")
)

# ======================================================================
# sidebar
sidebar <- dashboardSidebar(
  sidebarMenu(
    # Setting the id ensures input$tabs knows the names of currently selected tab
    # icons from https://fontawesome.com/icons?d=gallery&m=free
    id = "tabs",
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItemOutput("tempreductionMenuItem"),
    menuItemOutput("comfortTempHumMenuItem"),
    menuItemOutput("comfortTempROaMenuItem"),
    menuItemOutput("comfortAqualMenuItem"),
    menuItemOutput("ventilationFlatsMenuItem"),
    menuItemOutput("hotWaterFlatsMenuItem"),
    menuItemOutput("heatingFlatsMenuItem"),
    menuItemOutput("heatingCentralMenuItem"),
    menuItemOutput("heatingCurveMenuItem"),
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
  # tags$head(tags$style(".shiny-notification {position: fixed; top: 20% ;left: 50%}")),
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
    tabItem(tabName = "dashboard",
            "content tbd"
    ),
    
    tabItem(tabName = "tempreduction",
            temperatureReductionModuleUI("tempreduction")
    ),
    
    tabItem(tabName = "comfortTempHum",
            comfortTempHumModuleUI("cmfTempHum")
    ),
    
    tabItem(tabName = "comfortTempROa",
            comfortTempROaModuleUI("cmfTempROa")
    ),
    
    tabItem(tabName = "comfortAQual",
            comfortAQualModuleUI("cmfAQual")
    ),
    
    tabItem(tabName = "ventilationFlats",
            ventilationFlatsModuleUI("ventilationFlats")
    ),
    
    tabItem(tabName = "hotWaterFlats",
            hotWaterFlatsModuleUI("hotWaterFlats")
    ),
    
    tabItem(tabName = "heatingFlats",
            heatingFlatsModuleUI("heatingFlats")
    ),
    
    tabItem(tabName = "heatingCentral",
            heatingCentralModuleUI("heatingCentral")
    ),
    
    tabItem(tabName = "heatingCurve",
            heatingCurveModuleUI("heatingCurve")
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
ui <- dashboardPage(title = "Monitoring Dashboard",
                    skin = "blue",
                    header,
                    sidebar,
                    body
)

