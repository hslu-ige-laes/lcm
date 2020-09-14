---
layout: default
title: Data fetcher
nav_order: 04
parent: Installation
---
# Data fetcher
- The measured values of LoRaWAN sensors are sent via antennas to a server of the things network. There the data is stored for a maximum of seven days. Consequently, the lcm application must retrieve and locally store the measured values at least every seven days.
- This is what the "Data Fetcher" is doing. The script fetches all data from the configured "the things network applications" and saves them locally in csv files.
- Below is a description of how this process can be initiated automatically on various operating systems.

## Windows
The following setup procedure uses the Windows Task Scheduler, which periodically executes a batch file.
1. 


## MacOSX and Linux
The following setup procedure uses the cronjob daemon, which periodically executes a batch file.

1. open `/etc/crontab` in your favorite editor
1. paste the following entry at the end (change `MyAppPath` accordingly)<br>
   `0 * * * * Rscript /MyAppPath/dataFetcher/lcmDataFetcher.R`
1. save file and close editor
