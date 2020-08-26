---
layout: default
title: System Architecture
nav_order: 1
parent: About the app
---

# System Architecture

## Overview
{: .no_toc }
The basic structure follows the [data warehouse principle](https://en.wikipedia.org/wiki/Data_warehouse). Data from multiple sources get collected and saved. Following the ETL principle (Extract, Transform, Load), where "Load" colloquially stands for store.  

[![Application Architecture](https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/docs/systemArchitecture_01.PNG)]()

The time series get saved in a raw format. The only exceptions are influxDB data, where the original raw data does not get saved. To keep things simple and for , all the configurations are saved as csv files.
