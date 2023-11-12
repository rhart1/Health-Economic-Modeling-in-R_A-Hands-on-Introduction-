# Docker container 

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/rhart1/Health-Economic-Modeling-in-R_A-Hands-on-Introduction-/docker?urlpath=rstudio)

This repository contains the set up to create a Rstudio environment with all the relevant packages and programmes installed.

This is useful to work on the practicals. You may want to also install the full configuration on your local machine, but this is useful if you have troubles with some aspects of the installation (eg you didn't have permission to install some packages...).

To run the docker container simply click on the button above (labelled as "launch binder"). This will take you to another URL. The first time you run the container, it may be a bit slow (because it will be compiling the virtual machine), but soon enough you will see Rstudio appearing. You can then work as if you were on your local machine!

## BCEA-web
You can also use `BCEA-web` to check how things work. Go to its [website](https://egon.stats.ucl.ac.uk/projects/BCEAweb/) to load it up.

The default tab gives you some description of what it can do. Move to the next tab `1. Parameter simulations`. From there:

1. Click on the first slider `1. Import parameter simulations data from`, select `Spreadsheet` and then upload the file [`model-parameter-simulations.csv`](https://github.com/rhart1/Health-Economic-Modeling-in-R_A-Hands-on-Introduction-/blob/docker/model-parameters-simulations.csv), which you can download from this GitHub repo. This contains the PSA simulations for all the `Vaccine` model parameters.
2. Click on  the second slider `2. Select parameter of interest for checking`, which can be used to flip over the model parameters and check that the resulting histogram is consistent with the modelling assumptions you want to use.

Now move to the next tab `2. Economic analysis`. 

1. In the first slider `1. Import the simulations for (e,c) from:` select again `Spreadsheet` and upload the file `[cost-effectiveness-simulations.csv]`(https://github.com/rhart1/Health-Economic-Modeling-in-R_A-Hands-on-Introduction-/blob/docker/cost-effectiveness-simulations.csv) that you can download from this repo. This contains the simulations for QALYs and costs for the two interventions.
2. You *can* (but don't have to!) add labels for your interventions by typing new names instead of `Intervention1` and `Intervention2`.
3. Click on the `Run` button to run the economic analysis. 
4. Navigate the tabs on the right-hand side of the panel, `2.1 Cost-Effectiveness Analysis` to `2.4 Cost-Effectiveness Efficiency Frontier`

Now move to the third tab `3. Uncertainty analysis`. You can visualise the CEAC in the tabs on the right-hand side of the panel.

**OPTIONAL**: You can also run the VoI analysis from the fourth panel `4. Value of Information`. Perhaps the most useful one is the `4.2 Info-rank`: this is a probabilistic version of the "tornado plot" --- it shows the EVPPI associated with each parameter; the bigger the value, the more of the uncertainty is due to that specific parameter.

Finally, move to panel `5. Report`. From there you can select which parts of the analysis you've just done you want to export to either `pdf` or `docx` --- `BCEA-web` will do it for you and you can open the resulting report.
