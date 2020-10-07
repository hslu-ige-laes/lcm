---
layout: default
title: Konfiguration
nav_order: 2
parent: Deutsch
grand_parent: Quick Start Guide
has_toc: false
---

# Konfiguration
## Schritt 1: Anwendungskonfiguration
1. Navigieren Sie in der Seitenleiste zu den Applikaitions-Einstellungen `Settings > App Configuration`
1. Wählen Sie den entsprechenden "Gebäudetyp" (Einfamilienhaus oder Mehrfamilienhaus) aus und stellen Sie die "Gebäudehöhe" ein
1. Klicken Sie auf den Speichern-Knopf `Save settings in configApp.csv`

Das Ergebnis sollte wie folgt aussehen:<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/quickStartGuide_03.PNG" style="border:1px solid lightgrey"/>


## Schritt 2: Definieren Sie die Gebäudehierarchie
In der lcm-Anwendung werden Gebäude hierarchisch definiert. Zum Beispiel:
- gehört eine Raumtemperaturfühler zu einem bestimmten Raum
- gehört ein Raum zu einer bestimmten Wohnung
- usw.

**Beispiel:** Definieren Sie eine einzelne Wohnung mit mehreren Räumen.

1. Navigieren Sie in der Seitenleiste zu den Gebäudehierarchie-Einstellungen `Settings > Building Hierarchy`
1. Klicken Sie auf `Add new` um einen neuen Eintrag zu erstellen
1. Füllen Sie das Formular wie folgt aus:<br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/settingsBldgHierarchy_01.PNG" style="border:1px solid lightgrey"/>
1. Klicken Sie auf `Add new flat` um die Wohnung der Hierarchie hinzuzufügen

Das Ergebnis sollte wie folgt aussehen:<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/quickStartGuide_04.PNG" style="border:1px solid lightgrey"/>

Drücken Sie "Weiter" um zu erfahren, wie Sie eine Datenquelle hinzufügen können.

[Weiter](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/de/addDataSource/){: .btn .btn-green }
