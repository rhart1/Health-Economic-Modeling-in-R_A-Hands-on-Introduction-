### Install the relevant packages 

# Gets repos for r-universe too
linux_binary_repo <- function(universe){
  sprintf('https://%s.r-universe.dev/bin/linux/noble-%s/%s/', 
    universe,
    R.version$arch, 
    substr(getRversion(), 1, 3))
}
options(repos = linux_binary_repo(c('giabaio', 'cran')),timeout=600)

.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))

install.packages("BCEA")
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

# Now disable bspm (to avoid going to apt binaries) and install BCEA from r-universe
# bspm::disable()
#install.packages("BCEA")
