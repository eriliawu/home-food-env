clear all
set more off

cd "S:\Personal\hw1220\food environment paper 2"
use "food_environment_2009-2013.dta", clear

cd "C:\Users\wue04\Box Sync\home-food-env"
********************************************************************************

* define sample, covariates
global sample home==0 & !missing(grade) & nearestFFOR<=2640
global sample2 home==0 & !missing(grade) & nearestFFORsn<=2640

global demo b5.ethnic2 female poor forborn sped lep age i.graden i.year
global house publichousing fam1 coop fam2to4 fam5ormore condo mixeduse otherres nonres





/*
esttab using "supplementary_table4_may3.rtf", replace b(3) ci(3) ///
	starlevels(= 0.1 + 0.05 * 0.01) title("table4 street network") nogaps
*/
	















