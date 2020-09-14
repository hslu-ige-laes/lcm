---
layout: default
title: App Configuration
nav_order: 01
parent: Settings
---

## App Configuration
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/settingsAppConfiguration_01.PNG" style="border:1px solid lightgrey"/><br><br>

### Title on top left
- You can choose whatever you want. For example your comanys name or the name of the project/building.

### Building Type
- Choose what type of building you monitor
- The settings affect the consumption calculation from e.g. the module [Flat > Electricity](https://hslu-ige-laes.github.io/lcm/docs/modules/flatElectricity/userinterface/)

### Building Altitude
- Set the altitude in meters above sea level
- The altitude affects the mollier hx chart in the module [Room > Temp vs. Hum](https://hslu-ige-laes.github.io/lcm/docs/modules/roomTempHum/userinterface/)

### Time Zone
- Set the "Time Zone" of the building.
- If your time zone is not listed, please add it manually to the variable `timeZoneList` in the file `/app/shiny/global.R`
