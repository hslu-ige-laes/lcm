---
layout: default
title: Configuration
nav_order: 2
parent: English
grand_parent: Quick Start Guide
has_toc: false
---

# Configuration
## Step 1: Application configuration
1. Navigate to `Settings > App Configuration` in the sidebar
1. Choose the appropriate `Building Type` and set the `Building altitude`
1. Click `Save settings in configApp.csv`

The result should look like this:<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/quickStartGuide_03.PNG" style="border:1px solid lightgrey"/>


## Step 2: Define building hierarchy
In the lcm application, buildings are defined hierarchically. For instance:
- A room temperature sensor belongs to a given room
- A room belongs to a given flat
- Etc.

**Example:** Define a single flat with multiple rooms.

1. Navigate to `Settings > Building Hierarchy` in the sidebar
1. Click `Add new`
1. Fill in the form as follows:<br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/settingsBldgHierarchy_01.PNG" style="border:1px solid lightgrey"/>
1. Click `Add new flat`

The result should look like this:<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/quickStartGuide_04.PNG" style="border:1px solid lightgrey"/>

Press "Next" in order to learn how to add a data source.

[Next](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/en/addDataSource/){: .btn .btn-green }
