### Install the relevant packages 

# Sets the paths
.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))
# Sets the repos from which to install the packages
options(repos=c(CRAN="https://cran.r-project.org",giabaio='https://giabaio.r-universe.dev'))
# Sets the timeout duration
options(timeout=600)
# Install packages
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
install.packages('BCEA',repos=c('https://giabaio.r-universe.dev',"https://cran.r-project.org"))
