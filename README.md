# Validation of CHADS2 and HAS-BLED scores using ICD-9-CM codes
Brian Gulbis, Christie Hall  
April 26, 2016  

## Objective

To compare manual calculation of CHADS2 and HAS-BLED scores with automated scores
calculated using ICD-9-CM codes.

## Methods

Patient records were manually reviewed by two IPPE pharmacy students, and a
CHADS2 and HAS-BLED score were calculated.

For the same patients, data was extracted from the EDW, including a list of all
encounters for each patient, and all ICD-9-CM diagnosis codes for each
encounter.

The ICD-9-CM codes were then used to determine whether each patient had the
specified condition, and this was used to calculate the score.

* CHADS2
    - Heart failure (1 point)
    - Hypertension (1 point)
    - Age, 75 years or greater (1 point)
    - Diabetes (1 point)
    - Stroke (2 points)
* HAS-BLED

### Classifying ICD-9-CM Codes

To classify ICD-9-CM codes into diagnosis of these disease states, the Clinical 
Classifications Software (CCS) for ICD-9-CM tool was used (see [Healthcare Cost
and Utilization
Project](https://www.hcup-us.ahrq.gov/toolssoftware/ccs/ccs.jsp)).

### Comparing Manual and Automated Scores

The next step will be to compare the manual and automated scores to determine
the accuracy of the automated scores.
