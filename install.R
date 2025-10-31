### Install the relevant packages 

# Sets the paths
.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))

Sys.setenv(R_BSPM_ENABLE = "FALSE")
options(bspm.enable = FALSE, bspm.sudo = FALSE,
        repos = c("https://giabaio.r-universe.dev", "https://cran.r-project.org"),
        timeout = 600)
if ("bspm" %in% loadedNamespaces()) {
  try(unloadNamespace("bspm"), silent = TRUE)
  if ("package:bspm" %in% search()) try(detach("package:bspm", unload = TRUE, character.only = TRUE), silent = TRUE)
}

# install from r-universe first
install.packages("BCEA", ,repos=c("https://giabaio.r-universe.dev"),dependencies=TRUE)

# re-enable bspm for later installs (optional)
Sys.setenv(R_BSPM_ENABLE = "TRUE")
options(bspm.enable = TRUE)
if (!"bspm" %in% loadedNamespaces()) try(library(bspm), silent = TRUE)

# Re-enables bspm so the other packages can be installed via apt
options(bspm.enable=TRUE)

install.packages("shiny")
install.packages("shinydashboard")
install.packages("hesim")
install.packages("data.table")
install.packages("ggplot2")
install.packages("survminer")
install.packages("shinyWidgets")
install.packages("rmarkdown")
install.packages("bookdown")
install.packages("knitr")
install.packages("kableExtra")
install.packages("diagram")
install.packages("heemod")
install.packages("shinycssloaders")
install.packages("DT")
install.packages("shinyjs")
