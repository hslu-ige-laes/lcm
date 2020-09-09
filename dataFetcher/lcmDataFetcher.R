
# Sys.setenv(LC_CTYPE = "en_US.UTF-8")

library(here)
library(httr)
library(jsonlite)
library(lubridate)
library(tictoc)
library(readr)
library(plyr)
library(tidyverse)
library(influxdbr)
library(xts)
library(highfrequency)
library(NCmisc)
library(shiny)

source(here::here("app", "shiny", "R", "fct_etlSourceTtn_server.R"))
source(here::here("app", "shiny", "R", "fct_etlSourceInfludxDB_server.R"))
source(here::here("app", "shiny", "R", "fct_etlSourceCsv_server.R"))

source(here::here("app", "shiny", "R", "fct_etlAggData_server.R"))

source(here::here("app", "shiny", "R", "utils_server.R"))

options(readr.num_columns = 0)

# ======================================================================
# get newest ttn data from server
# ======================================================================

print("=== START DATA FETCHING === ")
tic("ttnFetchServerData")
ttnFetchServerData()
toc()

# ======================================================================
# Aggregator and Cache Creator
# ======================================================================

tic("etlAggFilterData")
etlAggFilterData()
toc()
print("=== END DATA FETCHING === ")