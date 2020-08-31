---
layout: default
title: Data Analysis
nav_order: 02
parent: Room > Room vs. Outside Temp
grand_parent: Modules
---

### Data Aquisition
- Temperatured in °C
- hourly values required

### Calculations
- hourly mean value for indoor room temperature
- rolling mean average of the last 48 hours for the outdoor temperature
- merging the two values by date and hour
- keep only pairs where both values are available
- calculate season out of date (for later filtering)
