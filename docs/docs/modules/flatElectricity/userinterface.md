---
layout: default
title: Userinterface
nav_order: 03
parent: Flat > Electricity
grand_parent: Modules
---

### Visualization(s)
#### Daily Electric Energy Consumption and Standby Power

A simple overview of the time series data per room.
<br><br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/flatElectricity_01.PNG" style="border:1px solid lightgrey" width = "90%"/>
<br>
- The chart is splitted in two subplots:
  - upper plot with daily energy consumption in kWh/day
  - lower plot with standby-losses in Watts
- The points represent a rolling mean value of the last seven days
- The solid dashed lines represent the total mean value of the visible points. On the right are two text annotations with the values of these two lines. 
- Tooltip: Place the mouse pointer over a datapoint to get more information of a specific measurement.
<br><br>

### Settings
#### Basic

<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/flatElectricity_03.PNG" style="border:1px solid lightgrey" width="180px"/>
<br><br>

**Flat and Room**
- Selection of flat resp. room which should get analyzed.
- According to the building hierarchy all flats and rooms get listet which have a datapoint of type "tempRoom" or "humRoom".

**Time Range**
- The date left is automatically the oldest timestamp and on the right side the newest.
- Narrow the time range to make comparisons.

**Visible Seasons**
- The points are colored according to the season.
- With the checkboxes the measurements of a season can be shown and hidden individually.

#### Extended

<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/flatElectricity_04.PNG" style="border:1px solid lightgrey" width="90%"/>
<br><br>
