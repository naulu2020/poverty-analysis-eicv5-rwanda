
/*Nadine's project*/
**********************
set more off 
cd "C:\UWURUKUNDO Nadine\DATA ANALYTICS COURSES\ANALYSIS OF DETERMINANTS OF POVERTY WITHIN HOUSEHOLDS"

use cs_S1_S2_S3_S4_S6A_S6E_Person.dta,clear   // This is the datset from household survey that is detailed at personal level


*Generation of the education of head of househod variable*
********************************************************* 
recode s4aq1(.=2)
gen Educ_HoH=1 if  s1q2==1 & s4aq1==1
replace Educ_HoH=0 if s1q2==1 & s4aq1==2
replace Educ_HoH=. if s1q2!=1 & s4aq1==.
drop if  Educ_HoH==.
label var Educ_HoH "Education of the Head of Household"
label def Educ_HoH 0 " Head of HH did not attended school" 1 "Head of Household  attended school"
label val Educ_HoH Educ_HoH
numlabel, add
tab Educ_HoH,m /* 76.7% of Head of HH attended school*/

*Generation of gender variable of Head of Household*
****************************************************
gen Sex_HoH=.
replace Sex_HoH=0 if s1q1==1 & s1q2==1
replace Sex_HoH=1 if s1q1==2 & s1q2==1
replace Sex_HoH=. if s1q1==. & s1q2!=1
drop if  Sex_HoH==.
label var Sex_HoH "Sex of the Head of Household"
label def Sex_HoH 0 " male" 1 "female"
label val Sex_HoH Sex_HoH
numlabel,add
tab Sex_HoH,m /* 74.46% are male and 25.54% are females */

*Generation of marital status of the Head of HH*
***********************************************
gen Marital_HoH=.
replace Marital_HoH=0 if s1q4==1|s1q4==2|s1q4==3 & s1q2==1
replace Marital_HoH=1 if s1q4==4|s1q4==5|s1q4==6|s1q4==7|s1q4==8 & s1q2==1
replace Marital_HoH=. if s1q4==. & s1q2!=1
drop if  Marital_HoH==.

label var Marital_HoH "Marital status of the Head of Household"
label def Marital_HoH 0 " Married" 1 " Not married"
label val Marital_HoH Marital_HoH
tab Marital_HoH ,m   /*  64.16 % are married compared to 35.84% who are not married*/

*Generation of Disability status of the Head of HH*
***************************************************
gen Disb_HoH=.
replace Disb_HoH=0 if s1q13==2|s1q13==3|s1q13==4|s1q13==5|s1q13==6|s1q13==7|s1q13==8|s1q13==9 & s1q2==1
replace Disb_HoH=1 if s1q13==1 & s1q2==1
replace Disb_HoH=. if s1q13==. & s1q2!=1
drop if  Disb_HoH==.

label var Disb_HoH "Marital status of the Head of Household"
label def Disb_HoH 0 " Disabled" 1 " Not Disabled"
label val Disb_HoH Disb_HoH
tab Disb_HoH ,m   /*  91.56% % are not disabled while 8.44% are disabled*/

*Remove duplicates*
*******************
sort hhid
quietly by hhid: gen dup = cond(_N==1,0,_n)
*save the final dataset to be merged with size dataset
************************************************************************
keep if dup<=1
keep hhid  Educ_HoH Sex_HoH Marital_HoH Disb_HoH
save pid.dta, replace
	                
// Size of Household//
**********************				
set more off 
cd "C:\UWURUKUNDO Nadine\DATA ANALYTICS COURSES\ANALYSIS OF DETERMINANTS OF POVERTY WITHIN HOUSEHOLDS"

use cs_S1_S2_S3_S4_S6A_S6E_Person.dta, clear

*Calculating the size of hOusehold to be used *
***********************************************
collapse (count) size_HH=pid, by(hhid) /* there are some households with more than 20 persons*/
 
* save dataset*
***************
save sizeHH.dta, replace

*merging dataset with size and other useful variables to be used in the analysis*
*********************************************************************************
set more off 
cd "C:\UWURUKUNDO Nadine\DATA ANALYTICS COURSES\ANALYSIS OF DETERMINANTS OF POVERTY WITHIN HOUSEHOLDS"
use pid.dta,clear
merge 1:1 hhid using sizeHH
drop _merge
save pidfinal.dta, replace


* Cleaning other variables needed in the model*
***********************************************
set more off 
cd "C:\UWURUKUNDO Nadine\DATA ANALYTICS COURSES\ANALYSIS OF DETERMINANTS OF POVERTY WITHIN HOUSEHOLDS"

use cs_S0_S5_Household.dta, clear                   // dataset that contains 14,580 HH onservations

*welfare categories*
********************
tab poverty
recode  poverty (2=1)(3=0)
label def poverty 0 "non poor" 1 "poor"
label val poverty poverty
tab  poverty,m

*region*
********
recode ur (1=0)(2=1)
label def ur 0 "rural" 1 "urban"
label val ur ur 
tab ur

*keep variables to be merged with personal level dataset*
*********************************************************
keep hhid  weight poverty ur

*final dataset to be used in analysis"
*************************************
merge 1:1 hhid using pidfinal
drop  _merge
save finaldataset.dta, replace

*Logit regression*
******************
logit poverty ur Educ_HoH Sex_HoH size_HH Marital_HoH Disb_HoH [iw=weight], vce (robust)
 
*coefficients interpretation*
*****************************
margins , dydx (ur Educ_HoH Sex_HoH size_HH Marital_HoH Disb_HoH)

*end of do file*






					
