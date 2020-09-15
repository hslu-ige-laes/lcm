---
layout: default
title: Data Points
nav_order: 04
parent: Settings
---

# Data Points
A datapoint tells the lcm application
- from wich Data Source the time series is coming
- which type of sensor they represent
- and where they are located in the building

With this information the modules filter and preprocess the time series.

<hr>

## Add new
1. Click in the lcm application under `Settings > Data Points` the button `Add new`
1. Fill the fields as follows:
   - **Abbreviation**<br>
     Name for the data point in the application which you can define freely.
   - **Name**<br>
     Description of the data point which you can define freely.
     It appears in diagram headers of the modules.
   - **Datapoint Type**<br>
     Choose the appropriate type.
     The different modules of the lcm application look at this information and filter the data accordingly.
   - **Unit**<br>
     Used for some diagram axis descriptions
   - **Locality**<br>
     The configured flat(s) from `Settings > Building Hierarchy` appear here as well as "Building" which is always present and foreseen for central devices like a central heating meter.
   - **Room**<br>
     The presented list depends on the drop down "Locality" and shows the rooms which got configured in `Settings > Building Hierarchy`.
   - **Data Source**<br>
     The configured sources from `Settings > Data Sources` appear.
   - **Data Point**<br>
     The presented list depends on the drop down "Data Source" and shows all measurements of the selected source.
   - **Field Key (InfluxDB only)**<br>
     Get's automatically selected. If there are multiple Field Keys available you can select one.
   - **Factor**<br>
     During data import all measured values get multiplicated with this factor.
   - **Value Type**<br>
     absolute Value: sensors which measure an absolute values
	 Counter Reading: values normally from meters which represent an increasing counter value
1. Click `Test settings and preview data` and if everything looks fine `Add new data point`