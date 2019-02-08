clear all
set more off

cd "C:\Users\wue04\Box Sync\home-food-env\data\raw-data"
********************************************************************************
*** test correlation in food measure
{
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
drop _merge id *name 
compress
save replace2011.dta, replace
erase replace2011_id.dta

* clean up 2012 supermarket data
import delimited closestC6P_2012map.csv, clear
keep incidentid total_length
rename inci id
rename total C6P
gen year=2012
sum id
compress
save C6P2012_temp.dta, replace

* link id to x-y
import delimited "H:\Personal\food environment paper 1\students' addresses\unique_xy12.csv", clear
tab year
sum id
drop if missing(x)
merge 1:1 id using C6P2012_temp.dta
drop if _merge==1
drop id _merge
compress
save C6P2012.dta, replace
erase C6P2012_temp.dta

* link to students
merge 1:m x y year using "H:\Personal\food_environment_2009-2013.dta"
drop if _mer==1
replace nearestC6Psn=C6P if !missing(C6P) & year==2012 & _merge==3
drop _merge C6P

merge m:1 x y year using replace2011.dta
drop if _mer==2
foreach var in FFOR BOD WS C6P {
	replace nearest`var'sn=`var' if !missing(`var') & year==2011 & _merge==3
}
.
drop FFOR C6P WS BOD  _merge
compress
save "H:\Personal\food_environment_2009-2013_replace.dta", replace
erase replace2011.dta
erase C6P2012.dta
}
.

********************************************************************************
*** analytical
* re-run regressions
use "H:\Personal\food_environment_2009-2013_replace.dta", clear
{
* define sample, covariates
global sample home==0 & !missing(grade) & nearestFFOR<=2640
global sample2 home==0 & !missing(grade) & nearestFFORsn<=2640

global demo b5.ethnic2 female poor forborn sped lep age i.graden i.year
global house publichousing fam1 coop fam2to4 fam5ormore condo mixeduse otherres nonres

*** house cleaning
* re-create distance rings
drop distFFORsn distBODsn distWSsn distC6Psn distFFsn distWSORsn
foreach var in FFOR BOD WS C6P {
	gen dist`var'sn=(nearest`var'sn<=132)
	replace dist`var'sn=2 if nearest`var'sn>132 & nearest`var'sn<=264
	replace dist`var'sn=3 if nearest`var'sn>264 & nearest`var'sn<=528
	replace dist`var'sn=4 if nearest`var'sn>528 & nearest`var'sn<=792
	replace dist`var'sn=5 if nearest`var'sn>792 & nearest`var'sn<=1056
	replace dist`var'sn=6 if nearest`var'sn>1056 & nearest`var'sn<=1320
	replace dist`var'sn=7 if nearest`var'sn>1320
}
.

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
	label var dist`var'sn1 "time lag 1 year"
	label var dist`var'sn2 "time lag 2 years"
	label var nearest`var'sn1 "time lag 1 year"
	label var nearest`var'sn2 "time lag 2 yeas"
}
.

* sanity check
sort newid year
quietly by newid: gen dup=cond(_N==1, 0, _n)
bys newid: egen max=max(dup) //looks fine
drop dup max

order newid year bdsnew x y
compress
save "H:\Personal\food_environment_2009-2013_replace.dta", replace

cd "C:\Users\wue04\Box Sync\home-food-env"

global sample2 home==0 & !missing(grade) & nearestFFORsn<=2640
* compare summary stats
forvalues i=1/2 {
	foreach var in obese overweight female poor ethnic forborn sped lep boro {
		tab `var' if $sample2 & year==2013 & !missing(distFFORsn`i')
	}
	sum zbmi grade age if $sample2 & year==2013 & !missing(distFFORsn`i')
}
.

*** regression and export result
* main model
foreach y in overweight obese zbmi {
	eststo clear
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2, robust absorb(boroct2010) //current model
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2, absorb(boroct2010) vce(cluster newid) //clustered SE at student level
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn ///
		sped lep age i.graden i.year $house if $sample2, robust absorb(newid) //student fe
	quietly eststo: areg `y' i.distFFORsn1 i.distBODsn1 i.distWSsn1 ///
		i.distC6Psn1 $demo $house if $sample2, robust absorb(boroct2010) //time lag t-1
	quietly eststo: areg `y' i.distFFORsn2 i.distBODsn2 i.distWSsn2 ///
		i.distC6Psn2 $demo $house if $sample2, robust absorb(boroct2010) //time lag t-2
	esttab using raw-tables\studentFE_timeLag20190207.rtf, append b(3) se(3) ///
		starlevels(= 0.1 + 0.05 * 0.01) title("`y'-estimates") nogaps
}
.

*** supp analyses
* table s7: by grade
eststo clear
foreach y in overweight obese zbmi {
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2 & level==1, robust absorb(boroct2010) 
}
.
foreach y in overweight obese zbmi {
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2 & (level==2|level==3), robust absorb(boroct2010) 
}
.
esttab using raw-tables\studentFE_timeLag20190207.rtf, append b(3) se(3) ///
	starlevels(= 0.1 + 0.05 * 0.01) title("s7-by-grade") nogaps

* s8: by boro
forvalues i=1/5 {
	eststo clear
	foreach y in overweight obese zbmi {
		quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
			$house if $sample2 & boro==`i', robust absorb(boroct2010)
	}
	esttab using raw-tables\studentFE_timeLag20190207.rtf, append b(3) se(3) ///
		starlevels(= 0.1 + 0.05 * 0.01) title("s8-boro`i'") nogaps
}
.

* s9: students not living in commercial strips
egen commercial_10tile=xtile(commercial2016) if $sample2, by(year) nq(10)
eststo clear
foreach y in overweight obese zbmi {
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2 & commercial_10tile<=9, robust absorb(boroct2010)
}
.
esttab using raw-tables\studentFE_timeLag20190207.rtf, append b(3) se(3) ///
	starlevels(= 0.1 + 0.05 * 0.01) title("s9-commercial-strip") nogaps

* s11: alternative reference group in supermarkets
* set 0-0.05 miles as ref group
gen distC6Psn_alt = 1
replace distC6Psn_alt = 2 if distC6Psn==3
replace distC6Psn_alt = 3 if distC6Psn==4
replace distC6Psn_alt = 4 if distC6Psn==5
replace distC6Psn_alt = 5 if distC6Psn==6
replace distC6Psn_alt = 6 if distC6Psn==7
label var distC6Psn_alt "ref group 0-0.05 miles"

eststo clear
foreach y in overweight obese zbmi {
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn_alt $demo ///
		$house if $sample2, robust absorb(boroct2010)
}
.
esttab using raw-tables\studentFE_timeLag20190207.rtf, append b(3) se(3) ///
	starlevels(= 0.1 + 0.05 * 0.01) title("s11-alternative-SUP-ref-group") nogaps

*s12 without CT FE
eststo clear
foreach y in overweight obese zbmi {
	quietly eststo: reg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn ///
			$demo $house if $sample2, robust
}
.
foreach y in overweight obese zbmi {
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn ///
			$demo $house if $sample2, robust absorb(boroct2010)
}
.
esttab using raw-tables\studentFE_timeLag20190207.rtf, append b(3) se(3) ///
	starlevels(= 0.1 + 0.05 * 0.01) title("s12-no-CT-FE") nogaps

* poor vs. non-poor
eststo clear
foreach i in 0 1 {
	foreach y in overweight obese zbmi {
		quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn ///
			$demo $house if $sample2 & poor==`i', robust absorb(boroct2010)
	}
}
.
esttab using raw-tables\studentFE_timeLag20190207.rtf, append b(3) se(3) ///
	starlevels(= 0.1 + 0.05 * 0.01) title("s13-poo-vs-non-poor") nogaps

*sample size for different models
count if $sample2 //3,507,542
count if $sample2 & level==1 //1,758,305
count if $sample2 & (level==2|level==3) //1,749,237
forvalues i=1/5 {
	count if $sample2 & boro==`i'
}
. //404,198; 731,271; 1,169,775; 992,331; 209,963
count if $sample2 & commercial_10tile<=9 //3,156,825
count if $sample2 & poor==0 //452,316
count if $sample2 & poor==1 //3,055,226


*** addressing other comments from reviewers
* how many home ct do students reside in?
unique(boroct2010) if $sample2

* corr in food measurements between diff years
keep if $sample2 & !missing(nearestFFORsn)
keep newid year x y *FFORsn *BODsn *WSsn *C6Psn 
reshape wide x y *FFORsn *BODsn *WSsn *C6Psn, i(newid) j(year)

foreach var in FFOR BOD WS C6P {
	pwcorr nearest`var'sn2009 nearest`var'sn2010 nearest`var'sn2011 ///
		nearest`var'sn2012 nearest`var'sn2013
}
.
}
.





