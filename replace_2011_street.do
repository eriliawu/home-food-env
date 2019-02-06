clear all
set more off

cd "C:\Users\wue04\Box Sync\home-food-env\data\raw-data"
********************************************************************************
{
*** link 2011 food outlets to 2011 map, round 2, 2018-12
foreach var in BOD WS {
	import delimited `var'_2012map.csv, clear
	keep incidentid total_length name
	rename inci id
	rename total `var'
	rename name `var'name
	gen year=2011
	sum id
	compress
	save `var'2011_temp.dta, replace
}
.

import delimited closestFFOR_2012.csv, clear
keep incidentid total_length name
rename inci id
rename total FFOR
rename name FFORname
gen year=2011
sum id
compress
save FFOR2011_temp.dta, replace

foreach var in BOD WS {
	merge 1:1 id using `var'2011_temp.dta
	rename _merge merge_`var'
	erase `var'2011_temp.dta
}
.
compress
drop merge* *name

save replace2011_id.dta, replace
erase FFOR2011_temp.dta

* link id to x-y
import delimited "H:\Personal\food environment paper 1\students' addresses\unique_xy11.csv", clear
tab year
sum id
drop if missing(x)
merge 1:1 id year using replace2011.dta
drop _merge id
compress
save replace2011.dta, replace
erase replace2011_id.dta

* link to students
merge 1:m x y year using "S:\Personal\hw1220\food environment paper 2\food_environment_2009-2013.dta"
foreach var in FFOR BOD WS {
	replace nearest`var'=`var' if !missing(`var') & year==2011
}
.
drop if _merge==1
drop FFOR BOD WS
compress
save "S:\Personal\hw1220\food environment paper 2\food_environment_2009-2013_replace.dta", replace

********************************************************************************
*** see corr between years
global sample2 home==0 & !missing(grade) & nearestFFORsn<=2640

keep if $sample2 & !missing(nearestFFORsn)
keep newid year x y *FFORsn *BODsn *WSsn *C6Psn 
reshape wide x y *FFORsn *BODsn *WSsn *C6Psn, i(newid) j(year)

foreach var in FFOR BOD WS C6P {
	pwcorr nearest`var'sn2009 nearest`var'sn2010 nearest`var'sn2011 ///
		nearest`var'sn2012 nearest`var'sn2013
	*pwcorr dist`var'sn2009 dist`var'sn2010 dist`var'sn2011 dist`var'sn2012 dist`var'sn2013
}
. //2009, 2010, 2012 and 2013 are highly correlated, but not 2011

pwcorr x2009 x2010 x2011 x2012 x2013
pwcorr y2009 y2010 y2011 y2012 y2013

*compress
*save "S:\Personal\hw1220\food environment paper 2\data\dist_street_network.dta", replace
sum nearestFFORsn* nearestBODsn* nearestWSsn* nearestC6Psn*
}
.

*** link 2011 food outlets to 2011 map, round 2, 2018-12
cd "C:\Users\wue04\Box Sync\home-food-env\data\raw-data"
foreach var in FFOR BOD WS C6P {
	import delimited closest`var'_2011map.csv, clear
	keep incidentid total_length name
	rename inci id
	rename total `var'
	rename name `var'name
	gen year=2011
	sum id
	compress
	save `var'2011_temp.dta, replace
}
.
foreach var in FFOR BOD WS {
	merge 1:1 id using `var'2011_temp.dta
	drop if _mer!=3
	drop _merge
}
.
save replace2011_id.dta, replace
erase FFOR2011_temp.dta
erase WS2011_temp.dta
erase BOD2011_temp.dta
erase C6P2011_temp.dta

* link id to x-y
import delimited "H:\Personal\food environment paper 1\students' addresses\unique_xy11.csv", clear
tab year
sum id
drop if missing(x)
merge 1:1 id using replace2011_id.dta
drop _merge id
drop *name
foreach var in FFOR BOD WS C6P {
	rename `var' `var'2011
}
.
drop year
compress
save replace2011.dta, replace
erase replace2011_id.dta

*** compare with original 2012 stats
cd "C:\Users\wue04\Box Sync\home-food-env\data\raw-data\archive"
foreach var in FFOR BOD WS C6P {
	import delimited "H:\Personal\food environment paper 1\2012\closest\closest`var'.csv", clear
	keep incidentid total_length 
	rename inci id
	rename total `var'2012
	gen year=2012
	sum id
	compress
	save `var'2012_temp.dta, replace
}
.
foreach var in FFOR BOD WS C6P {
	merge 1:1 id using `var'2012_temp.dta
	drop _merge
}
save replace2012_id.dta, replace
erase WS2012_temp.dta
erase FFOR2012_temp.dta
erase BOD2012_temp.dta
erase C6P2012_temp.dta

* link id to x-y
import delimited "H:\Personal\food environment paper 1\students' addresses\unique_xy12.csv", clear
tab year
sum id
drop if missing(x)
merge 1:1 id using replace2012_id.dta
drop if _mer!=3
drop _merge id year
compress
save replace2012.dta, replace
erase replace2012_id.dta

* link to 2011 data
merge 1:1 x y using replace2011.dta
pwcorr FFOR2011 FFOR2012
pwcorr WS2011 WS2012
pwcorr BOD2011 BOD2012
pwcorr C6P2011 C6P2012 //all highly correlated

* link to student data
drop *2012 _merge
foreach var in FFOR BOD WS C6P {
	rename `var'2011 `var'
}
.
gen year=2011
merge 1:m x y year using "H:\Personal\food_environment_2009-2013.dta"

global sample2 home==0 & !missing(grade) & nearestFFORsn<=2640
drop if _mer==1
foreach var in FFOR BOD WS C6P {
	replace nearest`var'sn=WS if !missing(`var') & year==2011 & _merge==3
}
.
drop WS BOD FFOR C6P _merge

keep if $sample2 & !missing(nearestFFORsn)
keep newid year x y *FFORsn *BODsn *WSsn *C6Psn 
reshape wide x y *FFORsn *BODsn *WSsn *C6Psn, i(newid) j(year)

foreach var in FFOR BOD WS C6P {
	pwcorr nearest`var'sn2009 nearest`var'sn2010 nearest`var'sn2011 ///
		nearest`var'sn2012 nearest`var'sn2013
}
. 





