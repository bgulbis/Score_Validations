# library.R

library(readxl)
library(dplyr)
library(stringr)
library(BGTools)

# set directories
pt.dir <- "patients"
data.dir <- "data"
lookup.dir <- "lookup"

gzip_files(data.dir)
