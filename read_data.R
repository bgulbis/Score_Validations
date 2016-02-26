# read_data.R
# 
# read in data from Excel, process MRN's, and print out list of MRN's to input
# into EDW

source("library.R")

# read in patient list from Excel; keep only patients being validated
xls.name <- paste(pt.dir, "chads hasbled validation.xls", sep = "/")
pts <- read_excel(xls.name) %>%
    filter(!is.na(Assignment)) 

# make valid column names
names(pts) <- make.names(names(pts))

# get the MRN field and remove leading 0
mrn <- select(pts, Medical.Record.Number) %>%
    transmute(mrn = str_replace_all(Medical.Record.Number, ".000000", ""))

# print MRN list for EDW
edw.mrn <- str_c(mrn$mrn, collapse = ";")
print(edw.mrn)
