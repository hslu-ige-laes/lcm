---
layout: default
title: Start application
nav_order: 03
parent: Installation
---

# Start applicaton
## R Portable
- Execute `lcmStartApp.bat` in the application folder
- A Web browser will open and display the application
- To quit the application, simply close the browser window

<hr>

## Local installation
### RStudio console
1. Open the R Studio Project by clicking `lcm.Rproj`
1. Either run `runApp("./app/shiny/")` in the console, or open the file `/app/shiny/server.R` in the files tab and click the green arrow "> Run App"
1. The application starts
1. To quit the application, press the red stop icon

### via Desktop Link (Windows only)
1. Create a new desktop link
1. Define the following target: `"C:\Program Files\R\R-3.6.3\bin\R.exe" -e "shiny::runApp('C:/PATH_TO_YOUR_APP/lcm/app/shiny', launch.browser = TRUE)`, where you need to replace `PATH_TO_YOUR_APP` with your folder location
1. When double-clicking the link icon, a Command Prompt as well as a Web browser open
1. To quit the application, close the Command Prompt
