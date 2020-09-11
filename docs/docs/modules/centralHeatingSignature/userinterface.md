---
layout: default
title: User Interface
nav_order: 03
parent: Central > Heating Signature
grand_parent: Modules
---

### Visualization(s)
#### Heating Signature
This visualization allows a quick detection of malfunctions and provides valuable information on the energy efficiency of the building.
- A constant indoor temperature is assumed.
- It is also assumed that the outside temperature is the parameter with the greatest influence on heating energy consumption.
- This method is suitable for buildings with stable internal heat loads and relatively low passive solar heat loads.

<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/centralHeatingSignature_02.PNG" style="border:1px solid lightgrey"/>
<br>
- The x-axis represents the average outdoor temperature.
- The y-axis the daily energy consumption.
- Tooltip: Place the mouse pointer over a datapoint to get more information of a specific measurement.
<br><br>

### Settings
#### Basic

<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/centralHeatingSignature_03.PNG" style="border:1px solid lightgrey" width="180px"/>
<br><br>

**Energy Heat Meter Central**
- Selection of the heat meter.

**Temperature Outside Air**
- Selection of the outside air temperature sensor.

**Time Range**
- The date left is automatically the oldest timestamp and on the right side the newest.
- Narrow the time range to make comparisons.

**Visible Seasons**
- The points are colored according to the season.
- With the checkboxes the measurements of a season can be shown and hidden individually.

#### Extended
- To access the extended settings, the plus symbol in the upper right corner of the title bar must be pressed.
- Per default the extended settings tab is collapsed.
<br><br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/centralHeatingSignature_04.PNG" style="border:1px solid lightgrey" width="90%"/>
<br><br>

**Threshold to exclude low values for regression line**
- Used for the regression line for outlier removal.
