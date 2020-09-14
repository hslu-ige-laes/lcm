---
layout: default
title: Data Sources
nav_order: 03
parent: Settings
---
# Data Sources
{: .no_toc }
Supported data sources are csv files, LoRaWAN sensors over "the things network" and influxDB.

<hr>
### Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

<hr>

## csv Files
### When do I use this import process?
- tbd

### How can I add a new csv file?
1. tbd
1. Now the csv file and its datapoints are selectable in `Settings > Data Points > Add new` under `Data Source` resp. `Data Point`

## the things network (ttn)
### What is the things network
- tbd

### How can I integrate ttn data into the lcm application?
1. Create a ttn application, add devices and configure them according to the [lora-devices-ttn documentation](https://hslu-ige-laes.github.io/lora-devices-ttn/). There you can find as well an overview of recommended devices.
1. Then click in the lcm application under `Settings > Data Sources > the things network` the button `Add new`
1. Fill the fields as follows:
   - SourceName: Name for the application which you can define freely.
   - Application ID: You can copy/paste this ID from your ttn application settings
   - Access Key: You can copy/paste this key from your ttn application settings
   - Fetching Enabled: This setting defines wheter the data get automatically fetched by the lcm application. If you want to disable one application, you can deselect the checkbox.
1. Press `Tets settings and preview data`
   - now you should get an overview of the data in the ttn storage
1. Finally press `Add new data source`
1. Now the ttn application and its device datapoints are selectable in `Settings > Data Points > Add new` under `Data Source` resp. `Data Point`

### Background info about the data storage
- Normally the things network (ttn) forwards only telegrams and does not store time series data.
- But ttn offers a free database solution which stores all data for seven days.
- The lcm applicaiton takes advantage of this possibility and uses an API to retrieve this data.
- The retrieved data gets stored in csv files which you can find in the folder `/app/shiny/data/ttn/yourTtnAppName/yourTtnDeviceName_yourTtnDatapointName.csv`
- In the [lora-devices-ttn documentation](https://hslu-ige-laes.github.io/lora-devices-ttn/) it is described how to add this integration to your application.

### Help, no ttn coverage at the buildings location!
- tbd

## influxDB
### What is influxDB
- tbd

### How can I integrate influxDB into the lcm application?
1. tbd
1. Now the influx database and its measurements are selectable in `Settings > Data Points > Add new` under `Data Source` resp. `Data Point`


