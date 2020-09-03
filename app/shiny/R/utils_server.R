season <- function(input.date){
  #' Get season of date
  #'
  #' Get the season of an input date
  #' @param input.date a POSIXct, POSIXlt, Date, chron, yearmon, yearqtr, zoo, zooreg, timeDate, xts, its, ti, jul, timeSeries, or fts object..
  #' @return Returns the corresponding season [Winter, Spring, Summer, Fall].
  #' @export
  #' @examples
  #' x <- as.Date("2019-01-18")
  #' season(x) #"Winter"
  #'
  #' @author Reto Marek
  numeric.date <- 100 * lubridate::month(input.date) + lubridate::day(input.date)
  ## input Seasons upper limits in the form MMDD in the "break =" option:
  cuts <- base::cut(numeric.date, breaks = c(0,0229,0531,0831,1130,1231))
  # rename the resulting groups (could've been done within cut(...levels=) if "Winter" wasn't double
  levels(cuts) <- c("Winter","Spring","Summer","Fall","Winter")
  return(as.character(cuts))
}

aggregateXts <- function(xts, func = "mean", agg = "1d", locTimeZone = "Europe/Zurich") {
  data <- switch(agg,
                 "15m" = {
                   temp <- aggregatets(xts, FUN=func, on="minutes", k=15, dropna=FALSE)
                   tzone(temp) <- locTimeZone
                   return(temp)
                 },
                 "1h" = {
                   temp <- aggregatets(xts, FUN=func, on="hours", k=1, dropna=FALSE)
                   tzone(temp) <- locTimeZone
                   return(temp)
                 },
                 "1d" = {
                   # temp <- xts:::.drop.time(apply.daily(xts, func))
                   temp <- apply.daily(xts, func)
                   index(temp) <- as.POSIXct(trunc(index(temp), units="days"), tz = locTimeZone)
                   temp <- temp[! duplicated( index(temp) ),]
                   return(temp)
                   },
                 "1W" = {
                   temp <- apply.weekly(xts, func)
                   index(temp) <- as.POSIXct(trunc(index(temp), units="days"), tz = locTimeZone)
                   temp <- temp[! duplicated( index(temp) ),]
                   return(temp)
                   },
                 "1M" = {
                   temp <- apply.monthly(xts, func)
                   index(temp) <- as.POSIXct(trunc(index(temp), units="days"), tz = locTimeZone)
                   temp <- temp[! duplicated( index(temp) ),]
                   return(temp)
                 },
                 "1Y" = {
                   temp <- apply.yearly(xts, func)
                   index(temp) <- as.POSIXct(trunc(index(temp), units="days"), tz = locTimeZone)
                   temp <- temp[! duplicated( index(temp) ),]
                   return(temp)
                 }
  )
  return(data)
}

# used to read user defined csv script functions with unknown function names
getFunctionsInFile <- function(filePath){

  is_function <- function (expr) {
    if (! is_assign(expr))
      return(FALSE)
    value = expr[[3]]
    is.call(value) && as.character(value[[1]]) == 'function'
  }
  
  function_name <- function (expr)
    as.character(expr[[2]])
  
  is_assign <- function (expr)
    is.call(expr) && as.character(expr[[1]]) %in% c('=', '<-', 'assign')
  
  
  file_parsed = parse(filePath)
  functions = Filter(is_function, file_parsed)
  function_names = unlist(Map(function_name, functions))
  
  return(function_names)
  
}

# get rooms of specific flat in a data frame
getRoomsOfFlat <- function(selectedFlat){
  rooms <- bldgHierarchy() %>% filter(flat == selectedFlat) %>% select(rooms)
  rooms <- as.data.frame(str_split(rooms, ","))
  names(rooms)[1] <- "rooms"
  
  return(rooms)
}

# configFile <- list(pageTitle = "Low Cost Monitoring", theme = "cerulean", new = "test")
loadDataPointsFile <- function(dataPointsFilePath) {
  #' Load Data Points File
  #'
  #' Load the datapoints csv-file into R list
  #' @param filename a String representing the filename inclusive extension.
  #' @return Returns the configuration in a list.
  #' @export
  #' @examples
  #' loadConfigFile("config.csv")
  #'
  #' @author Reto Marek
  
  dataPoints <- read_delim(file = dataPointsFilePath,
                           delim = ";",
                           col_names = TRUE,
                           col_types = c(
                             abbreviation = col_character(),
                             name = col_character(),
                             flat = col_character(),
                             room = col_character(),
                             dpType = col_character(),
                             sourceName = col_character(),
                             sourceReference = col_character(),
                             unit = col_character(),
                             fieldKey = col_character(),
                             valueFactor = col_double(),
                             valueType = col_character()
                            )
                           )
  
  return(dataPoints)
}

saveDataPointsFile <- function() {
  # write list to datapoints file
  dataPoints <- dataPoints()
  write_csv2(dataPoints, here::here("app", "shiny", "data", "dataPoints.csv"))
}

# configFile <- list(pageTitle = "Low Cost Monitoring", theme = "cerulean", new = "test")
loadConfigFile <- function(configFilePath) {
  #' Load Configuration File
  #'
  #' Load the configuration csv-file into R list
  #' @param filename a String representing the filename inclusive extension.
  #' @return Returns the configuration in a list.
  #' @export
  #' @examples
  #' loadConfigFile("config.csv")
  #'
  #' @author Reto Marek
  
  temp <- read.table(
    file = configFilePath,
    sep = ";"
  )
  configList <- vector(mode = "list", length = 0)
  for (i in 1:ncol(temp)) {
    configList[toString(temp[1,i])] <- toString(temp[2,i])
  }
  return(configList)
}


# key <- "theme"
# value <- "onenote"
saveConfigFile <- function(configFilePath, key, value) {
  # write list to config file
  # print("saveConfigFile() called")
  # print(key)
  # print(value)
  configFile <- loadConfigFile(configFilePath)
  # print(configFile)
  configFile[key] <- value
  write.table(
    as.data.frame(configFile),
    file = configFilePath,
    quote = FALSE,
    sep = ";",
    row.names = FALSE
  )
}

loadDataSourceFile <- function(configFilePath) {
  df <- read.csv2(configFilePath)
  df <- data.frame(lapply(df, as.character), stringsAsFactors = FALSE)
  return(df)
}

