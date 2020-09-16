---
layout: default
title: App Configuration
nav_order: 01
parent: Settings
---

## App Configuration
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/settingsAppConfiguration_01.PNG" style="border:1px solid lightgrey"/><br>
- **Hint:** Do not forget to save new settings by pressing the button `Save settings to configApp.csv`

### Title on top left
- This is the title that is displayed on top of the running application
- This can for instance be used in order to declare the name of the current building, project or your company name

### Building Type
- Select the type of the building to be monitored
- This setting affect the consumption calculation from e.g. the module [Flat > Electricity](https://hslu-ige-laes.github.io/lcm/docs/modules/flatElectricity/userinterface/)

### Building Altitude
- Set the altitude of the building, in meters above sea level
- This setting affects the mollier h,x-chart in the module [Room > Temp vs. Hum](https://hslu-ige-laes.github.io/lcm/docs/modules/roomTempHum/userinterface/)

### Time Zone
- Set the time zone of the building.
- If your current time zone is not listed, please add it manually to the variable `timeZoneList` in the file `/app/shiny/global.R`
