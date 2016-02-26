# read_data.R
# 
# read in data from Excel, process MRN's, and print out list of MRN's to input
# into EDW

source("library.R")

# excel data ----

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

# person identifiers ----

# read in list of encounters
encounters <- read_data(pt.dir, "identifiers")

# get person id's and re-run EDW encounters
persons <- select(encounters, Person.ID) %>%
    distinct

# print person list for EDW
edw.person <- str_c(persons$Person.ID, collapse = ";")
print(edw.person)

# encounter list ----

# get list of all encounters
encounters <- read_edw_data(pt.dir, "encounters")

# get list of TMC inpatient encounters
encounters.tmc <- filter(encounters, location == "Memorial Hermann Hospital")

inpt.types <- c("Bedded Outpatient", "EC Emergency Center", "Inpatient", 
                "Inpatient Rehab", "OBS Day Surgery", "OBS Observation Patient")
encounters.inpt <- filter(encounters, encounter.type %in% inpt.types)

# check number of patients
tmp <- encounters.inpt %>%
    distinct(person.id)

no.outpt <- anti_join(encounters, tmp, by = "person.id") %>%
    distinct(person.id)
