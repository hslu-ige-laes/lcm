---
layout: default
title: Room > Temp vs. Hum
nav_order: 01
parent: Module Descriptions
---

### Background
- The comparison of the room temperature with the humidity at the same time allows a comfort evaluation.
- In order to enable a quick visual evaluation, zones where people feel comfortable are color-coded.

### Visualizations
#### Room Temperature versus relative Humidity
Such visualizations have existed for more than 45 years and were shown e.g. by Frank (1975) <a href="#frank1975">[1]</a> in a report.
<br><br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/roomTempHum_02.PNG" style="border:1px solid lightgrey"/>
<br>

- Tooltip: Place the mouse pointer over a datapoint to get more information of a specific measurement.

#### Mollier hx-Diagram
The Mollier h,x-diagram was proposed by Richard Mollier in 1923 <a href="#mollierhxand">[2]</a> allows to describe changes of state of humid air. In the present case it is used to show comfort states regarding temperature and humidity.
This visualisation is written in D3 and open-source <a href="#mollierhxand">[3]</a> 
<br><br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/roomTempHum_01.PNG" style="border:1px solid lightgrey"/>
<br>
- It is valid for a certain air pressure. The lcm application calculates the air pressure from the building altitude (meters above sea level) which you can change in the settings `Settings > App Configuration`.
- The basic scale for the h,x-diagram is a temperature scale, which is applied vertically as y-axis.
- The auxiliary lines drawn horizontally from left to right are the "isotherms", i.e. lines with constant air temperature. While the isotherm at 0 °C runs parallel to the horizontal axis, the isotherms at higher temperatures will increasingly rise to the right, due to the heat content of the increasing water content.
- The x-axis represents the water content x resp. the absolute humidity of the air.
- The comfort zone helps to indicate whether measured temperature/humidity values are within a comfortable range or not.
- Measured values get integrated as scatter plot and are coloured according to the season (winter, spring, summer, fall).
- Using the building altitude, temperature and relative humidity the application calculates the absolute water content.
- A dot stands for a daily averaged state.

### Settings
- To access the settings, the plus symbol in the upper right corner of the title bar must be pressed.
- Per default the settings tab is collapsed.

<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/roomTempHum_03.PNG" style="border:1px solid lightgrey"/>
<br>

#### Time Range
- The date left is automatically the oldest timestamp and on the right side the newest.
- Narrow the time range to make comparisons.

#### Visible Seasons
- The points are colored according to the season.
- With the checkboxes the measurements of a season can be shown and hidden individually.

#### "Mollier hx"-Diagram Properties
- The three sliders in the upper line change the comfort zone.
- The two sliders in the lower line change the ranges of the x- and y-axis

### References
<a id="frank1975">[1] </a>Frank, W. (1975). Raumklima und thermische Behaglichkeit: Literaturauswertung, durchgeführt im Auftr. d. Bundesmin. f. Raumordnung, Bauwesen u. Städtebau. Berichte aus der Bauforschung: H. 104. 
<a id="mollierhx">[2] </a> Mollier-h-x-Diagramm (n.d.). In Wikipedia. Retrieved August 28, 2020, from [https://de.wikipedia.org/wiki/Mollier-h-x-Diagramm](https://de.wikipedia.org/wiki/Mollier-h-x-Diagramm)
<a id="d3-mollierhx">[3] </a>d3-mollierhx (n.d.). In Github. Retrieved August 28, 2020, from [https://github.com/hslu-ige-laes/d3-mollierhx](https://github.com/hslu-ige-laes/d3-mollierhx)

