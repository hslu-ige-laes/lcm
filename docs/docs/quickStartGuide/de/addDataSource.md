---
layout: default
title: Datenquelle hinzufügen
nav_order: 3
parent: Deutsch
grand_parent: Quick Start Guide
has_toc: false
---

# Datenquelle hinzufügen
- In diesem Beispiel fügen wir eine CSV-Datei hinzu, die von einem Datenlogger stammt
- Die Beispieldatei enthält Temperatur- und Feuchtigkeitsmessungen aus einem Raum
- Später können Sie Ihre eigenen CSV-Dateien sowie andere Datenquellen, z.B. LoRaWAN-Sensoren oder InfluxDB-Datenbanken, importieren

1. Navigieren Sie in der Seitenleiste zu den Einstellungen der Datenquelle `Settings > Data Sources`
1. Klicken Sie auf `Add new` um eine neue Quelle hinzuzufügen
1. Setzen Sie einen benutzerdefinierten Quellennamen `source Name`, wie z.B. `flatTempHum`
1. Wählen Sie über den Knopf `Browse...` die Beispieldatendatei `flatTempHum.csv` aus. Diese Datei befindet sich in Ihrem Anwendungsordner im Unterordner `/sampleData`<br><br>
   Ihr Fenster sollte wie folgt aussehen:<br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/quickStartGuide_05.PNG" style="border:1px solid lightgrey"/><br>
1. Klicken Sie auf `Add new data source` um die neue Datenquelle hinzufügen

Die neue CSV-Datenquelle erscheint jetzt in der Quellentabelle:
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/quickStartGuide_06.PNG" style="border:1px solid lightgrey"/>

Klicken Sie auf "Weiter", um zu erfahren, wie Sie einzelne Datenpunkte hinzufügen können.

[Weiter](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/de/addDataPoints/){: .btn .btn-green }
