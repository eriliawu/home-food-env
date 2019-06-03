clear all
set more off

cd "C:\Users\wue04\Box Sync\home-food-env"
use "S:\Personal\hw1220\food environment paper 2\food_environment_2009-2013_replace.dta", clear

* define sample, covariates
global sample2 home==0 & !missing(grade) & nearestFFORsn<=2640
global demo b5.ethnic2 female poor forborn sped lep age i.graden i.year
global house publichousing fam1 coop fam2to4 fam5ormore condo mixeduse otherres nonres

esttab using raw-tables\studentFE_timeLag20190207.rtf, append b(3) se(3) ///
	starlevels(= 0.1 + 0.05 * 0.01) title("`y'-estimates") nogaps

* % of students observed multiple times
sort newid year
duplicates tag newid if $sample2, gen(dup)
tab dup
unique(newid) if $sample2

* main model, clustered student SE
eststo clear
foreach y in overweight obese zbmi {
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2, robust absorb(boroct2010) //current model
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2, vce(cluster newid) absorb(boroct2010) //with clustered SE, student
}
.
esttab using raw-tables\rr2_20190530.rtf.rtf, append b(3) se(3) ///
	starlevels(= 0.1 + 0.05 * 0.01) title("`y'-estimates") nogaps

* stratify by year
foreach y in overweight obese zbmi {
	eststo clear
	forvalues i=2009/2013 {
		quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
			$house if $sample2 & year==`i', robust absorb(boroct2010)
	}
	esttab using raw-tables\rr2_20190530.rtf.rtf, append b(3) se(3) ///
		starlevels(= 0.1 + 0.05 * 0.01) title("`y'-stratify-by-year") nogaps
}
.

* logit model
* main model and clustered SE at student level
eststo clear
foreach y in overweight obese zbmi {
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2, robust absorb(boroct2010) //current model
	quietly eststo: areg `y' i.distFFORsn i.distBODsn i.distWSsn i.distC6Psn $demo ///
		$house if $sample2, vce(cluster newid) absorb(boroct2010) //with clustered SE, student
}
.
esttab using raw-tables\rr2_20190530.rtf.rtf, append b(3) se(3) ///
	starlevels(= 0.1 + 0.05 * 0.01) title("logit-estimates") nogaps





* corr in food measurements between diff years
keep if $sample2 & !missing(nearestFFORsn)
keep newid year x y *FFORsn *BODsn *WSsn *C6Psn 
reshape wide x y *FFORsn *BODsn *WSsn *C6Psn, i(newid) j(year)

foreach var in FFOR BOD WS C6P {
	pwcorr nearest`var'sn2009 nearest`var'sn2010 nearest`var'sn2011 ///
		nearest`var'sn2012 nearest`var'sn2013
}
.





