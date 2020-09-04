---
layout: default
title: Data Analysis
nav_order: 02
parent: Flat > Electricity
grand_parent: Modules
---

### Data Aquisition
- Electric consumption in kWh
- hourly values required, 15min values desirable

### Calculations
- hourly sum of electric consumption (15min could be done as well, calculation will take longer )
- remove negative, invalid values
- remove upper outliers
  - Assumption max. fuse 40 ampere (average in single family houses <a href="#da_16AGebaeude">[2]</a>)
  - this results in continuous power 9.2 kW
  - over 24h = approx. 221 kWh max. consumption per day
  - Everything above is very unlikely...
- calculate season out of date (for later filtering)
- calculate sum per day
- calculate minimum per day (standby-losses)
- calculate rolling averages for usage
- calculate rolling minimum for standby-losses
- calculate standby-share value with total energy consumtion and standby-average of the rolling minimum
- calculate typical houshold consumption for comparison. Formulas and values from <a href="#da_nipkov">[1]</a>

<hr>

### References
<a id="da_nipkov">[1]</a> Nipkov, J. (2013). Typischer Haushalt-Stromverbrauch. Schlussbericht. Bundesamt für Energie (BFE). [https://www.aramis.admin.ch/Default.aspx?DocumentID=61764](https://www.aramis.admin.ch/Default.aspx?DocumentID=61764)<br>
<a id="da_16AGebaeude">[2]</a> Sattler, M. et al. (2020). 16 A-Gebäude: Stromnetzstabilisierung und Nutzerbeeinflussung durch elektrische Leistungsbegrenzung für Gebäude. Bundesamt für Energie (BFE). https://www.aramis.admin.ch/Texte/?ProjectID=40160 