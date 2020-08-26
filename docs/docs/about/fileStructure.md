---
layout: default
title: File structure
nav_order: 2
parent: About the app
---

# File structure
{: .no_toc }
---
## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---
## /app
- This folder contains application specific things.
- app.R is the starting script for R Portable
- config.cfg conatains configuration for R Portable
- packages.txt includes R libraries which get installed for R Portable. If you extend the application and require a new R package, then you have to edit this file. 

### /library
- Includes the downloaded R packages.
- Only used with R Portable.

### /shiny
- This folder contains the Shiny application and all the saved time series data and app configurations.
- If you work in a local R installation and don't use R Portable, only this folder is interesting for you.

#### /config
- All the configuration parameters for the app and project are saved here.
- To keep things simple, all the configurations are saved as csv files.

##### /bldgHierarchy.csv
- This file contains the project specific building hierarchy.
- The file can be edited in the app under `Menue > Settings > Building Hierarchy`
- Every Datapoint respectively sensor gets assigned with a location. This information is used to label diagrams and create pull down menues.
- The lcm app is made for one building with one or multiple flats resp apartments. So the building hierarchy includes the flats and its rooms.
- Because some modules require the size in square meters and the amount of occupants of each flat analysis purposes, these parameters get saved as well in the hierarchy.

Exemplary content:
```csv
flat;size;occupants;rooms
Flat A;120;3;Dormitory,Bathroom,Bathroom,Aisle,Kitchen,Living Room,Office
```

- Note that the different rooms of the flat are comma separated while the rest is separated with semicolons.

##### /configApp.csv
- This file contains application specific configuration settings.
- The file can be edited in the app under `Menue > Settings > App Configuration`

Exemplary content:
```csv
pageTitle;bldgAltitude;bldgTimeZone
Low Cost Monitoring;450;Europe/Zurich
```

#### /csvScripts
- In this folder you can save project specific csv parsing scripts.
- For csv data sources the importer foresees the standard file formatting options with different settings of e.g. delimiter etc.
- Unfortunately some files come with special formatting and require special parsing. In such cases a specific user-defined R parsing script can be created.
- Copy and paste the following code into a new R-file and save it in the folder /csvSripts. The script automatically appears in the pull-down menu of the csv importer under `Menu > Data Sources > csv Files > Add New` 

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

#### /modules
- The application is based on <a href="https://mastering-shiny.org/scaling-modules.html" target="_blank">modules</a> in order to keep everything in a maintainable and sustainable manner.
- Basically every page in the application has its own module.
- To learn how data can get exchanged between modules please consult the following [link](https://engineering-shiny.org/structure.html#communication-between-modules)

#### /data
- This folder includes all the raw data from the data sources (except of InfluxDB) and the cached data.
- To keep things simple, all raw time series data get saved as csv files.
- Cached and aggregated values are saved as R .rds files (due to performance).

## /dist
- This folder contains the R Portable code to run "lcm" in Windows as self-contained desktop R application.
- If you work with a local R installation you don't need this folder.

## /docs
- This folder contains documentation.
- The documentation gets automatically generated with GithubPages and is published under [https://hslu-ige-laes.github.io/lcm/](https://hslu-ige-laes.github.io/lcm/)
- The documentation is written in [Markdown language](https://en.wikipedia.org/wiki/Markdown).
