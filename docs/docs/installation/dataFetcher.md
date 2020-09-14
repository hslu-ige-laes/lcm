---
layout: default
title: Data fetcher
nav_order: 04
parent: Installation
---
# Data fetcher
{: .no_toc }
- The measured values of LoRaWAN sensors are sent via antennas to a server of the things network. There the data is stored for a maximum of seven days. Consequently, the lcm application must retrieve and locally store the measured values at least every seven days.
- This is what the "Data Fetcher" is doing. The script fetches all data from the configured "the things network applications" and saves them locally in csv files.
- Below is a description of how this process can be initiated automatically on various operating systems.

{:toc}

<hr>

## Windows
The following setup procedure uses the Windows Task Scheduler, which periodically executes a batch file.
To create a task on Windows 10, use these steps:

1. Open `Start`
1. Search for `Task Scheduler`, and click the top result. The "Task Scheduler" (de: `Aufgabenplanung`) opens.
1. Right-click the `Task Scheduler Library` branch (de: `Aufgabenplanungsbibliothek`), and select the `Create task...` option.
1. Fill the fields in the first tab as follows<br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_01.PNG" style="border:1px solid lightgrey"/><br><br>
1. In the second tab create new Triggers as follows<br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_02.PNG" style="border:1px solid lightgrey"/><br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_03.PNG" style="border:1px solid lightgrey"/><br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_04.PNG" style="border:1px solid lightgrey"/><br><br>
1. In the third tab create new Actions as follows<br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_05.PNG" style="border:1px solid lightgrey"/><br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_06.PNG" style="border:1px solid lightgrey"/><br><br>
   Arguments: (change `MyAppPath` accordingly)<br>
   `/c start /min C:\MyAppPath\dataFetcher\lcmDataFetcher.bat ^& exit`<br>
1. In the fouth and fifth tab set the checkboxes as follows<br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_07.PNG" style="border:1px solid lightgrey"/><br><br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/installationDataFetcher_08.PNG" style="border:1px solid lightgrey"/><br><br>
1. Click OK to save
1. You can right click the created task and execute it as test


## MacOSX and Linux
The following setup procedure uses the cronjob daemon, which periodically executes a R script file.

1. open `/etc/crontab` in your favorite editor
1. paste the following entry at the end (change `MyAppPath` accordingly)<br>
   `0 * * * * Rscript /MyAppPath/dataFetcher/lcmDataFetcher.R`
1. save file and close editor

This cronjob executes the file every hour.