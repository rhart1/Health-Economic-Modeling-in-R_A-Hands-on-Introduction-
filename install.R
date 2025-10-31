### Install the relevant packages 

# Sets the paths
.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))
# Sets the repos from which to install the packages
options(repos="https://cran.r-project.org")
# Sets the timeout duration
options(timeout=600)
# Install packages
# Disable bspm so the package is installed from the r-universe.dev repo
bspm::disable()
install.packages("BCEA",repos=c("https://giabaio.r-universe.dev"),dependencies=TRUE)
# Then re-enables it so the others can be installed quickil
bspm::enable()
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
