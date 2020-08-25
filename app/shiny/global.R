rm(list=ls())
Sys.setenv(LC_CTYPE = "en_US.UTF-8")
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
library(influxdbr)
library(xts)
library(highfrequency)
library(NCmisc)
library(viridisLite)
library(viridis)
library(streamgraph)
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

source(here::here("app", "shiny", "R", "mod_01_temperatureReduction.R"))
source(here::here("app", "shiny", "R", "mod_02_comfortTempHum.R"))
source(here::here("app", "shiny", "R", "mod_50_comfortTempROa.R"))
source(here::here("app", "shiny", "R", "mod_03_comfortAQual.R"))

source(here::here("app", "shiny", "R", "mod_04_ventilationFlats.R"))

source(here::here("app", "shiny", "R", "mod_05_hotWaterFlats.R"))

source(here::here("app", "shiny", "R", "mod_06_heatingFlats.R"))
source(here::here("app", "shiny", "R", "mod_07_heatingCentral.R"))
source(here::here("app", "shiny", "R", "mod_08_heatingCurve.R"))

source(here::here("app", "shiny", "R", "mod_80_dataexplorer.R"))

source(here::here("app", "shiny", "R", "mod_91_configuration.R"))

source(here::here("app", "shiny", "R", "mod_92_bldgHierarchy.R"))

source(here::here("app", "shiny", "R", "mod_93_dataSources.R"))
source(here::here("app", "shiny", "R", "mod_93_dataSourcesTtn.R"))
source(here::here("app", "shiny", "R", "mod_93_dataSourcesInfluxdb.R"))
source(here::here("app", "shiny", "R", "mod_93_dataSourcesCsv.R"))

source(here::here("app", "shiny", "R", "mod_94_dataPoints.R"))

# ======================================================================
# Load configuration files at startup

configFileApp <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "configApp.csv"), loadConfigFile)
configFileTtn <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "configTtn.csv"), loadDataSourceFile)
configFileInfluxdb <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "configInfluxdb.csv"), loadDataSourceFile)
configFileCsv <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "configCsv.csv"), loadDataSourceFile)

etlAggFilterList <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "etlAggFilterList.csv"), loadDataPointsFile)

bldgHierarchy <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "bldgHierarchy.csv"), loadDataPointsFile)
dataPoints <- reactiveFileReader(1000, NULL, here::here("app", "shiny", "config", "dataPoints.csv"), loadDataPointsFile)

# ======================================================================
# time zone list
# see OlsonNames() for full list and extend timeZoneList acoordingly
timeZoneList <- data.frame("timeZone" = c("UTC","Europe/Zurich"))

# check if rds exists
if (!file.exists(here::here("app", "shiny", "data", "cache","data_15m_max.rds"))) {
  df <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
  saveRDS(df, here::here("app", "shiny", "data", "cache","data_15m_max.rds"))
}

data_15m_max <- reactiveFileReader(1000, session =  session, file = here::here("app", "shiny", "data", "cache","data_15m_max.rds"), readRDS)

if (!file.exists(here::here("app", "shiny", "data", "cache","data_1h_mean.rds"))) {
  df <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
  saveRDS(df, here::here("app", "shiny", "data", "cache","data_1h_mean.rds"))
}

data_1h_mean <- reactiveFileReader(1000, session =  session, file = here::here("app", "shiny", "data", "cache","data_1h_mean.rds"), readRDS)

if (!file.exists(here::here("app", "shiny", "data", "cache","data_1d_mean.rds"))) {
  df <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
  saveRDS(df, here::here("app", "shiny", "data", "cache","data_1d_mean.rds"))
}

data_1d_mean <- reactiveFileReader(1000, session =  session, file = here::here("app", "shiny", "data", "cache","data_1d_mean.rds"), readRDS)

if (!file.exists(here::here("app", "shiny", "data", "cache","data_1d_sum.rds"))) {
  df <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
  saveRDS(df, here::here("app", "shiny", "data", "cache","data_1d_diffMax.rds"))
}

data_1d_sum <- reactiveFileReader(1000, session =  session, file = here::here("app", "shiny", "data", "cache","data_1d_sum.rds"), readRDS)

if (!file.exists(here::here("app", "shiny", "data", "cache","data_1M_sum.rds"))) {
  df <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), c("time", "value", "abbreviation", "flat", "room", "dpType"))
  saveRDS(df, here::here("app", "shiny", "data", "cache","data_1M_sum.rds"))
}

data_1M_sum <- reactiveFileReader(1000, session =  session, file = here::here("app", "shiny", "data", "cache","data_1M_sum.rds"), readRDS)

# update data at startup
# tic("ttnFetchServerData")
# ttnFetchServerData()
# toc()
# tic("etlAggFilterData")
# etlAggFilterData()
# toc()
