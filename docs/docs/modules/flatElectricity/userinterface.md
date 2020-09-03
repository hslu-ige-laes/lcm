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
- A horizontal line with a left aligned annotation shows a typical houshold for comparison. Calculated with extended settings (described below). Formulas and values from <a href="#ui_nipkov">[1]</a>
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
- To access the extended settings, the plus symbol in the upper right corner of the title bar must be pressed.
- Per default the extended settings tab is collapsed.
- All the settings below are used to calculate the "typical household" consumption.
- Please note that you only have to select devices that are really connected to the corresponding electric meter.

<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/flatElectricity_04.PNG" style="border:1px solid lightgrey" width="90%"/>
<br><br>

- Depending on the setting and `Settings > App Configuration > Building Type` the typical consumption changes.
- For detailed values, bachground information and formulas see  <a href="#nipkov">[1]</a>
- Adaptions of the extended settings does not (yet) get changed.

**Occupants**
- Default value comes from `Settings > Building Hierarchy > occupants`
- The persons should be present at least on working days, i.e. at least in the evening and usually for 2 meals.
- Children up to approx. 10 years are to be counted as approx. "½ person".
- Teenagers from about 11 years on are to be counted as adults.

**Rooms**
- If the effective room number deviates significantly, i.e. by more than 1, from a "typical room number", the typical energy consumption is adjusted accordingly.

**Dishwasher**
- none: no dishwaser powered with this meter
- classic: dishwaser available, no further classification
- with hot water supply: electrical dishwasher which uses as well hot water to heat up

**Freezer**
- none: no "big" freezer powered with this meter. The one in the refrigerator does not count.
- classic: additional freezer available, no further classification

**Cooking & Baking**
- If cooking and baking is particularly intensive and often, and little hot food is eaten outdoors, this increases the base value by 50 per person.
- Conversely, if the stove and oven are used less intensively and food is eaten outdoors frequently, this reduces the base value by 50 per person.

**Efficient Lighting**
- The mix values apply to a share of efficient lamps of about 40 to 50% (energy saving lamps, LED, fluorescent tubes).
- Attention: Halogen or "Eco-Halogen" lamps are not efficient!
- Majority means more than 80%, minority less than 20%

**Clothes Dryer**
- none: no dryer powered with this meter
- room air dryer: room air dehumidifier in the drying room
- heat pumpt dryer: dryer with integrated heat pump, uses less energy than classic one!
- classic dryer: classical one which is only connected to the electric power

**Washing Machine**
- none: no washing machine powered with this meter
- classic: washing machine available, no further classification
- with hot water supply: electrical washing machine which uses as well hot water to heat up

**Water Heater**
- none: no water heater powered with this meter
- Electric Boiler: separate electric boiler powered with this meter
- Heat Pump: only for single family houses when the water heater is connected to the meter

**Common electricity (building equipment, common lighting)**
- included: e.g. for single family houses with main meter
- excluded:  e.g. for multi family houses where the meter of the flat gets analyzed. Normally the coomon electricity is measured by a separate meter.

<hr>

### References
<a id="ui_nipkov">[1]</a> Nipkov, J. (2013). Typischer Haushalt-Stromverbrauch. Schlussbericht. Bundesamt für Energie (BFE). [https://www.aramis.admin.ch/Default.aspx?DocumentID=61764](https://www.aramis.admin.ch/Default.aspx?DocumentID=61764)<br>
