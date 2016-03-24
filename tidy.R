# tidy.R

source("library.R")

raw.demograph <- read_edw_data(data.dir, "demographics")
raw.diagnosis <- read_edw_data(data.dir, "diagnosis")
raw.problems <- read_edw_data(data.dir, "problems")
