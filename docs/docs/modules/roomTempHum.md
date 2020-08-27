---
layout: default
title: Room > Temp vs. Hum
nav_order: 1
parent: Module Descriptions
---

### Purpose

## Visualizations
#### Room Temperature versus relative Humidity
<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/roomTempHum_02.PNG" style="border:1px solid lightgrey"/>
<br>

### Mollier hx-Diagram
The Mollier h,x-diagram was proposed by Richard Mollier in 1923 and allows to describe changes of state of humid air. In the present case it is used to show comfort states regarding temperature and humidity.
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

Source: [https://github.com/hslu-ige-laes/d3-mollierhx](https://github.com/hslu-ige-laes/d3-mollierhx)

## Settings
<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/roomTempHum_03.PNG" style="border:1px solid lightgrey"/>
<br>