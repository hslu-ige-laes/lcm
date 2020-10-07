---
layout: default
title: Configuration
nav_order: 2
parent: Français
grand_parent: Quick Start Guide
has_toc: false
---

# Configuration
## Étape 1: Configuration de l'application
1. Naviguez vers `Settings > App Configuration` dans la barre latérale pour configurer les paramètres de l'application
1. Choisissez le type de bâtiment `Building Type` approprié et réglez l'altitude du bâtiment `Building altitude`
1. Cliquez sur `Save settings in configApp.csv` pour enregistrer les paramètres

Le résultat devrait ressembler à ceci:<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/quickStartGuide_03.PNG" style="border:1px solid lightgrey"/>


## Étape 2: Définir la hiérarchie des bâtiments
Dans l'application lcm, les bâtiments sont définis de manière hiérarchique. Par exemple:
- Un capteur de température ambiante appartient à une chambre
- Une chambre appartient à un appartement donné
- Etc.

**Exemple:** Définir un appartement simple avec plusieurs chambres.

1. Naviguez vers `Settings > Building Hierarchy` dans la barre latérale pour ajuster la hiérarchie des bâtiments
1. Cliquez sur `Add new` pour ajouter un nouvel élément à la hiérarchie
1. Remplissez le formulaire comme suit:<br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/settingsBldgHierarchy_01.PNG" style="border:1px solid lightgrey"/>
1. Cliquez sur `Add new flat`  pour ajouter le nouvel appartement

Le résultat devrait ressembler à ceci:<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/quickStartGuide_04.PNG" style="border:1px solid lightgrey"/>

Appuyez sur "Suivant" pour savoir comment ajouter une source de données.

[Suivant](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/fr/addDataSource/){: .btn .btn-green }

