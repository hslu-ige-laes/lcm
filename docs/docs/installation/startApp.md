---
layout: default
title: Start App
nav_order: 03
parent: Installation
---

# Start applicaton
## in R Portable
It works with the portableApps framework, so R can be run without a local installation. This works as well on a flash drive!

- Execute `lcmStartApp.bat` in the application folder
- A browser will open and show the application
- To stop the application simply close the browser window

## in local installation
### RStudio console
1. Open the R Studio Project by clicking `lcm.Rproj`
1. Either run `runApp("./app/shiny/")` in the console or open the file `/app/shiny/server.R` in the files tab and click the green arrow "> Run App"
1. The application starts
1. To stop the application press the red stop icon

### via Desktop Link (Windows)
1. Create a new desktop link
1. For the execution path enter `"C:\Program Files\R\R-3.6.3\bin"`
1. As target enter `"C:\Program Files\R\R-3.6.3\bin\R.exe" -e "shiny::runApp('C:/PATH_TO_YOUR_APP/lcm/shiny', launch.browser = TRUE)` where you have to exchange `PATH_TO_YOUR_APP` with your folder location
1. By double clicking the icon a dos command window as well as a browser opens
1. To stop the application close the dos command window
