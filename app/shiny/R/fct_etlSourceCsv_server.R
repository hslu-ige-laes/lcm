
# # Test function call for debugging
# fileName <- "TempFeuchteWhg3.csv"
# fileName <- "KwlFanPercZul.csv"
# datapoint <- "Feuchte"
# datetimeStart = "2019-01-01"
# datetimeEnd = "2019-10-31"
# func = "mean"
# agg = "1d"
# 
# head(csvGetTimeSeries(fileName, datapoint, datetimeStart, datetimeEnd, func, agg))
# 

csvGetTimeSeries <- function(fileName, datapoint,
                             datetimeStart = NULL, datetimeEnd = NULL,
                             func = "raw", agg = "1d", fill = "null", valueFactor = 1, valueType = "absVal",
                             locTimeZone = "Europe/Zurich"){
  
  df <- read_csv2(file = here::here("app", "shiny", "data", "csv", fileName), na = c("", "NA"))
  # df <- read_delim(file = here::here("app", "shiny", "data", "csv", fileName), na = c("", "NA"), delim = ";")
  
  df <- df %>% select(time, datapoint)
  
  switch(valueType,
         counterVal = {
           # increasing counter reading values
           # calculate difference to get consumption values
           df[[datapoint]] <- df[[datapoint]] - lag(df[[datapoint]])
           
           # tbd: handle counter reading fall backs...
           
         },
         {
           # do nothing as default, e.g. for "absVal"
         }
  )
  
  # multiply with conversion valueFactor (for example 0.001 to get from Watthours to Kilowatthours)
  df[[datapoint]] <- df[[datapoint]] * valueFactor
  
  df <- df %>% na.omit()

  # tbd: this line sometimes doesn't work, check how to replace "" with NA. Does not work with time column?!
  # df <- df %>% mutate_all(na_if,"")
  # df <- df %>% na.omit()
  df$time <- parse_date_time(df$time, "YmdHMS", tz = locTimeZone)
  df <- df %>% na.omit()
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
    data$time <- parse_date_time(data$time, "Ymd", tz = locTimeZone)
  } else {
    if(grepl("X",rownames(data)[1] , fixed=TRUE)){
      data$time <- as.POSIXct(data$time, format = "X%Y.%m.%d.%H.%M.%S")
    } else {
      data$time <- parse_date_time(data$time, "YmdHMS", tz = locTimeZone)
    }
  }
  
  # data$time <- parse_date_time(data$t ime, "Ymd", tz = locTimeZone)
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

csvGetDataPointNames <- function(dpSourceName) {
  fileName <- as.character((configFileCsv() %>% filter(sourceName == dpSourceName) %>% select(csvFileName))[[1]])
  
  dpList <- as.data.frame(names(read_csv2(file = here::here("app", "shiny", "data", "csv", fileName), n_max = 1)))
  names(dpList)[1] <- "name"
  dpList <- filter(dpList, name != "time")
  
  return(dpList)
}

