---
layout: default
title: About the app
nav_order: 6
has_children: true
permalink: /docs/about
---

# About the application
## Background <sub><a href="#balmer2020">[1]</a></sub>
The construction of energy-efficient buildings is now state of the art in Switzerland. However, when in operation they often do not achieve the planned values. This is partly due to user behavior, which is difficult to plan. On the other hand, it is due to the fact that the technical systems in buildings are not operated optimally. As a result, even new buildings constructed according to energy labels often require significantly more energy than necessary. This is also true to an even greater extent for existing buildings. And this is the real problem if we want to achieve the goals of energy and climate policy. Around three-quarters of buildings in Switzerland were built before 1990 and in most cases do not meet today's energy requirements. There is a huge potential for efficiency gains here.
Exploiting this potential is the goal of energy-related operational optimization. Experience shows that this can save between 10 and 15 percent of energy. In practice, this is often more for owner-occupied properties and less for properties used by third parties. Of course, energy-related operational optimizations alone do not save the climate, but they do make a tangible contribution to it and, in addition, relieve the users and/or owners of unnecessary costs.

<hr>

## Why not using an available cloud service/dashboard
- As of today, the market does not offer an affordable application for residential construction. 
- Today's IoT applications are subject to licensing and focus on the presentation of time series in standard plots.
- More complicated data analyses and visualizations are rarely supported.
- Many people today still want to store as little data as possible on the internet and are not happy with a fully centralized solution.

<hr>

## Used software
- The app is built as a [Shiny](https://shiny.rstudio.com/) web application which is based on the [programming language R](https://en.wikipedia.org/wiki/R_(programming_language)).
- R and its web application extension [Shiny](https://shiny.rstudio.com/) are a good solution to build prototypes of web apps which require data analysis and visualization functionality.
- No programming skills are required to install and use the application.
- If you want to extend or adapt the application a basic knowledge of R, [RStudio](https://rstudio.com/products/rstudio/) and the graph library [ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html) and [ploty](https://plotly.com/r/) are required.
- The nice thing with R Shiny application is, that everything is open source and no further knowledge of HTML, CSS or JavaScript is required to build small and minimal apps.

### Getting started with R, RStudio and Shiny
- [RStudio Education](https://education.rstudio.com/learn/beginner/) serves as good starting point for beginners in R and RStudio. 
- If you are only new to Shiny we suggest the free <a href="https://mastering-shiny.org/" target="_blank">"Mastering Shiny book"</a>

<hr>
### References 
<a id="balmer2020">[1]</a> Balmer, M., Hubbuch, M., & Sandmeier, E. (2020). Energetische Betriebsoptimierung: Gebäude effizienter betreiben (1. Auflage). Fachbuchreihe «Nachhaltiges Bauen und Erneuern». FAKTOR Verlag AG. [https://pubdb.bfe.admin.ch/de/publication/download/10042](https://pubdb.bfe.admin.ch/de/publication/download/10042)<br>
	
