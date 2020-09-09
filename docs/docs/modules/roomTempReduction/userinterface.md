---
layout: default
title: User Interface
nav_order: 03
parent: Room > Temp Reduction
grand_parent: Modules
---

### Visualization(s)
#### Temperature Flats with Average, Setpoint and resulting Difference
A simple overview of the time series data per room.
<br><br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/roomTempReduction_01.PNG" style="border:1px solid lightgrey" width = "90%"/>
<br>
- The orange solid line represents the room temperature setpoint which can be changed in the extended settings (see below)
- The red dashed line represents the average value of the room. It takes the season- and time range selection into account.
- Tooltip: Place the mouse pointer over a datapoint to get more information of a specific measurement.

#### Boxplot
A standard Boxplot to get a compact overview of all flats/rooms.
<br><br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/roomTempReduction_02.PNG" style="border:1px solid lightgrey"/>
<br>
- The orange solid line represents the room temperature setpoint which can be changed in the extended settings (see below)
- The red dashed line represents the average value of the room. It takes the season- and time range selection into account.
- Tooltip: Place the mouse pointer over a datapoint to get more information of a specific measurement.

### Settings
#### Basic

<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/roomTempReduction_03.PNG" style="border:1px solid lightgrey" width="180px"/>
<br><br>

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
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/roomTempReduction_04.PNG" style="border:1px solid lightgrey" width="90%"/>
<br><br>

**Temperature Setpoint**
- Changes will move the horizontal lines in the plots around and trigger a new calculation of the temperature differences.

<hr>

### References
none