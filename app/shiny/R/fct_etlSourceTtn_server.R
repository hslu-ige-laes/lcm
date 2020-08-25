# libraries are included in global.R
# library(httr)
# library(jsonlite)
# library(dplyr)
# library(lubridate)
# library(tictoc) # for time measuring

# ==========================================================================
# tbd: get data only if there are new data -> kind of reactivePoll
# tbd: Error handling überlegen, wie werden Nutzer informiert über Fehler?
#      "else"-part ganz am Ende vom Code
#      ev. try catch einbauen für Error Handling
# tbd: wie Fehler abfangen bei ttnData(), das hätte zwei return values was kompliziert wird.
# ==========================================================================

# # settings for local debugging
# appId <- "lowcostmonitoring"
# key <- "ttn-account-v2.5X4MFYGQI3B48pECjyyAybIZozz2_Fg2YXehzJ4t3g0"
# locTimeZone <- "Europe/Zurich"
# range <- "7d"
# 
# # Test function call for debugging
# ttnData <- ttnFetcher(appId="lowcostmonitoring",
#                       key = "ttn-account-v2.5X4MFYGQI3B48pECjyyAybIZozz2_Fg2YXehzJ4t3g0",
#                       locTimeZone = "Europe/Zurich",
#                       range = "7d")
# 
# result <- ttnWriteRawCsv(ttnData, locTimeZone = "Europe/Zurich")

ttnReadServerData <- function(appId, key, locTimeZone = "Europe/Zurich", range = "7d") {
  # get data
  url <- paste0("https://", appId, ".data.thethingsnetwork.org")
  
  response = tryCatch({
      GET(url = url,
          add_headers(Accept = "application/json",
                      Authorization = paste0("key ", key)
          ),
          path = "/api/v2/query",
          query = list(last="7d")
      )
    }, warning = function(w) {
      print("warning")
      return(NULL)
    }, error = function(e) {
      print("error")
      return(NULL)
    }
  )
  # print("response")
  # print(response)
  # print(status_code(response))
  if(is.null(response)){
    data <- NULL
    print("Error in html request")
  } else if (status_code(response) == 200) {
    #tic("time conversion")
    json <- httr::content(response, as = "text", encoding = "UTF-8")
    data <- fromJSON(json)
    
    # rearrange columns, time first
    data <- select(data, time, device_id, everything())
    
    # make timezone conversion because values in TTN Data Storage are UTC
    data$time <- parse_date_time(data$time, "YmdHM0S", tz = "UTC")
    data$time <- with_tz(data$time, locTimeZone)
    data$time <- round_date(data$time, unit = "second")
    
  } else {
    # Error message and notification
    print("Error in html request")
    data <- NULL
  }
  return(data)
}

ttnWriteRawCsv <- function(data = NULL, sourceName, locTimeZone = "Europe/Zurich") {
  # write csv files for each device and datapoint separately
  if (is.null(data)){
    print("Error ttnWriteRawCsv(): data object is NULL")
    return()
    }
  
  devices <- distinct(data, device_id)
  
  for (i in 1:nrow(devices)) {
    deviceName <- devices[i, 1]
    deviceData <- data %>% filter(device_id == deviceName)
    
    # remove columns with all na
    deviceData <- deviceData %>% select_if(~sum(!is.na(.)) > 0)
    
    deviceDatapoints <- as.list(names(deviceData))
    
    # remove "time" and device_id in column 1 and 2 for looping through datapoints
    deviceDatapoints <- deviceDatapoints[c(-1, -2)];
    
    for(j in 1:length(deviceDatapoints)) {
      
      datapointName <- as.character(deviceDatapoints[j])
      datapointFileName <- paste0(here::here(), "/app/shiny/data/ttn/", sourceName, "/", deviceName, "_", datapointName, ".csv")

      filter <- c("time", datapointName)
      datapointDataNew <- deviceData %>% select(one_of(filter)) %>% na.omit()
      
      if(file.exists(datapointFileName)){
        # load existing file
        datapointDataOld <- read_csv2(datapointFileName)
        datapointDataOld$time <- parse_date_time(datapointDataOld$time, "YmdHM0S", tz = locTimeZone)

        # find changes and append them to existing file
        datapointDataNew <- anti_join(datapointDataNew,datapointDataOld, by = "time")

        if(nrow(datapointDataNew) > 0){
          write.table(datapointDataNew, file = datapointFileName, append = TRUE, row.names = FALSE, col.names = FALSE, sep = ";", quote = FALSE)
          print(paste0("appended ttn data to: ", datapointFileName))
          print(datapointDataNew)
        }else{
          print(paste0("no new ttn data points for: ", datapointFileName))
        }
      }else{
        # create new file
        write.table(datapointDataNew, file = datapointFileName, row.names = FALSE, sep = ";")
        print(paste0("created new file: ", datapointFileName))
      }
    }
  }
}

ttnFetchServerData <- function(){
  
  configFileTtn <- loadDataSourceFile(here::here("app", "shiny", "config", "configTtn.csv"))
  configFileApp <- loadConfigFile(here::here("app", "shiny", "config", "configApp.csv"))
  if(nrow(configFileTtn) > 0) {
    for (row in 1:nrow(configFileTtn)) {
      if(as.logical(configFileTtn[row,"ttnFetchingEnabled"])){
        print(paste0(configFileTtn[row,"ttnAppId"], ": ttn Fetcher activated, fetching data"))  
        
        ttnData <- ttnReadServerData(appId=configFileTtn[row,"ttnAppId"],
                                     key = configFileTtn[row,"ttnAccessKey"],
                                     locTimeZone = configFileApp[["bldgTimeZone"]],
                                     range = "7d")
        
        result <- ttnWriteRawCsv(ttnData, sourceName=configFileTtn[row,"sourceName"], locTimeZone = configFileApp[["bldgTimeZone"]])
        
      }else{
        print(paste0(configFileTtn[row,"ttnAppId"], ": ttn Fetcher deactivated"))  
      }
    }
  }
}

# # Test function call for debugging
datapoint <- "wisely01_temp"
locTimeZone = "Europe/Zurich"
func = "mean"
agg = "1W"
agg = "1d"
fill = "none"
datetimeStart = "2020-01-01"
datetimeEnd = "2020-03-01"
sourceName = "AvelonWiselySensors"

# head(ttnGetTimeSeries(datapoint, datetimeStart, datetimeEnd, func, agg, locTimeZone))

ttnGetTimeSeries <- function(datapoint, sourceName,
                             datetimeStart = NULL, datetimeEnd = NULL,
                             func = "raw", agg = "1d", fill = "null", valueFactor = 1, valueType = "absVal",
                             locTimeZone = "Europe/Zurich"){

  if(fill != "previous"){
    fill <- "null"
  }
  
  df <- read.table(file = here::here("app", "shiny", "data", "ttn", sourceName, paste0(datapoint,".csv")), header = TRUE, sep = ";")
  
  switch(valueType,
         counterVal = {
           # increasing counter reading values
           # calculate difference to get consumption values
           df[[2]] <- df[[2]] - lag(df[[2]])
           
           # tbd: handle counter reading fall backs...
           
         },
         {
           # do nothing as default, e.g. for "absVal"
         }
  )
  # saveRDS(df, paste0(here::here(), "/app/shiny/temp/temp.rds"))
  
  # multiply with conversion valueFactor (for example 0.001 to get from Watthours to Kilowatthours)
  df[[2]] <- df[[2]] * valueFactor
  
  df <- df %>% na.omit()
  df$time <- parse_date_time(df$time, "YmdHMS", tz = locTimeZone)
  df <- df %>% dplyr::arrange(time)
  
  xts <- xts(df[,-1], order.by = df$time)
  colnames(xts) <- datapoint

  switch(func,
         raw = {
           # get raw values nothing has to be done here...
           data <- df
         },
         diffMax = {
           ## get difference from max values in aggregation range
           data <- as.data.frame(aggregateXts(xts, "max", agg, locTimeZone))
           data[[datapoint]] <- data[[datapoint]] - lag(data[[datapoint]])
         },
         {
           ## get values in aggregation range according to func argument
           data <- as.data.frame(aggregateXts(xts, func, agg, locTimeZone))
         }
  )

  if(!(func == "raw")){
    data$time<- row.names(data)
  }
  
  if((agg == "1d" | agg == "1W" | agg == "1M" | agg == "1Y") & (func != "raw")){
    data$time <- as.Date(data$time)
  } else {
    data$time <- parse_date_time(data$time, "YmdHMS", tz = locTimeZone)
  }
 
  # data$time <- parse_date_time(data$time, "Ymd", tz = locTimeZone)
  rownames(data) <- NULL
  
  # rearrange columns
  data <- data %>% select(time, everything())

  if(is.null(datetimeStart) & is.null(datetimeEnd)){
    # return full range, noting has to be done
    
  } else if (is.null(datetimeStart)){
    time_end <- as.POSIXct(datetimeEnd, tz = locTimeZone)
    data <- data %>% filter(time < time_end)
    
  } else if (is.null(datetimeEnd)){
    time_start <- as.POSIXct(datetimeStart, tz = locTimeZone)
    data <- data %>% filter(time > time_start)
    
  } else {
    time_start <- as.POSIXct(datetimeStart, tz = locTimeZone)
    time_end <- as.POSIXct(datetimeEnd, tz = locTimeZone)
    data <- data %>% filter(time > time_start & time < time_end)
  }
  
  if(fill == "previous"){
    data <- na.locf(data)
  } else {
    data <- data %>% na.omit()
  }

  rownames(data) <- NULL
  
  return(data)
}

ttnGetDataPointNames <- function(dpSourceName) {
  
  # read all filenames in ttn application folder without extension ".csv" 
  dpList <- as.data.frame(gsub("\\.csv$","", list.files(here::here("app", "shiny", "data", "ttn", dpSourceName), pattern="\\.csv$")))
  names(dpList)[1] <- "name"

  return(dpList)
}

