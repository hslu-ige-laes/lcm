---
layout: default
title: Data fetcher
nav_order: 04
parent: Installation
---
# Data fetcher
The measured values of LoRaWAN sensors are sent via antennas to a server of the things network. There the data is stored for a maximum of seven days. Consequently, the lcm application must retrieve and locally store the measured values at least every seven days.

This is what the "Data Fetcher" is for. The script fetches all data from the configured the things network applications and saves them locally in csv files.

Below is a description of how this process can be initiated automatically on various operating systems.

## Windows
The following setup procedure enables the windows task scheduler triggers the batch file periodically.

## MacOSX and Linux
tbd: describe how to set up cronejob

