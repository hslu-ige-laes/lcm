---
layout: default
title: Start App
nav_order: 6
parent: Installation
---

# Start lcm application
## via "R Portable"
- Execute `lcm.bat` in the application folder.
- A browser will open
- To stop the application simply close the browser window

## via "R Studio console"
1. Open the R Studio Project by clicking `lcm.Rproj`
1. Either run `runApp("./app/shiny/")` in the console or open the file `/app/shiny/server.R` in the files tab and click the green arrow "> Run App".
1. To stop the application press the red stop icon

## via Desktop Link (Windows)
1. Create a new desktop link
1. For the execution path enter `"C:\Program Files\R\R-3.6.3\bin"`
1. As target enter`"C:\Program Files\R\R-3.6.3\bin\R.exe" -e "shiny::runApp('C:/PATH_TO_YOUR_APP/lcm/shiny', launch.browser = TRUE)` where you have to exchange `PATH_TO_YOUR_APP` with your folder location.
1. By double clicking the icon a dos command window opens
1. To stop the application close the dos command window