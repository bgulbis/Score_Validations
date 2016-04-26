# read_data.R
# 
# read in data from Excel, process MRN's, and print out list of MRN's to input
# into EDW

source("0-library.R")

# excel data ----

# read in patient list from Excel; keep only patients being validated
xls.name <- paste(dir.pts, "chads hasbled validation.xls", sep = "/")
pts <- read_excel(xls.name) %>%
    filter(!is.na(Assignment)) 

# get the MRN field and remove leading 0
mrn <- select(pts, `Medical Record Number`) %>%
    transmute(mrn = str_replace_all(`Medical Record Number`, ".000000", ""))

# print MRN list for EDW, run query "Identifiers - Person by MRN"
concat_encounters(mrn$mrn)

# person identifiers ----

# read in list of person id's
ids <- read_edw_data(dir.pts, "mrn")

# get person id's and run EDW query "Encounters - by Person ID"
concat_encounters(ids$person.id)

# encounter list ----

# get list of all encounters for these patients, remove encounters which are not
# an inpatient or clinic visit
encounters <- read_edw_data(dir.pts, "encounters") %>%
    filter(!(facility %in% c("Lifepoint", "University Care Plus")),
           !(visit.type %in% c("Outreach Lab", "Outpt Diag Services", 
                               "Research Patient", "Wound Care"))) %>%
    left_join(ids, by = "person.id")

concat_encounters(encounters$pie.id, 900)

save_rds(dir.save, "encounters")

# get list of TMC inpatient encounters
# encounters.tmc <- filter(encounters, facility == "Memorial Hermann Hospital")
# 
# inpt.types <- c("Bedded Outpatient", "EC Emergency Center", "Inpatient", 
#                 "Inpatient Rehab", "OBS Day Surgery", "OBS Observation Patient")
# encounters.inpt <- filter(encounters, visit.type %in% inpt.types)

# check number of patients
# tmp <- encounters.inpt %>%
#     distinct(person.id)
# 
# outpt.only <- anti_join(encounters, tmp, by = "person.id") %>%
#     distinct(person.id)
