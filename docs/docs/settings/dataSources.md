---
layout: default
title: Data Sources
nav_order: 03
parent: Settings
---

# Data Sources
{: .no_toc }
Supported data sources are: CSV files, LoRaWAN sensors over "The Things Network" and influxDB connections.

<hr>
### Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

<hr>

## csv Files
### Generalities
- Time series data can get imported from CSV files
- The data should have the following structure:
  ```javascript
  time,value1,value2
  2020-07-30 13:00:00,53,10.5
  ```
- The file can include one or multiple value columns
- Data can be separated by comma, semicolons or tabulators
- In case of a special file format, you can write an own `Parsing script`. Details see [csv scripts](https://hslu-ige-laes.github.io/lcm/docs/about/fileStructure/#csvscripts)

### Add new
1. In the lcm application under `Settings > Data Sources > csv Files`, click the button `Add new`
1. Fill in the form as follows:
   - **SourceName**<br>
     Name for the data source in the application. Can be defined freely
   - **Parsing Script**<br>
     Select a special parsing script if required. If you are unsure, select `none`
   - **Choose CSV file**<br>
     Navigate to the CSV file you want to import
   - **Separator and Quote**<br>
     Depends on the file
   - **Time Zone Source Data**<br>
     Select the time zone in which the data in the CSV file got monitored. If your time zone is not listed, please add it manually to the variable `timeZoneList` in the file `/app/shiny/global.R`
     The import procedure changes the time into the time zone of the application in `Settings > App Configuration > Time Zone`
   - **Time Column**<br>
     The recognized columns are listed. In case the column with the timestamp is not named `time`, the correct column can get selected as follows:
1. At the bottom, you can see the data preview window
1. Click `Add new data source` if everything looks fine
1. Now the CSV file and its datapoints are selectable in `Settings > Data Points > Add new` under `Data Source` resp. `Data Point`

<hr>

## the things network (TTN) applications
### Generalities
- [The Things Network](https://de.wikipedia.org/wiki/The_Things_Network) is a community based initiative to create a [LoRaWAN network](https://de.wikipedia.org/wiki/Long_Range_Wide_Area_Network){:target="_blank"}
- You can buy a LoRaWAN device and connect it to the network, free without charges or fees
- LoRaWAN devices are able to send messages over a distance of about 10 kilometres wirelessly to a network gateway, where the data gets forwarded via internet to a TTN server
- The link between the device and the TTN server is secured using an AES-128-End-to-End-Encryption

### Add new
1. Create a TTN application, add devices and configure them according to the separate [lora-devices-ttn documentation](https://hslu-ige-laes.github.io/lora-devices-ttn/){:target="_blank"}.
   There you can find as well an overview of recommended devices
1. Then click in the lcm application under `Settings > Data Sources > the things network` the button `Add new`
1. Fill the fields as follows:
   - **SourceName**<br>
     Name for the application which you can define freely
   - **Application ID**<br>
     You can copy/paste this ID from your TTN application overview
   - **Access Key**<br>
     You can copy/paste this key from your TTN application overview (at the bottom of the page, starts with `ttn-account-v...`)
   - **Fetching Enabled**<br>
     This setting defines whether the data get automatically imported by the [lcm Data Fetcher](https://hslu-ige-laes.github.io/lcm/docs/installation/dataFetcher/). If you want to disable one application, you can deselect the checkbox
1. Press `Test settings and preview data`
   - now you should get an overview of the data in the TTN storage
1. Finally press `Add new data source`
1. Now the TTN application and its device datapoints are selectable in `Settings > Data Points > Add new` under `Data Source` resp. `Data Point`

### TTN data storage information
- Normally the things network (TTN) forwards only telegrams and does not store time series data
- But TTN offers a free database solution which stores all data for seven days
- The lcm application takes advantage of this possibility and uses an API to retrieve this data
- The retrieved data gets stored in CSV files which you can find in the folder `/app/shiny/data/ttn/yourTtnAppName/yourTtnDeviceName_yourTtnDatapointName.csv`
- In the [lora-devices-ttn documentation](https://hslu-ige-laes.github.io/lora-devices-ttn/){:target="_blank"} it is described how to add this integration to your application
- The measurements in the storage get saved with a UTC timestamp
- If necessary (depending on `Settings > App Configuration > Time Zone`) a time zone change is made during the import into the lcm application


### No TTN coverage at the buildings location
- Don't panic, you can install and setup an own gateway within a few minutes. It's easy and will cost you less than 100 Swiss Francs (September 2020) for the hardware
  - an affordable [indoor LoRaWAN Gateway from ttn](https://ch.rs-online.com/web/p/entwicklungstools-kommunikation-und-drahtlos/1843981/){:target="_blank"}
  - and the corresponding [installation description](https://www.thethingsnetwork.org/docs/gateways/thethingsindoor/#activate-your-gateway-in-under-5-min){:target="_blank"}
- You only need to have a WLAN internet connection in the building and a 5V USB power supply

<hr>

## influxDB integration
### Generalities
- An [influxDB](https://en.wikipedia.org/wiki/InfluxDB){:target="_blank"} is a specialized database for time series
- Data can get injected from external systems and read easily from the lcm application
- An already existing ifnluxDB instance is prerequisite. Database installation and data injection is not described in detail here
- This integration is only implemented for users with influxDB knowledge
- The lcm application assumes that stored data of influxDB is in UTC time zone
- During import the lcm application changes the time zone to the configured one of `Settings > App Configuration > Time Zone`


### Add new
1. Click in the lcm application under `Settings > Data Sources > influxDB` the button `Add new`
1. Fill the fields as follows:
   - **SourceName**<br>
     Name for the data source in the application which you can define freely
   - **InfluxDB Host Address**<br>
     IP address of the influxDB instance
   - **Port**<br>
     influxDB's port, per default 8086
   - **Username and Password**<br>
     optional, depending on influxDB settings
1. Click the button `Query databases` to get an overview of the configured databases in the influxDB instance
1. Select the desired database with the pull down menu
1. Click the button `Test settings and preview data` to get an overview of the available measurements of the selected database
1. Click `Add new data source` if everything looks fine
1. Now the influx database and its measurements are selectable in `Settings > Data Points > Add new` under `Data Source` resp. `Data Point`

