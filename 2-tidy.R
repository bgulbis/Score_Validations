# tidy.R

source("0-library.R")

tmp <- get_rds(dir.save)

raw.demograph <- read_edw_data(dir.data, "demographics") %>% distinct(pie.id)
raw.diagnosis <- read_edw_data(dir.data, "icd9")
# raw.problems <- read_edw_data(dir.data, "problems")

# get ICD9 codes for HTN, DM, CHF, and CVA
ref.ccs.chads <- read_data(dir.lookup, "ccs_chads.csv") 

raw.diagnosis <- inner_join(raw.diagnosis, encounters[c("person.id", "pie.id")], 
                            by = "pie.id")

# how many patients had no ICD9 codes?
zero.icd9 <- anti_join(encounters, raw.diagnosis, by = "person.id") %>%
    select(person.id, mrn) %>%
    distinct

have.icd9 <- anti_join(encounters, zero.icd9, by = "person.id")

tidy.diagnosis <- tidy_data(raw.diagnosis, "icd9", ref.data = ref.ccs.chads, 
                            patients = have.icd9["pie.id"])

# calculate CHADS2 for each encounter
data.chads <- inner_join(raw.demograph[c("pie.id", "age")], tidy.diagnosis, 
                         by = "pie.id") %>%
    group_by(pie.id) %>%
    mutate(chads2 = sum(heart.failure, age >= 75, hypertension, diabetes, 
                        stroke * 2, na.rm = TRUE))

# calculate a CHADS2 score for each person; assumes that if they ever had an
# ICD9 code for a disease then it is present even if missing from future
# encounters
data.chads.person <- inner_join(data.chads, 
                                encounters[c("person.id", "pie.id", "mrn")], 
                                by = "pie.id") %>%
    group_by(person.id) %>%
    summarize(heart.failure = sum(heart.failure, na.rm = TRUE),
              hypertension = sum(hypertension, na.rm = TRUE),
              age = last(age),
              diabetes = sum(diabetes, na.rm = TRUE),
              stroke = sum(stroke, na.rm = TRUE),
              chads2.first = first(chads2),
              chads2.last = last(chads2),
              chads2.max = max(chads2)) %>%
    group_by(person.id) %>%
    mutate(heart.failure = ifelse(heart.failure > 0, TRUE, FALSE),
           hypertension = ifelse(hypertension > 0, TRUE, FALSE),
           diabetes = ifelse(diabetes > 0, TRUE, FALSE),
           stroke = ifelse(stroke > 0, TRUE, FALSE),
           chads2.all = sum(heart.failure, age >= 75, hypertension, diabetes, 
                        stroke * 2, na.rm = TRUE)) %>%
    left_join(distinct(encounters[c("person.id", "mrn")]), by = "person.id")

write_csv(data.chads, paste(dir.save, "chads2_icd9_by_encounter.csv", sep="/"))
write_csv(data.chads.person, paste(dir.save, "chads2_icd9_by_person.csv", sep="/"))

save_rds(dir.save, "^data")
