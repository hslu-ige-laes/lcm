---
layout: default
title: Overview
nav_order: 1
description: "Low Cost Monitoring - Documentation"
permalink: /
---
# lcm
> "Low Cost Monitoring" application for residential buildings
> - Fetch, store and analyze IoT data to save energy
> - supported data sources are LoRaWAN sensors, influxDB or csv files

## General
### What is a Shiny application
A Shiny app is a web  application that communicates and works with the [programming language R](https://en.wikipedia.org/wiki/R_(programming_language)). Beside a basic knowledge of R and its environment no further knowledge of HTML, CSS or JavaScript is required to build small and minimal apps. That's why R and its web application extension Shiny are a good solution to build prototypes of web apps which require data analysis and visualization functionality. 

>**Get started with R and R Shiny**
>
> If you are new to Shiny we suggest to start with the free <a href="https://mastering-shiny.org/" target="_blank">"Mastering Shiny book"</a>

## Installation
The application comes as R package and is available on github.
You can install the released version of lcm from [hslu-ige-laes](https://github.com/hslu-ige-laes/) with:

``` r
install.packages("devtools")
library(devtools)
install_github("hslu-ige-laes/lcm")
```

### Prerequisites



## System Architecture
The basic structure follows the [data warehouse principle](https://en.wikipedia.org/wiki/Data_warehouse). Data from multiple sources get collected and saved. Following the ETL principle (Extract, Transform, Load), where "Load" colloquially stands for store.  

[![Application Architecture](https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/docs/systemArchitecture_01.PNG)]()

### Data Sources
Data can get fetched from different sources:
- manual import via csv files
- [ttn LoRa Data Storage](https://www.thethingsnetwork.org/docs/applications/storage/) (periodical API calls)
- [influx database](https://docs.influxdata.com/influxdb/)

### Warehouse
Data get saved in a raw format. The only exceptions are influxDB data, where the original raw data does not get saved. To keep things simple and for , all the configurations are saved as csv files.


## File structure
### /config [Configuration parameters]
To keep things simple, all the configurations are saved as csv files.

#### /csvScripts [csv parsing scripts]
For csv data sources the importer foresees the standard file formatting options with different settings of e.g. delimiter etc.

Unfortunately some files come with special formatting and require special parsing. In such cases a specific user-defined R parsing script can be created.
Copy and paste the following code into a new R-file and save it in the folder /csvSripts. The script automatically appears in the pull-down menu of the csv importer under `Menu > Data Sources > csv Files > Add New` 

Parsing script template:
```R
myParsingScriptName <- function(filePath = NULL) {
  
  if(is.null(filePath)){
    return(NULL)
  }
  # read csv file
  df <- read.csv(filePath, stringsAsFactors=FALSE)
  
  # parse and transform data here
  # final data format should be in long format: time,value1,value2, etc.
  # time,value1,value2
  # 2020-07-30 13:00:00,53,10.5

  return(df)
}
```
>**Attention**
>- Make sure the returned timestamp of df is UTC and not local time!


#### bldgHierarchy.csv [Building Hierarchy]
>The file can be edited in the app under `Menue > Settings > Building Hierarchy`

Every Datapoint respectively sensor gets assigned with a location. This information is used to label diagrams and create pull down menues.

The lcm app is made for one building with one or multiple flats resp apartments. So the building hierarchy includes the flats and its rooms. Because some modules require the size in square meters and the amount of occupants of each flat analysis purposes, these parameters get saved as well in the hierarchy.

Exemplary content:
```csv
flat;size;occupants;rooms
Flat A;120;3;Dormitory,Bathroom,Bathroom,Aisle,Kitchen,Living Room,Office
```

>Note that the different rooms of the flat are comma separated while the rest is separated with semicolons.

#### configApp.csv [Application configurations]
>The file can be edited in the app under `Menue > Settings > App Configuration`

Application specific configuration settings.

Exemplary content:
```csv
pageTitle;bldgAltitude;bldgTimeZone
Low Cost Monitoring;450;Europe/Zurich
```

### /modules [Shiny modules]
The application is based on <a href="https://mastering-shiny.org/scaling-modules.html" target="_blank">modules</a> in order to keep everything in a maintainable and sustainable manner. Basically every page in the application has its own module.

https://engineering-shiny.org/structure.html#communication-between-modules

### /data [Data ingestion and storage]
To keep things simple, all the configuration values as well the imported data get's saved as csv file.
Cached and aggregated values are saved as R .rds files.
The whole data in

## Naming conventions
The naming convention of the book [Engineering Production-Grade Shiny Apps](https://engineering-shiny.org/structure.html#conventions-matter) was adopted.

