---
layout: default
title: Building Hierarchy
nav_order: 02
parent: Settings
---

## Building Hierarchy
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/settingsBldgHierarchy_02.PNG" style="border:1px solid lightgrey"/><br>
- You can run multiple lcm applications on one computer. Each application has its own folder.
- In one application you can have either a single familiy house with one flat or a multi family house with multiple flats.
- The application works with hierarchical elements:
  - for example a room temperature sensor belongs to a specific room and
  - a room belongs to a flat

## Table content
### flat
- name for the flat
- appears e.g. on the charts and in the pull down menues

### size
- size of the flat in square meters
- it is used for specific consumptions e.g. in the module [Flat > Heating](https://hslu-ige-laes.github.io/lcm/docs/modules/flatHeating)

### occupants
- amount of occupants per flat
- it is used for specific consumptions e.g. in the module [Flat > Hot Water](https://hslu-ige-laes.github.io/lcm/docs/modules/flatHotWater)
- Recommendations for dealing with children
  - The persons should be present at least on working days, i.e. at least in the evening.
  - Children up to approx. 10 years are to be counted as approx. “½ person”.
  - Teenagers from about 11 years on are to be counted as adults.

### rooms
- used to assign data points to
- "Central" will always be available, even if none gets configured

## Examples
### single family house
- In case of a single family house, the level "flat" is in fact superfluous.
- Therefore the structure is quite simple.
- In the case of a single-family house, several rooms may be monitored.

| flat | size | occupants | rooms |
|:-|:-:|:-:|:-|
| My Home | 150 | 4 | Dormitory,Living Room,Shower,Bathroom,Kid,Kitchen |

### multi family house
- In case of a multi-family house, often not all rooms are monitored.
- Normally, room temperature and humidity are measured in the corridor and, if necessary, CO2 in the bedroom.
- Other sensors can usually be assigned to the "Central" level of the flat which is always available (you don't have to configure it).  

| flat | size | occupants | rooms |
|:-|:-:|:-:|:-|
| Flat A | 120 | 3 | Dormitory,Corridor |
| Flat B | 85 | 2 | Dormitory,Corridor |
| Flat C | 150 | 4 | Dormitory,Corridor |