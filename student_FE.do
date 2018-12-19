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
	by newid: gen nearest`var'sn1 = nearest`var'sn[_n-1] if year==year[_n-1]+1 //t-1
	by newid: gen nearest`var'sn2 = nearest`var'sn[_n-2] if year==year[_n-2]+2 //t-2
}
.
label var distFFORsn1 "time lag 1 year"
label var distFFORsn2 "time lag 2 years"
label var nearestFFORsn1 "time lag 1 year"
label var nearestFFORsn2 "time lag 2 yeas"

* sanity check
sort newid year
quietly by newid: gen dup=cond(_N==1, 0, _n)
bys newid: egen max=max(dup) //looks fine
drop dup max

* compare summary stats
forvalues i=1/2 {
	foreach var in obese overweight female poor ethnic forborn sped lep boro {
		tab `var' if $sample2 & year==2013 & !missing(distFFORsn`i')
	}
	sum zbmi grade age if $sample2 & year==2013 & !missing(distFFORsn`i')
}
.

* regression and export result
foreach y in overweight obese zbmi {
	eststo clear
	*current model
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2, robust absorb(boroct2010) //current model
	* cluster SE at student level
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2, absorb(boroct2010) vce(cluster newid)
	* using student FE
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn ///
		sped lep age i.graden i.year $house if $sample2, robust absorb(newid) //student fe
	* time lag t-1
	quietly eststo: areg `y' i.distFFORsn1 i.distBODsn1 i.distWSsn1 ///
		i.distC6Psn1 $demo $house if $sample2, robust absorb(boroct2010) //time lag t-1
	* time lag t-2
	quietly eststo: areg `y' i.distFFORsn2 i.distBODsn2 i.distWSsn2 ///
		i.distC6Psn2 $demo $house if $sample2, robust absorb(boroct2010) //time lag t-2
	esttab using raw-tables\studentFE_time_lag.rtf, append b(3) se(3) ///
		starlevels(= 0.1 + 0.05 * 0.01) title("`y'-estimates") nogaps
}
.

*** addressing other comments from reviewers
* how many home ct do students reside in?
unique(boroct2010) if $sample2 

* check why the negative corr
* did students change address
* did food env change
keep if $sample2 & !missing(nearestFFORsn)
keep newid year x y *FFORsn *BODsn *WSsn *C6Psn 
reshape wide x y *FFORsn *BODsn *WSsn *C6Psn, i(newid) j(year)

foreach var in FFOR BOD WS C6P {
	*pwcorr nearest`var'sn2009 nearest`var'sn2010 nearest`var'sn2011 ///
		nearest`var'sn2012 nearest`var'sn2013
	*pwcorr dist`var'sn2009 dist`var'sn2010 dist`var'sn2011 dist`var'sn2012 dist`var'sn2013
}
. //2009, 2010, 2012 and 2013 are highly correlated, but not 2011

pwcorr x2009 x2010 x2011 x2012 x2013
pwcorr y2009 y2010 y2011 y2012 y2013

compress
save "S:\Personal\hw1220\food environment paper 2\data\dist_street_network.dta", replace
sum nearestFFORsn* nearestBODsn* nearestWSsn* nearestC6Psn*

* check if euclidean dist also have abnormal data in 2011
{
clear all
set more off
cd "S:\Personal\hw1220\food environment paper 2"
use "food_environment_2009-2013.dta", clear
global sample home==0 & !missing(grade) & nearestFFOR<=2640
keep if $sample & !missing(nearestFFOR)
keep newid year x y nearestFFOR nearestBOD nearestWS nearestC6P
reshape wide x y nearestFFOR nearestBOD nearestWS nearestC6P, i(newid) j(year)
foreach var in FFOR BOD WS C6P {
	pwcorr nearest`var'2009 nearest`var'2010 nearest`var'2011 ///
		nearest`var'2012 nearest`var'2013
}
. //all years are correlated
compress
save data\dist_euclidean.dta, replace
}
.











