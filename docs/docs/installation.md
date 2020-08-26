---
layout: default
title: Installation
nav_order: 3
has_children: false
permalink: /docs/installation
---

# Installation
## Prerequisites
- To run the application an installed R environment is required.
- R Studio (a graphical user interface for R) is recommended.
- Therefore you can run "lcm" on windows, linux and OSX operating systems where R is installed.
- Both R and RStudio are free and easy to download, see instructions below.
- For windows operating systems we have packed an "R Portable" solution where no installation of R is required to run the application.
- The application is tested with R version 3.6.3.

### R Portable for Windows
"R Portable" configures R to work with the PortableApps framework, so R can be run without installing R and without leaving artifacts on the computer.
To use it, simply download the "lcm" application as described below and execute `lcm.bat`.

### Install R
If "R Portable" is not suitable for you, R and R Studio can be installed as follows.

R is maintained by an international team of developers who make the language available through the web page of [The Comprehensive R Archive Network](http://cran.r-project.org/).
The top of the web page provides three links for downloading R. Follow the link that describes your operating system: Windows, Mac, or Linux.

#### Windows
1. <a href="https://cran.r-project.org/bin/windows/base/old/3.6.3/R-3.6.3-win.exe" download>Click to download R version 3.6.3</a>
1. The link downloads an installer program.
1. Run this program and step through the installation wizard that appears.
1. The wizard will install R into your program files folders and place a shortcut in your Start menu. Note that you’ll need to have all of the appropriate administration privileges to install new software on your machine.

#### Mac OSX
1. <a href="https://cran.r-project.org/bin/macosx/R-4.0.2.pkg" download>Click to download R version 3.6.3</a>
1. The link downloads an installer program.
1. Run this program and step through the installation wizard that appears.
1. The installer lets you customize your installation, but the defaults will be suitable for most users.

#### Linux
- R comes preinstalled on many Linux systems.
- The CRAN website provides files to build R from source on Debian, Redhat, SUSE, and Ubuntu systems under the link “Download R for Linux.”
- Click the [link](https://cran.r-project.org/bin/linux/) and then follow the directory trail to the version of Linux you wish to install on.
- The exact installation procedure will vary depending on the Linux system you use. CRAN guides the process by grouping each set of source files with documentation or README files that explain how to install on your system.
- Make shure to get the version 3.6.3

## Download lcm application
1. <a href="https://downgit.github.io/#/home?url=https://github.com/hslu-ige-laes/lcm" download>Click to download lcm application</a>
1. Extract the content to a folder of your choice

## Start lcm application
### via "R Portable"
- Execute `lcm.bat` in the application folder.
- A browser will open
- To stop the application simply close the browser window

### via "R Studio"
1. Open the R Studio Project by clicking `lcm.Rproj`
1. Either run `runApp("./app/shiny/")` in the console or open the file `/app/shiny/server.R` in the files tab and click the green arrow "> Run App".

