---
layout: default
title: File structure
nav_order: 3
parent: About lcm

---

# File structure
{: .no_toc }

<hr>

### Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

<hr>

## /app
- This folder contains application specific things
- `app.R` is the starting script for R Portable
- config.cfg conatains configuration for R Portable
- packages.txt includes R libraries which get installed for R Portable. If you extend the application and require a new R package, then you have to edit this file. 

### /library
- Includes the downloaded R packages
- Only used with R Portable

### /shiny
- This folder contains the Shiny application and all the saved time series data and app configurations
- If you work in a local R installation and don't use R Portable, only this folder is interesting for you

#### /config
- All the configuration parameters for the app and project are saved here
- To keep things simple, all the configurations are saved as csv files

##### /bldgHierarchy.csv
- This file contains the project specific building hierarchy
- The file can be edited in the app under `Menue > Settings > Building Hierarchy`
- Every Datapoint respectively sensor gets assigned with a location. This information is used to label diagrams and create pull down menues
- The lcm app is made for one building with one or multiple flats resp apartments. So the building hierarchy includes the flats and its rooms
- Because some modules require the size in square meters and the amount of occupants of each flat analysis purposes, these parameters get saved as well in the hierarchy

Exemplary content:
```csv
flat;size;occupants;rooms
Flat A;120;3;Dormitory,Bathroom,Bathroom,Aisle,Kitchen,Living Room,Office
```

- Note that the different rooms of the flat are comma separated while the rest is separated with semicolons.

##### /configApp.csv
- This file contains application specific configuration settings
- The file can be edited in the app under `Menue > Settings > App Configuration`

##### /configCsv.csv
- This file contains information about the imported csv files
- The file can be edited in the app under `Menue > Settings > Data Sources > csv Files`

##### /configInfluxdb.csv
- This file contains information about the connected [influxDB](https://www.influxdata.com/products/influxdb-overview/){:target="_blank"} databases
- The file can be edited in the app under `Menue > Settings > Data Sources > InfluxDB`

##### /configTtn.csv
- This file contains information about the connected [the things network](https://www.influxdata.com/products/influxdb-overview/){:target="_blank"} applications
- Please see [https://hslu-ige-laes.github.io/lora-devices-ttn/](https://hslu-ige-laes.github.io/lora-devices-ttn/){:target="_blank"} to learn how to create an application and integrate LoRaWAN devices
- The file can be edited in the app under `Menue > Settings > Data Sources > the things network`

##### /dataPoints.csv
- This file contains information about the configured data points
- The file can be edited in the app under `Menue > Settings > Data Points`

##### /etlAggFilterList.csv
- This file contains information which datapoint types should get aggregated
- You only have to modify this file if you extend or adapt the application modules

#### /csvScripts
- In this folder you can save project specific csv parsing scripts
- For csv data sources the importer foresees the standard file formatting options with different settings of e.g. delimiter etc.
- Unfortunately some files come with special formatting and require special parsing. In such cases a specific user-defined R parsing script can be created
- Copy and paste the following code into a new R-file and save it in the folder `/csvSripts`. The script automatically appears in the pull-down menu of the csv importer under `Menu > Data Sources > csv Files > Add New` 

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
**Attention**
- Make sure the returned timestamp of df is UTC and not local time!

#### /data
- This folder includes all the raw data from the data sources (except of InfluxDB) and the cached data
- To keep things simple, all raw time series data get saved as csv files
- Cached and aggregated values are saved as R .rds files (due to performance)

#### /R
- This folder contains all R files (server functions, modules and helper functions)
- The application is based on <a href="https://mastering-shiny.org/scaling-modules.html" target="_blank">modules</a> in order to keep everything in a maintainable and sustainable manner
- Basically every page in the application has its own module
- To learn how data can get exchanged between modules please consult the following [link](https://engineering-shiny.org/structure.html#communication-between-modules){:target="_blank"}

#### /www
- Shiny application folder where files for the web server session can get saved, e.g. the favicon.ico

<hr>

## /dataFetcher
- This folder contains the R [Data Fetcher](https://hslu-ige-laes.github.io/lcm/docs/about/installation/dataFetcher/) script and a batch file which fetches the data from the things network apllications

<hr>

## /dist
- This folder contains the R Portable code to run "lcm" in Windows as self-contained desktop R application
- If you work with a local R installation you don't need this folder
<hr>

## /docs
- This folder contains documentation.
- The documentation gets automatically generated with GithubPages and is published under [https://hslu-ige-laes.github.io/lcm/](https://hslu-ige-laes.github.io/lcm/)
- The documentation is written in [Markdown language](https://en.wikipedia.org/wiki/Markdown){:target="_blank"}

<hr>

## /sampleData
- Sample csv files for demonstration purposes

