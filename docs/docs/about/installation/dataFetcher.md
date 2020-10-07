---
layout: default
title: Data Fetcher
nav_order: 03
parent: Installation
grand_parent: About lcm
---
# Data Fetcher
{: .no_toc }
- The data from LoRaWAN sensors are transmitted to a server of The Things Network. The data are then stored for a maximum of seven days. Consequently, the lcm application must retrieve and locally store the sensor data at least every seven days
- This is the purpose of the "Data Fetcher". The Data Fetcher script collects all data from configured "the things network applications" and stores them locally as CSV files
- Below, you will find a description of how this process can be initiated automatically on various operating systems

<hr>
### Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

<hr>

## Windows
The following setup procedure relies on the Windows Task Scheduler, which periodically executes a batch file.
To create a task on Windows 10, follow these steps:

1. Open `Start`
1. Search for `Task Scheduler`, and open the corresponding app. The "Task Scheduler" (de: `Aufgabenplanung`) App opens
1. Right-click the `Task Scheduler Library` branch (de: `Aufgabenplanungsbibliothek`), and select the `Create task...` option
1. Fill in the fields in the first tab as follows:<br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_01.PNG" style="border:1px solid lightgrey"/><br><br>
1. In the second tab, create new Triggers as follows:<br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_02.PNG" style="border:1px solid lightgrey"/><br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_03.PNG" style="border:1px solid lightgrey"/><br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_04.PNG" style="border:1px solid lightgrey"/><br><br>
1. In the third tab, create new Actions as follows:<br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_05.PNG" style="border:1px solid lightgrey"/><br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_06.PNG" style="border:1px solid lightgrey"/><br><br>
   Arguments: (change `MyAppPath` accordingly)<br>
   `/c start /min C:\MyAppPath\dataFetcher\lcmDataFetcher.bat ^& exit`<br>
1. In the fourth and fifth tabs, set the checkboxes as follows:<br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_07.PNG" style="border:1px solid lightgrey"/><br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_08.PNG" style="border:1px solid lightgrey"/><br><br>
1. Click OK to save
1. You can right-click the new task and execute it in order to test

<hr>

## MacOSX and Linux
The following setup procedure relies on the cronjob daemon, which periodically executes a R script file.

1. Open `/etc/crontab` in your favorite editor
1. Paste the following entry at the end (change `MyAppPath` accordingly)<br>
   `0 * * * * Rscript /MyAppPath/dataFetcher/lcmDataFetcher.R`
1. Save file and close editor

The above cronjob runs the Data Fetcher script every hour.
