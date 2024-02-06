*Do file for EC223 Stata Empirical Project
*Fall 2023
*Gia Bao Ngo (Belinda)

*Data from IPUMS-CPS, ASEC 2023

clear all

*replace: Stata can replace the logfile when re-running the dofile
log using "/Users/bgngo/Desktop/boston u/2023 Fall/EC223 B1, Gnedenko/Stata Empirical project/log_ec223project.log", replace
use "/Users/bgngo/Desktop/boston u/2023 Fall/EC223 B1, Gnedenko/Stata Empirical project/cps_00005.dta", replace

*check original data
br
sum inctot educ age wkxpns marst citizen

*check and clean data
replace inctot = . if inctot == 999999999
drop if inctot == .

gen yrs_educ = educ
replace yrs_educ = 0 if educ == 2
replace yrs_educ = 4 if educ == 10
replace yrs_educ = 6 if educ == 20
replace yrs_educ = 8 if educ == 30
replace yrs_educ = 9 if educ == 40
replace yrs_educ = 10 if educ == 50
replace yrs_educ = 11 if educ == 60 | educ == 71
replace yrs_educ = 12 if educ == 73
replace yrs_educ = 13 if educ == 81
replace yrs_educ = 14 if educ == 91 | educ == 92
replace yrs_educ = 16 if educ == 111
replace yrs_educ = 18 if educ == 123
replace yrs_educ = 21 if educ == 124 | educ == 125

replace wkxpns = . if wkxpns == 9999
drop if wkxpns == .

gen married = marst
replace married = 1 if marst == 1 | marst == 2
replace married = 0 if marst >= 3

gen uscitizen = citizen
replace uscitizen = 1 if citizen < 5
replace uscitizen = 0 if citizen == 5

*check cleaned data
sum inctot yrs_educ age wkxpns married uscitizen

*analysis on sample statistics
sum inctot if married == 1
sum inctot if married == 0
sum inctot if uscitizen == 1
sum inctot if uscitizen == 0

*scatterplot & fitted line
twoway (scatter inctot yrs_educ) (lfit inctot yrs_educ)

*log of income
gen lninctot = ln(inctot)
sum lninctot yrs_educ age wkxpns married uscitizen

*bivariate regression: regular & log
reg inctot yrs_educ
reg lninctot yrs_educ

*multivariate regression: regular & log
reg inctot yrs_educ age wkxpns married uscitizen
reg lninctot yrs_educ age wkxpns married uscitizen

*regression with binary dependent variable
gen highinc = (inctot > 75000) if !missing(inctot)
reg highinc yrs_educ age wkxpns married uscitizen
sum highinc yrs_educ age wkxpns married uscitizen

*logistic regression
logit highinc yrs_educ age wkxpns married uscitizen
*predicting probabilities
dis "Predicted probability of total personal income > $75000 (highinc=1) when yrs_educ=12, age=43, wkxpns=1500, married=1, uscitizen=1 is " 1/(1+exp(-(_b[_cons]+_b[yrs_educ]*12+_b[age]*43+_b[wkxpns]*1500+_b[married]*1+_b[uscitizen]*1)))
dis "Predicted probability of total personal income > $75000 (highinc=1) when yrs_educ=21, age=43, wkxpns=1500, married=1, uscitizen=1 is " 1/(1+exp(-(_b[_cons]+_b[yrs_educ]*21+_b[age]*43+_b[wkxpns]*1500+_b[married]*1+_b[uscitizen]*1)))

*label new variables
la variable yrs_educ "years of completed schooling"
la variable married "is currently married"
la variable uscitizen "is a us citizen"
la variable lninctot "log of variable inctot"
la variable highinc "total personal income is > $75000"

*drop IPUMS pre-selected variables
drop year serial month cpsid asecflag asecwth pernum cpsidp cpsidv asecwt
de
br

*save as new data set
save "/Users/bgngo/Desktop/boston u/2023 Fall/EC223 B1, Gnedenko/Stata Empirical project/newdata_ec223project.dta", replace

log close
