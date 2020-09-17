etlAggFilterData <- function(){
  
  etlAggFilterList <- loadDataPointsFile(here::here("app", "shiny", "config", "etlAggFilterList.csv"))
  configFileApp <- loadConfigFile(here::here("app", "shiny", "config", "configApp.csv"))
  dataPoints <- loadDataPointsFile(here::here("app", "shiny", "config", "dataPoints.csv"))

  locTimeZone <- configFileApp[["bldgTimeZone"]]
  
  # row <- 3
  
  for(row in 1:nrow(etlAggFilterList)){
    filterDpType <- unlist(strsplit(as.character(etlAggFilterList[row,4]), split=","))
    func <- as.character(etlAggFilterList[row,2])
    agg <- as.character(etlAggFilterList[row,1])
    fill <- as.character(etlAggFilterList[row,3])
    
    # tic(paste0("getData: data_", agg, "_", func))
    
    # check if file exists
    # fileName <- here::here("app", "shiny", "data", "cache", paste0("data_","1h" ,"_","mean", ".RData"))
    # fileName <- "C:/Repositories/github/hslu-ige-laes/lcm/app/shiny/data/cache/data_1h_mean.RData"
    fileName <- here::here("app", "shiny", "data", "cache", paste0("data_",agg ,"_",func, ".RData"))
    if (!file.exists(fileName)) {
      df.all <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
    } else {
      load(file = fileName)
      # eval(parse(text=paste0("df.all <- ", "data_",agg ,"_",func)))
    }
    
    # create list for iteration
    list  <- dataPoints %>% filter(dpType %in% filterDpType)
    
    if(nrow(list) > 0){
      
      df.all  <- df.all %>% filter(abbreviation %in% list$abbreviation)
      
      list.old <- df.all %>% select(abbreviation) %>% unique()
      
      data <- list()
      
      # loop through list
      for (row2 in 1:nrow(list)) {
        dpAbbr <- as.character(list[row2,"abbreviation"])
        print(paste0("fetching ", dpAbbr))
        if(dpAbbr %in% list.old$abbreviation) {
          lastMeasurement <- df.all %>% filter(abbreviation == dpAbbr) %>% last()
          data.i <- getTimeSeries(dpAbbr, datetimeStart = lastMeasurement$time, datetimeEnd = NULL, func = func, agg = agg, fill = fill, locTimeZone = locTimeZone)
        } else {
          data.i <- getTimeSeries(dpAbbr, datetimeStart = NULL, datetimeEnd = NULL, func = func, agg = agg, fill = fill, locTimeZone = locTimeZone)
        }
        
        if(!is.null(data.i) && (nrow(data.i) > 0)){
          # rename value column
          names(data.i)[2] <- "value"
          
          # additional data in separate column for later filtering
          data.i$abbreviation <- dpAbbr
          data.i$flat <- as.character(list[row2,"flat"])
          data.i$room <- as.character(list[row2,"room"])
          data.i$dpType <- as.character(list[row2,"dpType"])
          
          df.all <- rbind(df.all, as.data.frame(data.i))
        }
      }
    } else {
      df.all <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
    }

    df.all <- df.all %>% unique()
  
    save(df.all, file = fileName)

    }
}

clearCache <- function(){
  fold <- here::here("app", "shiny", "data", "cache")
  # get all files in the directories, recursively
  f <- list.files(fold, include.dirs = F, full.names = T, recursive = T)
  # remove the files
  file.remove(f)
}


getDataPointNames <- function(dpSourceName){
  dpList <- NULL
  
  configFileTtn <- loadDataSourceFile(here::here("app", "shiny", "config", "configTtn.csv"))
  configFileInfluxdb <- loadDataSourceFile(here::here("app", "shiny", "config", "configInfluxdb.csv"))
  configFileCsv <- loadDataSourceFile(here::here("app", "shiny", "config", "configCsv.csv"))

  
  # check if data source is from the things network
   if(dpSourceName %in% configFileTtn$sourceName){
     dpList <- ttnGetDataPointNames(dpSourceName)
   }
  
  # check if data source is from influxDB
  if(dpSourceName %in% configFileInfluxdb$sourceName){
    
    list <- configFileInfluxdb %>% filter(sourceName == dpSourceName)

    dpList <- influxdbGetMeasurements(host = list$influxdbHost,
                                      port = list$influxdbPort,
                                      user = list$influxdbUser,
                                      pwd = list$influxdbPwd,
                                      database = list$influxdbDatabase
    )
  }
  
  # check if data source is from csv
  if(dpSourceName %in% configFileCsv$sourceName){
    dpList <- csvGetDataPointNames(dpSourceName)
  }
  
  return(dpList)
}

getTimeSeries <- function(dpAbbr = NULL, dpSource = NULL, dpSourceRef = NULL, datetimeStart = NULL,
                          datetimeEnd = NULL, func = "raw", agg = "1d", fill = "null", dpFieldKey = "value", valueFactor = 1, valueType = "absVal",
                          locTimeZone = "Europe/Zurich") {
  
  configFileApp <- loadConfigFile(here::here("app", "shiny", "config", "configApp.csv"))
  configFileTtn <- loadDataSourceFile(here::here("app", "shiny", "config", "configTtn.csv"))
  configFileInfluxdb <- loadDataSourceFile(here::here("app", "shiny", "config", "configInfluxdb.csv"))
  configFileCsv <- loadDataSourceFile(here::here("app", "shiny", "config", "configCsv.csv"))
  dataPoints <- loadDataPointsFile(here::here("app", "shiny", "config", "dataPoints.csv"))
  
  # verify inputs
  if(!is.null(dpAbbr)){
    source <- as.character(dataPoints %>% filter(abbreviation == dpAbbr) %>% select(sourceName))
    datapoint <- as.character(dataPoints %>% filter(abbreviation == dpAbbr) %>% select(sourceReference))
    dpFieldKey <- as.character(dataPoints %>% filter(abbreviation == dpAbbr) %>% select(fieldKey))
    valueFactor <- as.numeric(dataPoints %>% filter(abbreviation == dpAbbr) %>% select(valueFactor))
    valueType <- as.character(dataPoints %>% filter(abbreviation == dpAbbr) %>% select(valueType))
  } else if ((!is.null(dpSource)) & (!is.null(dpSourceRef))) {
    source <- dpSource
    datapoint <- dpSourceRef
  } else {
    return(NULL)
  }
  
  if(is.null(datetimeStart)){datetimeStart <- "2000-01-01"}
  if(is.null(datetimeEnd)){datetimeEnd <- Sys.time()}
  
  # handle different data sources
  if(nrow(configFileTtn %>% select(sourceName) %>% filter(sourceName == source)) == 1){ # check the things network
    data <- ttnGetTimeSeries(datapoint = datapoint,
                             sourceName = source,
                             datetimeStart = datetimeStart,
                             datetimeEnd = datetimeEnd,
                             func = func,
                             agg = agg,
                             valueFactor = valueFactor,
                             valueType = valueType,
                             locTimeZone = locTimeZone
    )
    
  }else if(nrow(configFileInfluxdb %>% select(sourceName) %>% filter(sourceName == source)) == 1){ # check influxDB
    list <- configFileInfluxdb %>% filter(sourceName == source)
    data <- influxdbGetTimeseries(host = list$influxdbHost,
                                  port = list$influxdbPort,
                                  user = list$influxdbUser,
                                  pwd = list$influxdbPwd,
                                  database = list$influxdbDatabase,
                                  measurement = datapoint,
                                  datetimeStart = datetimeStart,
                                  datetimeEnd = datetimeEnd,
                                  func = func,
                                  agg = agg,
                                  fieldKey = dpFieldKey,
                                  fill = fill,
                                  valueFactor = valueFactor,
                                  valueType = valueType,
                                  locTimeZone = locTimeZone
    )
  }else if(nrow(configFileCsv %>% select(sourceName) %>% filter(sourceName == source)) == 1){ # check csv
    fileName <- configFileCsv %>% filter(sourceName == source) %>% select(csvFileName)
    data <- csvGetTimeSeries(fileName = fileName,
                             datapoint = datapoint,
                             datetimeStart = datetimeStart,
                             datetimeEnd = datetimeEnd,
                             func = func,
                             agg = agg,
                             valueFactor = valueFactor,
                             valueType = valueType,
                             locTimeZone = locTimeZone
    )
  }else{ # no datasource found
    data <- NULL
  }
  return(data)
}

