rm(list=ls())
Sys.setenv(LC_CTYPE = "en_US.UTF-8")

# demoMode is for publishing on shinyapps.io, application has less functionality
demoMode <- FALSE

# Max. Upload Size for files 30MB (csv files can get really big...)
options(shiny.maxRequestSize=30*1024^2)
# options(shiny.error = browser)
# options(shiny.fullstacktrace = FALSE)

# ======================================================================
# import libraries
library(shiny)
library(shinydashboard)
library(plyr)
library(tidyverse)
# library(ggthemes)
library(here)
library(dygraphs)
library(plotly)
library(r2d3)
library(ggnewscale)
library(DT)
library(httr)
library(jsonlite)
library(lubridate)
# install.packages("devtools")
# library(devtools)
#install_github("hslu-ige-laes/influxdbr")
library(influxdbr)
library(xts)
library(highfrequency)
library(NCmisc)
library(viridisLite)
library(viridis)
library(writexl)
library(markdown)

# libraries for debugging
library(tictoc)
#library(devtools)

# libraries explicitly for date editor
library(shinyjs)
library(data.table)
library(shinyalert)

useShinyalert()

source(here::here("app", "shiny", "R", "fct_etlAggData_server.R"))
source(here::here("app", "shiny", "R", "fct_etlSourceTtn_server.R"))
source(here::here("app", "shiny", "R", "fct_etlSourceInfludxDB_server.R"))
source(here::here("app", "shiny", "R", "fct_etlSourceCsv_server.R"))

source(here::here("app", "shiny", "R", "utils_server.R"))

source(here::here("app", "shiny", "R", "mod_01_roomTempHum.R"))
source(here::here("app", "shiny", "R", "mod_02_roomOutsideTemp.R"))
source(here::here("app", "shiny", "R", "mod_03_roomAirQuality.R"))
source(here::here("app", "shiny", "R", "mod_04_roomTempReduction.R"))

source(here::here("app", "shiny", "R", "mod_10_flatHeating.R"))
source(here::here("app", "shiny", "R", "mod_11_flatHotWater.R"))
source(here::here("app", "shiny", "R", "mod_12_flatVentilation.R"))
source(here::here("app", "shiny", "R", "mod_13_flatElectricity.R"))

source(here::here("app", "shiny", "R", "mod_20_centralHeatingSignature.R"))
source(here::here("app", "shiny", "R", "mod_21_centralHeatingCurve.R"))

source(here::here("app", "shiny", "R", "mod_80_dataexplorer.R"))

source(here::here("app", "shiny", "R", "mod_91_configuration.R"))

source(here::here("app", "shiny", "R", "mod_92_bldgHierarchy.R"))

source(here::here("app", "shiny", "R", "mod_93_dataSources.R"))
source(here::here("app", "shiny", "R", "mod_93_dataSourcesTtn.R"))
source(here::here("app", "shiny", "R", "mod_93_dataSourcesInfluxdbv1x.R"))
source(here::here("app", "shiny", "R", "mod_93_dataSourcesCsv.R"))

source(here::here("app", "shiny", "R", "mod_94_dataPoints.R"))

# ======================================================================
# Load configuration files at startup

configFileApp <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "configApp.csv"), loadConfigFile)
configFileTtn <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "configTtn.csv"), loadDataSourceFile)
configFileInfluxdbv1x <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "configInfluxdbv1x.csv"), loadDataSourceFile)
configFileCsv <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "configCsv.csv"), loadDataSourceFile)

etlAggFilterList <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "etlAggFilterList.csv"), loadDataPointsFile)

bldgHierarchy <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "bldgHierarchy.csv"), loadDataPointsFile)
dataPoints <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "dataPoints.csv"), loadDataPointsFile)

# ======================================================================
# time zone list
# see OlsonNames() for full list and extend timeZoneList acoordingly
timeZoneList <- data.frame("timeZone" = c("UTC","Europe/Zurich"))

# check if RData exists
df.all <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))

if (!file.exists(file = here::here("app", "shiny", "data", "cache","data_15m_max.RData"))) {
  save(df.all, file = here::here("app", "shiny", "data", "cache","data_15m_max.RData"))
}

# data_15m_max <- reactiveFileReader(1000, session =  session, file = file = here::here("app", "shiny", "data", "cache","data_15m_max.RData"), readRData)

if (!file.exists(file = here::here("app", "shiny", "data", "cache","data_1h_mean.RData"))) {
  save(df.all, file = here::here("app", "shiny", "data", "cache","data_1h_mean.RData"))
}

# data_1h_mean <- reactiveFileReader(1000, session =  session, file = file = here::here("app", "shiny", "data", "cache","data_1h_mean.RData"), readRData)

if (!file.exists(file = here::here("app", "shiny", "data", "cache","data_1h_sum.RData"))) {
  # data_1h_sum <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
  save(df.all, file = here::here("app", "shiny", "data", "cache","data_1h_sum.RData"))
}

# data_1h_sum <- reactiveFileReader(1000, session =  session, file = file = here::here("app", "shiny", "data", "cache","data_1h_sum.RData"), readRData)


if (!file.exists(file = here::here("app", "shiny", "data", "cache","data_1d_mean.RData"))) {
  # df.all <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
  save(df.all, file = here::here("app", "shiny", "data", "cache","data_1d_mean.RData"))
}

# data_1d_mean <- reactiveFileReader(1000, session =  session, file = file = here::here("app", "shiny", "data", "cache","data_1d_mean.RData"), readRData)

if (!file.exists(file = here::here("app", "shiny", "data", "cache","data_1d_sum.RData"))) {
  # df.all <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
  save(df.all, file = here::here("app", "shiny", "data", "cache","data_1d_sum.RData"))
}

# data_1d_sum <- reactiveFileReader(1000, session =  session, file = file = here::here("app", "shiny", "data", "cache","data_1d_sum.RData"), readRData)

if (!file.exists(file = here::here("app", "shiny", "data", "cache","data_1M_sum.RData"))) {
  # data_1M_sum <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
  save(df.all, file = here::here("app", "shiny", "data", "cache","data_1M_sum.RData"))
}

# update data at startup
# tic("ttnFetchServerData")
# ttnFetchServerData()
# toc()
# tic("etlAggFilterData")
# etlAggFilterData()
# toc()
