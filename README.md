# lcm - Low Cost Monitoring
<img src="https://github.com/hslu-ige-laes/lcm/raw/master/docs/assets/images/lcm.png" width="100" align="right" class="inline"/>

- "lcm" is an open source monitoring application for residential buildings
- The focus of the application is on providing energy savings whilst maintaining the expected comfort
- The application fetches, stores, analyzes and displays data from various sources
- Supported data sources include LoRaWAN sensors, influxDB and CSV files
- The lcm monitoring solution is cost-effective and "do it yourself"

## Getting started
- [Live Demo](https://hslu-ige-laes.shinyapps.io/lowcostmonitoring/)<br>
- [Documentation](https://hslu-ige-laes.github.io/lcm/)<br>
- Quick Start Guide<br>
  [English](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/en/) - [Deutsch](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/de/) - [Français](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/fr/) - [Italiano](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/it/)

<img src="https://github.com/hslu-ige-laes/lcm/raw/master/docs/assets/images/home_Demo.gif" width="100%" style="border:1px solid lightgrey"/>

**Disclaimer**<br>
This is a prototype. The authors decline any liability or responsibility in connection with the lcm application.

&copy; Lucerne University of Sciences and Arts, 2020

<hr>

## Simplified installation instructions
> For more details please consult [https://hslu-ige-laes.github.io/lcm/docs/installation](https://hslu-ige-laes.github.io/lcm/docs/installation)

### without installing R (only on Windows)
1. <a href="https://github.com/hslu-ige-laes/lcm/releases/latest/download/lcm.zip" download>Download lcm application</a>
1. Extract the content to a folder of your choice (you can rename the folder `lcm-x.y` to any name)
1. Execute `lcmStartApp.bat` in the application folder
1. A browser will open and show the application

### with R installation
1. Download and install R version 3.6.3 from [http://cran.r-project.org/](http://cran.r-project.org/)
1. <a href="https://downgit.github.io/#/home?url=https://github.com/hslu-ige-laes/lcm" download>Download lcm application</a>
1. Extract the content to a folder of your choice
1. Open R and install required libraries (see global.R)
1. execute `runApp("./app/shiny/")`
1. A browser will open and show the application

