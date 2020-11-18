
# Conversion script for Relay W60 M-Bus Datalogger csv Export file

# Source data format
#
# Index   Datum  Zeit  Adr ID.Nr. HST  Nr.                Wert  Einheit          Beschreibung     Art  Modul SP.Nr. Tarif
# 2461 01.12.19 00:00   4 920721 GWF   1                 45911     kWh                 energy instant.     0      0     0
# 2462 01.12.19 00:00   4 920721 GWF   2              11786.84     m^3                 volume instant.     0      0     0
# 2463 01.12.19 00:00   4 920721 GWF   3              11099.37     m^3                 volume instant.     1      0     0
# 2464 01.12.19 00:00   4 920721 GWF   4                    40      °C       flow temperature instant.     0      0     0
# 2465 01.12.19 00:00   4 920721 GWF   5                    35      °C     return temperature instant.     0      0     0
# 2466 01.12.19 00:00   4 920721 GWF   6                   4.1       K temperature difference instant.     0      0     0
# 2467 01.12.19 00:00   4 920721 GWF   7                 87283   hours                on time instant.     0      0     0
# 2468 01.12.19 00:00   4 920721 GWF   8                 87277   hours         operating time instant.     0      0     0
# 2469 01.12.19 00:00   4 920721 GWF   9                   124     l/h            volume flow instant.     0      0     0
# 2470 01.12.19 00:00   4 920721 GWF  10                  0.53      kW                  power instant.     0      0     0
# 2471 01.12.19 00:00   4 920721 GWF  11 01.12.19 04:57 Win  V                     time point instant.     0      0     0
# 2472 01.12.19 00:00   4 920721 GWF  12                 53431     HCA               HCA-Unit instant.     1      0     0
# 2473 01.12.19 00:00   4 920721 GWF  13                     0     HCA               HCA-Unit instant.     2      0     0
# 2474 01.12.19 00:00   4 920721 GWF  14                 45472     kWh                 energy instant.     0      1     0
# 2475 01.12.19 00:00   4 920721 GWF  15              11716.89     m^3                 volume instant.     0      1     0
# 2476 01.12.19 00:00   4 920721 GWF  16              11033.62     m^3                 volume instant.     1      1     0
# 2477 01.12.19 00:00   4 920721 GWF  17                 51683     HCA               HCA-Unit instant.     1      1     0
# 2478 01.12.19 00:00   4 920721 GWF  18                     0     HCA               HCA-Unit instant.     2      1     0
# 2479 01.12.19 00:00   4 920721 GWF  19              01.07.19                     time point instant.     0      1     0
# 2480 01.12.19 00:00   4 920721 GWF  20                   $00                    M-Bus state             NA     NA    NA
#
# Notes:
# - The Date and Time are in separate columns. The script therefore combine these two values
# - The HCA-Unit has a factor of 10, so the above HCA-value of 53431 are in 10 liters Units and result in 53431 * 10 = 534310 liter
# - In the example "Adr" is the number of the flat
# - Description of Nr. :
#     1   Heating meter energy since commissioning
#     2   Heating meter volume flow since commissioning
#     3   Heating meter volume flow (in case of a failure this value does not get increased)
#     4   Heating meter supply temperature
#     5   Heating meter return temperature
#     6   Heating meter temperature difference
#     7   Heating meter operating hours since commissioning
#     8   Heating meter operating hours since commissioning (in case of a failure this value does not get increased)
#     9   Heating meter average volume flow
#    10   Heating meter current power
#    11   timestamp of reading values Nr. 1...12
#    12   Additional meter 1 impulse count (for flow meters normally 1 impulse per 10 ltrs)
#    13   Additional meter 2 impulse count (for flow meters normally 1 impulse per 10 ltrs)
#    14   Heating meter energy value at date of programmed reading, see Nr. 19
#    15   Heating meter volume flow value at date of programmed reading, see Nr. 19
#    16   Heating meter volume flow value at date of programmed reading, see Nr. 19 (in case of a failure this value does not get increased)
#    17   Additional meter 1 impulse count at date of programmed reading, see Nr. 19
#    18   Additional meter 2 impulse count at date of programmed reading, see Nr. 19
#    19   Date of the programmed planned reading
#    20   M-Bus State

# uncomment only while developing the script
# filePath <- here::here("app", "shiny", "data", "csv", "GWF_KWH4.csv")
# sourceTimeZone <- "Europe/Zurich"
# 
# scriptRelayW60Logger(filePath, sourceTimeZone)

scriptRelayW60Logger <- function(filePath = NULL) {
  
  if(is.null(filePath)){
    return(NULL)
  }
  
  df.long <- read.csv(filePath, stringsAsFactors=FALSE)
  
  # create timestamp out of column "Date" and "Time"
  df.long <- mutate(df.long, time = paste0(df.long$Datum, " ", df.long$Zeit))
  df.long$time <- parse_date_time(df.long$time, "d.m.y H:M", tz = "Europe/Zurich")

  # select columns and rearrange
  df.long <- df.long %>% select(time, Adr, Nr., Wert, Einheit)

  # filter out Adr. of interest
  # df.long <- filter(df.long, Adr %in% c(1:6))
  
  # filter out Nr. of interest
  df.long <- filter(df.long, Nr. %in% c(1,12))
  
  # rename columns
  df.long <- df.long %>% mutate(Nr. = ifelse(Nr. == 1, paste0("Adr",sprintf("%02.0f", Adr), "_energyHeat"), ifelse(Nr. == 12, paste0("Adr",sprintf("%02.0f", Adr), "_hotWater"), Nr.)))
  
  # convert value to numeric
  df.long$Wert <- as.numeric(df.long$Wert)
  
  # multiply HCA-values by factor 10 to get liters and divide by 1000 to get m3
  df.long <- df.long %>% mutate(Wert = ifelse((Einheit == "HCA"), Wert * 10/1000, Wert))
  
  df.long <- df.long %>% select(-Einheit, -Adr)
  
  # convert long table into wide table
  df.wide <- as.data.frame(pivot_wider(df.long,
                         names_from = "Nr.",
                         values_from = Wert,
                         names_sep = "_"
                         )
  )

  return(df.wide)
}
