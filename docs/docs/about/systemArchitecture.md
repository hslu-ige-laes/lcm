---
layout: default
title: System Architecture
nav_order: 1
parent: About the app
---

# System Architecture
## Overview
<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/systemArchitecture_01.PNG" alt="Application architecture" style="border:1px solid lightgrey" onclick="window.open('https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/systemArchitecture_01.PNG', '_blank');" />
<br>
- The architecture follows the [data warehouse](https://en.wikipedia.org/wiki/Data_warehouse)- and [ETL principle](https://en.wikipedia.org/wiki/Extract,_transform,_load) (Extract, Transform, Load), where "Load" colloquially stands for store.
- Time series data from multiple [Data Sources](https://hslu-ige-laes.github.io/lcm/docs/settings/dataSources/) get collected and saved in a raw format (the only exceptions are influxDB data, where the original raw data does not get saved).
- To keep things simple, all the configurations and time series data are saved as csv files.
- An aggregation and filter process then collects the required datapoints according to the app configuration and saves again the preprocessed data.
- The [Shiny application](https://hslu-ige-laes.github.io/lcm/docs/about#used-software) consists of different [modules](https://hslu-ige-laes.github.io/lcm/docs/modules) which then access, analyzes and visualizes these processed data.

