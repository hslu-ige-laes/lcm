---
layout: default
title: Home
nav_order: 1
description: "Low Cost Monitoring - Documentation"
permalink: /
---

# lcm - Low-Cost Monitoring
## Getting started
- [Live Demo](https://hslu-ige-laes.shinyapps.io/lowcostmonitoring/)
- Quick Start Guide<br>
  [English](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/en/){: .btn .btn-green }  [Deutsch](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/de/){: .btn .btn-green }  [Français](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/fr/){: .btn .btn-green }  [Italiano](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/it/){: .btn .btn-green }

<hr>

## Overview
<img src="https://github.com/hslu-ige-laes/lcm/raw/master/docs/assets/images/lcm.png" width="100" align="right" class="inline"/>

- "lcm" is an open source monitoring application for residential buildings
- The focus of the application is on providing energy savings whilst maintaining the expected comfort
- The application fetches, stores, analyzes and displays data from various sources
- Supported data sources include LoRaWAN sensors, influxDB and CSV files
- The lcm monitoring solution is cost-effective and "do it yourself"

<img src="https://github.com/hslu-ige-laes/lcm/raw/master/docs/assets/images/home_Demo.gif" width="100%" style="border:1px solid lightgrey"/>

<hr>

## Dashboard Layout
<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/aboutDashboardLayout_01.png" alt="Application architecture" style="border:1px solid lightgrey" onclick="window.open('https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/aboutDashboardLayout_01.png', '_blank');" />
<br>
- In the left sidebar you can select the different [Modules](https://hslu-ige-laes.github.io/lcm/docs/modules).<br>
  They appear according to the configured [Data Points](https://hslu-ige-laes.github.io/lcm/docs/settings/dataPoints/)
- The Data Explorer allows an exploration of the configured data points and includes as well an export function
- [Settings](https://hslu-ige-laes.github.io/lcm/docs/settings) indludes the
  - [App Configuration](https://hslu-ige-laes.github.io/lcm/docs/settings/appConfiguration/)
  - [Building Hierarchy](https://hslu-ige-laes.github.io/lcm/docs/settings/bldgHierarchy/)
  - [Data Sources](https://hslu-ige-laes.github.io/lcm/docs/settings/dataSources/)
  - [Data Points](https://hslu-ige-laes.github.io/lcm/docs/settings/dataPoints/)
- Depending on the selected [Module](https://hslu-ige-laes.github.io/lcm/docs/modules), the content of the main window will change.<br>
  It includes a
  - filter pane with the most used options
  - an extended properties part which can get accessed by clicking the plus symbol on the top right sidebar
  - the main window with the visualization(s)
  - bottom part with different tabs which includes background information about the module

<hr>

**Disclaimer**<br>
This is a prototype. The authors decline any liability or responsibility in connection with the lcm application.

&copy; Lucerne University of Sciences and Arts, 2020