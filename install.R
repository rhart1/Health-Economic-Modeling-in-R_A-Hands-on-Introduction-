### Install the relevant packages 

# Sets the paths
.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))

options(
  repos = c(giabaio="https://giabaio.r-universe.dev",CRAN="https://cran.r-project.org"),
  timeout = 600
)
.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))

###install.packages("BCEA", repos=c("https://giabaio.r-universe.dev"),dependencies=TRUE)
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
install.packages("docopt")
