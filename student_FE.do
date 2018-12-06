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

*** new models
* using student FE
* use time lagged measurements: t-1 and t-2
* generate lagged distance measurements, t-1 and t-2
sort newid year
foreach var in FFOR BOD WS C6P {
	by newid: gen dist`var'sn1 = dist`var'sn[_n-1] if year==year[_n-1]+1 //t-1
	by newid: gen dist`var'sn2 = dist`var'sn[_n-2] if year==year[_n-2]+2 //t-2
}
.
* sanity check
sort newid year
quietly by newid: gen dup=cond(_N==1, 0, _n)
bys newid: egen max=max(dup) //looks fine
drop dup max

* using student FE
foreach y in overweight obese zbmi {
	eststo clear
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2, robust absorb(boroct2010) //current model
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn ///
		sped lep age i.graden i.year $house if $sample2, robust absorb(newid) //student fe
	* time lag t-1
	quietly eststo: areg `y' i.distFFORsn1 i.distBODsn1 i.distWSsn1 ///
		i.distC6Psn1 $demo $house if $sample2, robust absorb(boroct2010) //time lag t-1
	* time lag t-2
	quietly eststo: areg `y' i.distFFORsn2 i.distBODsn2 i.distWSsn2 ///
		i.distC6Psn2 $demo $house if $sample2, robust absorb(boroct2010) //time lag t-2
	esttab using raw-tables\studentFE_time_lag.rtf, append b(4) se(4) nogaps ///
		title("`y'-student-FE-time-lag")
}
.






/*
esttab using "supplementary_table4_may3.rtf", replace b(3) ci(3) ///
	starlevels(= 0.1 + 0.05 * 0.01) title("table4 street network") nogaps
*/
	















