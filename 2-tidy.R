# tidy.R

source("0-library.R")

raw.demograph <- read_edw_data(data.dir, "demographics") %>% distinct(pie.id)
raw.diagnosis <- read_edw_data(data.dir, "diagnosis")
# raw.problems <- read_edw_data(data.dir, "problems")

raw.diagnosis <- inner_join(raw.diagnosis, select(encounters, person.id, pie.id), 
                            by = "pie.id")

# how many patients had no ICD9 codes?
zero.icd9 <- anti_join(persons, raw.diagnosis, by = "person.id")

# get ICD9 codes for HTN, DM, CHF, and CVA
ref.ccs.chads <- read_data(lookup.dir, "ccs_chads.csv") 

tidy.diagnosis <- tidy_data("diagnosis", ref.data = ref.ccs.chads, 
                            pt.data = raw.diagnosis, patients = encounters)

# patients that had ICD9 codes, but no CHF, HTN, DM, or CVA codes
zero.chads.icd9 <- anti_join(raw.diagnosis, 
                             inner_join(tidy.diagnosis, encounters, 
                                        by = "pie.id"), 
                             by = "person.id") %>%
    select(person.id) %>%
    distinct %>%
    inner_join(raw.demograph, by = "person.id") %>%
    inner_join(select(encounters, pie.id, admit.datetime), by = "pie.id") %>%
    group_by(person.id) %>%
    arrange(admit.datetime) %>%
    summarize(age = last(age))
    

# calculate CHADS2 for each encounter with ICD9 codes
data.chads <- select(encounters, -disposition) %>%
    arrange(admit.datetime) %>%
    inner_join(select(raw.demograph, pie.id:race), by = "pie.id") %>%
    left_join(tidy.diagnosis, by = "pie.id") %>%
    filter(!is.na(diabetes)) %>%
    group_by(pie.id) %>%
    mutate(chads2 = sum(heart.failure, age >= 75, hypertension, diabetes, 
                        stroke * 2, na.rm = TRUE))

# calculate a CHADS2 score for each person; assumes that if they ever had an
# ICD9 code for a disease then it is present even if missing from future
# encounters
data.chads.person <- data.chads %>%
    group_by(person.id) %>%
    summarize(heart.failure = sum(heart.failure, na.rm = TRUE),
              hypertension = sum(hypertension, na.rm = TRUE),
              age = last(age),
              diabetes = sum(diabetes, na.rm = TRUE),
              stroke = sum(stroke, na.rm = TRUE),
              chads2.first = first(chads2),
              chads2.last = last(chads2),
              chads2.max = max(chads2)) %>%
    full_join(zero.chads.icd9, by = c("person.id", "age")) %>%
    rowwise %>%
    mutate(heart.failure = ifelse(heart.failure > 0, TRUE, FALSE),
           hypertension = ifelse(hypertension > 0, TRUE, FALSE),
           diabetes = ifelse(diabetes > 0, TRUE, FALSE),
           stroke = ifelse(stroke > 0, TRUE, FALSE),
           chads2.all = sum(heart.failure, age >= 75, hypertension, diabetes, 
                        stroke * 2, na.rm = TRUE))
