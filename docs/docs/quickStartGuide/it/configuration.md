---
layout: default
title: Configurazione
nav_order: 2
parent: Italiano
grand_parent: Quick Start Guide
has_toc: false
---

# Configurazione
## Passo 1: Configurazione dell'applicazione
1. nella barra laterale, passare alle impostazioni dell'applicazione `Settings > App Configuration`
1. selezionare il "tipo di edificio" appropriato (casa unifamiliare o condominio) e impostare l'altezza dell'edificio
1. cliccare sul pulsante di salvataggio `Save settings in configApp.csv`

Il risultato dovrebbe essere così:<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/quickStartGuide_03.PNG" style="border:1px solid lightgrey"/>


## Passo 2: Definire la gerarchia dell'edificio
Nella lcm-applicazione gli edifici sono definiti gerarchicamente. Per esempio:
- un sensore di temperatura ambiente appartiene ad una certa stanza
- una stanza appartiene ad un certo appartamento
- e così via

**Esempio:** Definire un singolo appartamento con più stanze.

1. navigare nella barra laterale fino alle impostazioni della gerarchia degli edifici `Settings > Building Hierarchy`
1. cliccare su `Add new` per creare una nuova voce
1. compilare il modulo nel modo seguente:<br>
   <img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/settingsBldgHierarchy_01.PNG" style="border:1px solid lightgrey"/>
1. cliccare su `Add new flat` per aggiungere l'appartamento alla gerarchia

Il risultato dovrebbe essere così:<br>
<img src="https://raw.githubusercontent.com/hslu-ige-laes/lcm/master/docs/assets/images/quickStartGuide_04.PNG" style="border:1px solid lightgrey"/>

Cliccate su "Continua" per imparare ad aggiungere una fonte di dati.

[Continua](https://hslu-ige-laes.github.io/lcm/docs/quickStartGuide/it/addDataSource/){: .btn .btn-green }
