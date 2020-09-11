---
layout: default
title: Data Analysis
nav_order: 02
parent: Central > Heating Curve
grand_parent: Modules
---

### Data Aquisition
- Temperature outside air and supply heat in °C
- Heating energy consumption in kWh
- hourly values required

### Calculations
- hourly mean value for supply temperature heat
- rolling maximum of the last 6 hours (configurable)  for the supply temperature heat
- rolling mean average of the last 48 hours (configurable) for the outdoor temperature
- merging the two values by date and hour
- keep only pairs where both values are available
- calculate season out of date (for later filtering)