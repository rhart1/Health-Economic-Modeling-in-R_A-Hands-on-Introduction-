
# Please read and run this script prior to taking part in the workshop on 6th November 2022

# Please have an R version 4.2.0 or later - instructions for this are in the pre-read documents

# The following function has been written to look through a list of required packages and install
# any packages that have not been previously installed. It will then load the required libraries into
# your R environment
Packageloader <- function(packs) {
  system.time(
    if (length(setdiff(packs, rownames(installed.packages()))) > 0) {
      message("you need the following packages to run this script")
      message(setdiff(packs, rownames(installed.packages())))
      message("Installing them now...")
      install.packages(setdiff(packs, rownames(installed.packages())))
      message("Now loading libraries...")
      sapply(packs, require, character.only = TRUE)
    } else {
      message("All packages are installed already")
      message("Loading the specified libraries...")
      sapply(packs, require, character.only = TRUE)
    }
  )
}


# This will execute the above function with the following packages
# Depending on existing packages, this process may take a few minutes
Packageloader(
  c(
    "shiny",
    "shinydashboard",
    "hesim",
    "data.table",
    "ggplot2",
    "survminer",
    "magrittr",
    "shinyWidgets",
    "rmarkdown",
    "bookdown",
    "knitr",
    "kableExtra",
    "diagram",
    "heemod",
    "shinycssloaders",
    "DT",
    "shinyjs",
    "BCEA"
  ))
    
