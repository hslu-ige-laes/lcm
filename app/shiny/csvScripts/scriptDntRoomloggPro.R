
# Conversion script for DNT Roomlog Pro Datalogger csv Export file

# Source data format
#
# Time,Temperature(C),Humidity(%),Dewpoint(C),HeatIndex(C)
# 2020/01/27 20:37,24.2,45,11.5,24.2
# 2020/01/27 20:38,24.3,45,11.6,24.3
# 2020/01/27 20:39,24.4,44,11.4,24.4
# 2020/01/27 20:40,24.4,44,11.4,24.4
#
# Reasons for script:
# - The file has per default a ANSI encoding and not UTF-8
# - Date conversion required, default does not recognize proper format
#
# uncomment only while developing the script
# filePath <- here::here("app", "shiny", "data", "csv", "2020CH1A.CSV")
# sourceTimeZone <- "Europe/Zurich"
# 
# scriptRelayW60Logger(filePath, sourceTimeZone)

scriptDntRoomloggPro <- function(filePath = NULL) {
  
  if(is.null(filePath)){
    return(NULL)
  }
  
  df <- read.delim(filePath, sep = ",", dec = ".", stringsAsFactors=FALSE)
  names(df)[1] <- "time"
  names(df)[2] <- "Temp"
  names(df)[3] <- "Hum"

  df$time <- parse_date_time(df$time, "Y-m-d H:M", tz = "Europe/Zurich")

  df$Temp <- as.numeric(df$Temp)
  df$Hum <- as.numeric(df$Hum)
  
    
  df <- df %>% select(time, Temp, Hum)
  
  return(df)
}
