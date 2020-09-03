
# ======================================================================
# tbd: fill in influxdbGetMeasurements anschauen was enum wäre
# tbd: problem with diffMax where there is no start and end-Date in the query!
# ======================================================================

# # Testcalls
# host = "10.180.26.130"
# port = "8086"
# user = NULL
# pwd = NULL
# database = "huettengraben"
# measurement = "HK02_00_TMP_MET_AT_RT"
# measurement = "HK02_01_WAE_FBH_RZ"
# measurement = "HK14_04_ELE_WHG_EG_2_RZ"
# datetimeStart = "2000-01-01 00:00:00"
# datetimeStart = "2020-01-01 00:00:00"
# datetimeEnd = "2020-02-01 00:00:00"
# datetimeEnd = Sys.time()
# datetimeStart = NULL
# datetimeEnd = NULL
# func = "raw"
# func = "diffMax"
# func = "mean"
# func = "min"
# func = "max"
# func = "median"
# agg = "15m"
# agg = "1h"
# agg = "1d"
# agg = "1W"
# agg = "1M"
# agg = "1Y"
# fieldKey = "raw"
# fill = "0"
# locTimeZone = "Europe/Zurich"
# locTimeZone = "GMT"
# locTimeZone = "UTC"
# 
# # show databases
# influxdbGetDatabases(host)
# 
# influxdbGetMeasurements(host = host, database = database)
# 
# test <- influxdbGetTimeseries(host = host, database = database, measurement = measurement, datetimeStart = datetimeStart, datetimeEnd = datetimeEnd, func = func, agg = agg, fieldKey = fieldKey)
# head(test)
# summary(test)


influxdbCon <- function(host, port = "8086", user, pwd){
  
  con <<- tryCatch({
    influx_connection(host = host,
                      port = port,
                      user = user,
                      pass = pwd)
  }, error = function(e) {
    if(isRunning()){
      shinyalert(
        title = "Error",
        text = paste0("Could not connect to influxDB Host ",host ,":",port),
        closeOnEsc = TRUE,
        closeOnClickOutside = TRUE,
        html = FALSE,
        type = "error",
        showConfirmButton = TRUE,
        showCancelButton = FALSE,
        confirmButtonText = "OK",
        confirmButtonCol = "#AEDEF4",
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )
    }
  }
  )
  
  return(con)
}

influxdbGetDatabases <- function(host, port = "8086", user = NULL, pwd = NULL){
  data <- filter(as.data.frame(show_databases(con = influxdbCon(host, port, user, pwd)), name != "_internal"))
  return(data)
}

influxdbGetMeasurements <- function(host, port = "8086", user = NULL, pwd = NULL, database){
  data <- as.data.frame(show_measurements(con = influxdbCon(host, port, user, pwd), db = database))
  
  return(data)
}

influxdbGetFieldKeys <- function(host, port = "8086", user = NULL, pwd = NULL, database = NULL, datapoint = NULL){
  data <- as.data.frame(show_field_keys(con = influxdbCon(host, port, user, pwd), db = database, measurement = datapoint))
  data <- data %>% select(fieldKey)
  return(data)
}

influxdbGetTimeseries <- function(host, port = "8086", user = NULL, pwd = NULL, database, measurement,
                                  datetimeStart = NULL, datetimeEnd = NULL,
                                  func = "raw", agg = "1d", fieldKey = "value", fill = "null", valueFactor = 1, valueType = "absVal",
                                  locTimeZone = "Europe/Zurich"){
  
  # influxDB doesn't support aggregations greater than 1d, thats why the data get fetched by 1d and later aggregated
  aggOld <- agg
  funcOld <- func
  if((agg == "1W" | agg == "1M" | agg == "1Y") & (func != "raw")){
      agg <- "1d"
  }
  
  # increasing counter reading values
  # get first raw values and then
  # calculate difference to get consumption values further down
  if(valueType == "counterVal"){
    func <- "raw"
  }
  
  # in case of diffMax the influxDB query gets first the max and then calculates the diff
  if((aggOld == "1W" | aggOld == "1M" | aggOld == "1Y") & (func == "diffMax")){
    func <- "max"
  }
  
  switch(func,
           raw = {
             # get raw values
             field_keys <- paste0('"', fieldKey,'"')
             group_by <- NaN
             tableName <- fieldKey
           },
           diffMax = {
             ## get difference from max values in aggregation range
             field_keys <- paste0('difference(max(', '"', fieldKey, '"', '))')
             group_by <- paste0('time(', agg, ')')
             tableName <- "difference"
           },
           mean = {
             ## get mean values in aggregation range
             field_keys <- paste0('mean(', '"', fieldKey, '"', ')')
             group_by <- paste0('time(', agg, ')')
             tableName <- "mean"
           },
           median = {
             ## get median values in certain range
             field_keys <- paste0('median(', '"', fieldKey, '"', ')')
             group_by <- paste0('time(', agg, ')')
             tableName <- "median"
           },
           min = {
             ## get min values in aggregation range
             field_keys <- paste0('min(', '"', fieldKey, '"', ')')
             group_by <- paste0('time(', agg, ')')
             tableName <- "min"
           },
           max = {
             ## get max values in aggregation range
             field_keys <- paste0('max(', '"', fieldKey, '"', ')')
             group_by <- paste0('time(', agg, ')')
             tableName <- "max"
           }
         )
  
  if(is.null(fill) | fill == "NULL" | fill == "null" | fill == "none"){
    fill <- "null"
  }
  
  if(is.null(datetimeStart) && is.null(datetimeEnd)){
    qry <- paste0("SELECT ", field_keys, " * ", valueFactor,
                  " FROM ", '"', measurement,'"',
                  " GROUP BY ", group_by,
                  " Fill(", fill, ")", 
                  " tz(","'",  locTimeZone, "'",")"
    )
  } else if (is.null(datetimeStart)){
    time_end <- as.POSIXct(datetimeEnd, tz = locTimeZone)
    where <- paste0("time <= ","'",
                    as.character(time_end, format = "%Y-%m-%dT%H:%M:%OS.000", tz = "UTC"),"Z'"
    )
    qry <- paste0("SELECT ", field_keys, " * ", valueFactor,
                  " FROM ", '"', measurement,'"',
                  " WHERE ", where,
                  " GROUP BY ", group_by,
                  " Fill(", fill, ")", 
                  " tz(","'",  locTimeZone, "'",")"
    )
  } else if (is.null(datetimeEnd)){
    time_start <- as.POSIXct(datetimeStart, tz = locTimeZone)
    where <- paste0("time >= ","'",
                    as.character(time_start, format = "%Y-%m-%dT%H:%M:%OS.000", tz = "UTC"),"Z'"
    )
    qry <- paste0("SELECT ", field_keys, " * ", valueFactor,
                  " FROM ", '"', measurement,'"',
                  " WHERE ", where,
                  " GROUP BY ", group_by,
                  " Fill(", fill, ")", 
                  " tz(","'",  locTimeZone, "'",")"
    )
  } else {
    time_start <- as.POSIXct(datetimeStart, tz = locTimeZone)
    time_end <- as.POSIXct(datetimeEnd, tz = locTimeZone)
    where <- paste0("time >= ","'",
                    as.character(time_start, format = "%Y-%m-%dT%H:%M:%OS.000", tz = "UTC"),"Z'",
                    " AND time < ","'",
                    as.character(time_end, format = "%Y-%m-%dT%H:%M:%OS.000", tz = "UTC"),"Z'"
    )
    qry <- paste0("SELECT ", field_keys, " * ", valueFactor,
                  " FROM ", '"', measurement,'"',
                  " WHERE ", where,
                  " GROUP BY ", group_by,
                  " Fill(", fill, ")", 
                  " tz(","'",  locTimeZone, "'",")"
    )
  }
  # message(qry)
  data <- as.data.frame(influx_query(con = influxdbCon(host, port, user, pwd), db = database, query = qry, simplifyList = TRUE, return_xts = FALSE))
  
  if(nrow(data) == 1){
    return(NULL)
  } else {
    data <- data %>%  select(time, tableName)
  }

  data$time <- parse_date_time(data$time, "YmdHM0S", tz = "UTC")
  data$time <- with_tz(data$time, locTimeZone)
  data$time <- round_date(data$time, unit = "second")
  rownames(data) <- NULL
  
  data <- data %>% na.omit()
  
  if((aggOld == "1W" | aggOld == "1M" | aggOld == "1Y") & (func != "raw")){

    xts <- xts(data[,-1], order.by = data$time)
    colnames(xts) <- measurement
    
    switch(funcOld,
           diffMax = {
             ## get difference from max values in aggregation range
             data <- as.data.frame(aggregateXts(xts, "max", aggOld, locTimeZone))
             data[[measurement]] <- data[[measurement]] - lag(data[[measurement]])
             data <- data %>% na.omit()
           },
           {
             ## get values in aggregation range according to func argument
             data <- as.data.frame(aggregateXts(xts, func, aggOld, locTimeZone))
           }
    )
    data$time <- row.names(data)
    data$time <- as.Date(data$time)
    
    # rearrange columns
    data <- data %>% select(time, everything())
    
  }
  
  # saveRDS(data, paste0(here::here(), "/app/shiny/temp/temp.rds"))
  # browser()
  if(valueType == "counterVal"){
    data[[2]] <- data[[2]] - lag(data[[2]])
    data <- data %>% na.omit()
    
    if(funcOld != "raw"){
      xts <- xts(data[,-1], order.by = data$time)
      data <- fortify(aggregateXts(xts, funcOld, aggOld, locTimeZone))
      names(data) <- c("time", measurement)
    }

    if((aggOld == "1d" | aggOld == "1W" | aggOld == "1M" | aggOld == "1Y") & (funcOld != "raw")){
      data$time <- parse_date_time(data$time, "Ymd", tz = locTimeZone)
    } else {
      data$time <- parse_date_time(data$time, "Ymd HMS", tz = locTimeZone)
    }
    
    # rearrange columns
    data <- data %>% select(time, everything())
  }
  
  # browser()
  # saveRDS(data, paste0(here::here(), "/app/shiny/temp/temp.rds"))
  
  # delete first row
  if(funcOld == "diffMax"){
    data = data[-1,]
  }
  # delete/reindex
  rownames(data) <- NULL
  
  # rename column names
  names(data) <- c("time", measurement)
  return(data)
}

