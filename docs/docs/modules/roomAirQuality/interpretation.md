---
layout: default
title: Interpretation
nav_order: 04
parent: Room > Air Quality
grand_parent: Modules
---

### General <a href="#nachhaltigebueros">[2]</a>
Today, CO<sub>2</sub> is one of the most important indicators for evaluating the air quality in office and residential buildings.
Since humans produce CO<sub>2</sub> by breathing and release it into the air, the CO<sub>2</sub> content in occupied, unventilated rooms increases rapidly.
With increasing CO<sub>2</sub> concentration, room users experience odorous complaints and, with significantly increased CO<sub>2</sub> concentration, even health problems (concentration disorders, headaches, dizziness, etc.). 

### Thresholds
- In Switzerland, the Swiss Accident Insurance Institution is generally responsible for health-related limit values at the workplace <a href="#suva">[1]</a>. 
- The SUVA publishes an annual report entitled “Occupational Exposure Limits”, which also includes the maximum workplace concentration values (MAK values).
- These are limit values that are intended to ensure health protection but NOT comfort:
  While the SUVA sets 5'000 ppm (parts per million) as MAK value for carbon dioxide,
  the guideline to the regulation 3 of the labor law states:
  “Good indoor air is given if the total concentration of 1'000 ppm CO<sub>2</sub> is not exceeded over the period of use of the room.
- In standard SIA 382/1 <a href="#sia382">[3, Table 8]</a>, the Swiss Association of Engineers and Architects specifies a classification of indoor air quality. Residential and office spaces fall into category 3, for which CO<sub>2</sub> levels between 1'000 and 1'400 ppm are prescribed.
- The Swiss Air and Water Hygiene Association recommends values between 800 - 1'200 ppm for a good indoor climate, with the optimum at 1'000 ppm and a maximum value of 1'400 ppm <a href="#svlw">[4]</a>. These values are the default in the application.

### CO<sub>2</sub> Sensor self calibration
- Most CO<sub>2</sub> sensors have a self-correcting ABC (Automatic Baseline Correction) algorithm.
- It is assumed that the sensor reaches the fresh air value of approx. 400 ppm CO<sub>2</sub> at least once in x days (sensor specific) by window- or mechanical ventilation.
- This algorithm constantly tracks the lowest measured value of the sensor over the last x days and slowly corrects the unavoidable long-term drift.

<hr>

### References
<a id="suva">[1]</a> [SUVA: Grenzwerte am Arbeitsplatz](https://www.suva.ch/de-CH/material/Richtlinien-Gesetzestexte/grenzwerte-am-arbeitsplatz-aktuelle-werte#gnw-location=%2F) <br>
<a id="nachhaltigebueros">[2]</a> [http://www.nachhaltigebueros.ch/node/119](http://www.nachhaltigebueros.ch/node/119)
<a id="sia382">[3]</a>SIA Schweizerischer Ingenieur- und Architektenverein (2014). Lüftungs- und Klimaanlagen - Allgemeine Grundlagen und Anforderungen. (SN, SIA 382/1).
<a id="svlw">[4]</a> Schweizerischer Verein Luft- und Wasserhygiene (2019). Messgerate_fur_Raumluft.pdf - Das ist gutes Raumklima. Retrieved August 31, 2020, from [https://www.svlw.ch/](https://www.svlw.ch/component/easyfolderlistingpro/?view=download&format=raw&data=eNpFT0FOwzAQ_Eq1H4idiAKbK0e4UKkcrYVsUqtOGtnrUgnxG37Cx7DjRJzsmdmZnSXUGr8C7hH6i-vYQxtQXCdkRxo4VM4Ke5JYeI0QA_syGRYKQW3SEDnIf8o9gjELl9FDsU40coYKIT_7wtoOWouqmDy7meSU5eYOoaqV2h2Oz2-7p8s5jjwJV3WjzAuHMLD__RFe83vreMuvG4R1goRNH715pTi62C9tksq37Td3_dqXb7P1HLYyOrUkEfo45bXQvi_sY3J4vlr-LHemGyYSe017v_9cMIbbbCg,)<br>
