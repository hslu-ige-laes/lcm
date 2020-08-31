---
layout: default
title: Interpretation
nav_order: 04
parent: Room > Room vs. Outside Temp
grand_parent: Modules
---

### General 
- For the user of the rooms, the effectively expected room temperatures are decisive, assuming that the rooms are used as realistically as possible.
- If the temperature is above the maximum line, this is called an overheating hour.
- Note that the standard <a href="#sia180">[1]</a> refers to the "perceived temperature", which is an average between the measured room temperature and the measured temperature of the wall surfaces. So a simplification is made by showing only the measurement of the room air temperature.

### Rooms with natural ventilation, while they are neither heated nor cooled <sub><a href="#enbau">[2]</a></sub>
- For rooms with pure window ventilation, the upper maximum limit curve according to SIA 180:2014 <a href="#sia180">[1, p. 24-25]</a> applies.
- This curve is not limited upwards, which means that for high outside temperatures, correspondingly high room temperatures are also permissible.
  For a hot summer, such as in 2015, this means that during 7 to 10 days a maximum room temperature of more than 30°C is still "standard-compliant" and thus permissible.
- Experience shows, however, that such high room temperatures are not appreciated and hardly accepted by the users.
  It is therefore recommended to use the limit curve for mechanically ventilated and cooled rooms when assessing summer room temperatures.

### Heated, cooled and/or mechanically ventilated rooms <sub><a href="#enbau">[2]</a></sub>
- For heated, cooled and/or mechanically ventilated rooms the lower maximum limit curve is defined in standard SIA 180:2014 <a href="#sia180">[1, p. 24-25]</a>.
- In contrast to the limit curve for rooms with pure window ventilation, temperatures may be exceeded here.
- According to standard SIA 382/1:2014 <a href="#sia382">[3]</a>, the following three ranges are distinguished:
  - No hours above the limit value<br>
    -> Cooling not necessary
  - 0 to 100 hours overrun (*)<br>
    -> cooling desired
  - More than 100 hours overrun (*)<br>
    -> cooling necessary

  (*) For residential buildings the limit is 400 hours.

### Sensor placement
The placement of sensors is crucial. If the sensor is incorrectly positioned and is occasionally illuminated by direct sunlight, this is clearly visible in the measured values:
<br><br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/roomOutsideTemp_05.PNG" style="border:1px solid lightgrey" width="90%"/>
<br>

- In summer with high outside temperatures the values are in the comfort range (shading elements are lowered and prevent direct irradiation)
- On the other hand, there are outliers in winter which do not come from the heating system.

**Mounting guidelines for sensors for measuring room temperature, relative humidity and air quality** <a href="#sensorplacement">[4]</a>
- Mount sensors in rooms at a height of approx. 1.5 m and at least 50 cm away from the nearest wall or door
- Do not expose to direct sunlight
- Do not mount on outside walls
- Do not place in niches and shelves
- Avoid proximity of air currents and heat sources
- Do not cover by curtains


<hr>

### References
<a id="sia180">[1]</a> SIA Schweizerischer Ingenieur- und Architektenverein (2014). Wärmeschutz, Feuchteschutz und Raumklima in Gebäuden. (SN/EN, SIA 180). <br>
<a id="enbau">[2]</a> [https://enbau-online.ch/bautechnik-der-gebaeudehuelle/2-3%E2%80%82waermeschutz-im-sommer/](https://enbau-online.ch/bautechnik-der-gebaeudehuelle/2-3%E2%80%82waermeschutz-im-sommer/) <br>
<a id="sia382">[3]</a> SIA Schweizerischer Ingenieur- und Architektenverein (2014). Lüftungs- und Klimaanlagen - Allgemeine Grundlagen und Anforderungen. (SN, SIA 382/1). <br>
<a id="sensorplacement">[4]</a> Siemens Schweiz AG. (2018). Montagerichtlinien für Sensoren. [https://www.siemens.com/download?A6V11420159 ](https://www.siemens.com/download?A6V11420159)<br>

