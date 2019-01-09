* full sample analyses
* PLOSOne R&R

set more off 
clear all
cd "H:\Personal\food environment paper 1"
use food_environment_2013_paper1.dta, clear

cd "C:\Users\wue04\Box Sync\home-food-env"

*** analytics
global sample !missing(x) & !missing(age) & !missing(grade) & !missing(bds) & ///
	!missing(ethnic) & !missing(x_sch) & home>2640 & sch>2640 & district<=32 & ///
	eth!=6 & !missing(boro) & !missing(boro_sch) & !missing(native) //789520

rename FF FFOR
foreach var in FFOR BOD C6P WS {
	label var `var' "dist to nearest `var'"
	label var `var'_sch "dist to nearest `var' from school"
	label var n`var'1320 "num of `var' in 1320 ft"
	label var n`var'1320_sch "num of `var' in 1320 ft from school"
}
.

* create race and poverty intereaction
gen poor_race=1 if poor==0 & eth==5
replace poor_race=2 if poor==0 & eth==4
replace poor_race=3 if poor==0 & eth==3
replace poor_race=4 if poor==0 & eth==2
replace poor_race=5 if poor==1 & eth==5
replace poor_race=6 if poor==1 & eth==4
replace poor_race=7 if poor==1 & eth==3
replace poor_race=8 if poor==1 & eth==2

label var poor_race "interaction race and poverty"
label define interaction 1 "NP white" 2 "NP black" 3 "NP hisp" 4 "NP asian" ///
	5 "poor white" 6 "poor black" 7 "poor hisp" 8 "poor asian", replace
label values poor_race ineraction

* create flow diagram
count //1129918

* district 1-32
count if district<=32 //1027067

* have home and school address
count if !missing(x) & !missing(x_sch) & district<=32 & ///
!missing(boro) & !missing(boro_sch) //888815

* have demographic info
count if !missing(x) & !missing(age) & !missing(grade) & !missing(bds) & ///
!missing(ethnic) & !missing(x_sch) & district<=32 & ///
eth!=6 & !missing(boro) & !missing(boro_sch) & !missing(native) //821854

* live more than half a mile from city border
count if !missing(x) & !missing(age) & !missing(grade) & !missing(bds) & ///
!missing(ethnic) & !missing(x_sch) & home>2640 & sch>2640 & district<=32 & ///
eth!=6 & !missing(boro) & !missing(boro_sch) & !missing(native) //789520

*** table 1 socio-demo
{
tab eth if $sample
tab poor if $sample

tab female if $sample
tab poor if $sample
tab native if $sample
tab sped if $sample
tab eng if $sample
tab lep if $sample
sum grade age if $sample
tab boro if $sample

* by race/ethnicity
forvalues race=2/5 {
	tab female if $sample & eth==`race'
	tab poor if $sample & eth==`race'
	tab native if $sample & eth==`race'
	tab sped if $sample & eth==`race'
	tab eng if $sample & eth==`race'
	tab lep if $sample & eth==`race'
	sum grade age if $sample & eth==`race'
	tab boro if $sample & eth==`race'
}
.

* by poverty status
foreach poor in 1 0 {
	tab female if $sample & poor==`poor'
	tab poor if $sample & poor==`poor'
	tab native if $sample & poor==`poor'
	tab sped if $sample & poor==`poor'
	tab eng if $sample & poor==`poor'
	tab lep if $sample & poor==`poor'
	sum grade age if $sample & poor==`poor'
	tab boro if $sample & poor==`poor'
}
.
}.

* table 2
* distance to nearest food outlet
sum BOD* FF* WS* C6P* if $sample, d
forvalues poor=0/1 {
	forvalues race=2/5 {
		sum BOD* FF* WS* C6P* if $sample & eth==`race' & poor==`poor'
	}
}
.

* make histograms to see why mean and median are different
{
hist nBOD1320 if $sample, bin(127) ///
	xtitle("Number of corner stores") title("Corner store") ///
	xlab(`=0' "0" `=50' "50" `=127' "max" `=25' "25" `=15.65' "mean", labsize(tiny))
graph save figures\histogram_corner_store.gph, replace
hist nFFOR1320 if $sample, bin(242) ///
	xtitle("Number of fast food restaurants") title("Fast food") ///
	xlab(`=0' "0" `=50' "50" `=100' "100" `=242' "max" `=17.31' "mean", labsize(tiny))
graph save figures\histogram_fast_food.gph, replace
hist nWS1320 if $sample, bin(220) ///
	xtitle("Number of wait service restaurants") title("Wait service") ///
	xlab(`=0' "0" `=50' "50" `=150' "150" `=50' "50" `=150' "150" `=220' "max" `=8.02' "mean", labsize(tiny))
graph save figures\histogram_wait_service.gph, replace
hist nC6P1320 if $sample, bin(10) ///
	xtitle("Number of supermarkets") title("Supermarket") ///
	xlab(`=0' "0" `=2' "2" `=5' "5" `=10' "max" `=1.19' "mean", labsize(tiny))
graph save figures\histogram_supermarket.gph, replace
}
.


eststo clear
estpost tabstat BOD FFOR WS C6P if $sample, by(eth) stats(sd) column(statistics)
esttab using test.rtf, cells("sd(fmt(%12.0f))") replace

* test statistical significance between diff races
* home
foreach var in BOD FF WS C6P {
	reg `var' i.poor_race if $sample
	pwcompare poor_race, mcompare(bon) effects
}
.
* school: clustered SE at bds level with bonferroni correction
foreach var in BOD FF WS C6P {
	reg `var'_sch i.poor_race if $sample, cluster(bds)
	pwcompare poor_race, mcompare(bon) effects
}
.

* table 3-5: num of food outlets within buffers
*** count num of food outlets from schools
foreach dist in 1320 528 2640 {
	sum nBOD`dist'_sch nFF`dist'_sch nWS`dist'_sch nC6P`dist'_sch if $sample
	bys eth: sum nBOD`dist'_sch nFF`dist'_sch nWS`dist'_sch nC6P`dist'_sch if $sample & poor==0
	bys eth: sum nBOD`dist'_sch nFF`dist'_sch nWS`dist'_sch nC6P`dist'_sch if $sample & poor==1
}

sum nBOD1320* nFFOR1320* nWS1320* nC6P1320* if $sample, d //get median

* t test
foreach dist in 1320 528 2640 {
	foreach var in BOD FF WS C6P {
		reg n`var'`dist'_sch i.poor_race if $sample, cluster(bds)
		pwcompare poor_race, mcompare(bon) effects
	}
}
.




/*
* compare school level resutls with old model (no clustered SE)
foreach dist in 1320 528 2640 {
	foreach var in BOD FF WS C6P {
		reg n`var'`dist'_sch i.poor_race if $sample
		pwcompare poor_race, mcompare(bon) effects
	}
}
. */

* home 
* count the num of food outlets
foreach dist in 1320 528 2640 {
	sum nBOD`dist' nFFOR`dist' nWS`dist' nC6P`dist' if $sample
	bys eth: sum nBOD`dist' nFF`dist' nWS`dist' nC6P`dist' if $sample & poor==0
	bys eth: sum nBOD`dist' nFF`dist' nWS`dist' nC6P`dist' if $sample & poor==1
}
.

* t test
foreach dist in 528 {
	foreach var in BOD FFOR WS C6P {
		reg n`var'`dist' i.poor_race if $sample
		pwcompare poor_race, mcompare(bon) effects
	}
}
.

*** t test schools, 1) poor vs non-poor; 2) race;
*** no interactions
* clustered SE
foreach dist in 1320 528 2640 {
	foreach x in poor ethnic2 {
		foreach var in BOD FFOR WS C6P {
			reg n`var'`dist'_sch i.`x' if $sample, cluster(bds)
			pwcompare `x', mcompare(bon) effects
		}
	}
}
.

foreach x in poor ethnic2 {
	foreach var in BOD FFOR WS C6P {
		reg `var'_sch i.`x' if $sample, cluster(bds)
		pwcompare `x', mcompare(bon) effects
	}
}
.

* no clustered SE
foreach dist in 1320 528 2640 {
	foreach x in poor ethnic2 {
		foreach var in BOD FFOR WS C6P {
			reg n`var'`dist'_sch i.`x' if $sample
			pwcompare `x', mcompare(bon) effects
		}
	}
}
.

foreach x in poor ethnic2 {
	foreach var in BOD FFOR WS C6P {
		reg `var'_sch i.`x' if $sample
		pwcompare `x', mcompare(bon) effects
	}
}
.

*pwmean FFOR_sch, over(i.poor_race) mcompare(bon) effects //with bonferroni correction
* joint f tests
tab poor_race if $sample, gen(poor_race)
foreach var in BOD FFOR WS C6P {
	reg `var'_sch poor_race1 poor_race2 poor_race3 poor_race4 ///
		poor_race5 poor_race6 poor_race7 poor_race8, cluster(bds)
	test poor_race1 poor_race2 poor_race3 poor_race4 ///
		poor_race5 poor_race6 poor_race7 poor_race8
}
.

foreach dist in 1320 528 2640 {
	foreach var in BOD FFOR WS C6P {
		reg n`var'`dist' poor_race1 poor_race2 poor_race3 poor_race4 ///
			poor_race5 poor_race6 poor_race7 poor_race8, cluster(bds)
		test poor_race1 poor_race2 poor_race3 poor_race4 ///
			poor_race5 poor_race6 poor_race7 poor_race8
	}
}
.

* count of food outlets in AY2013
* 2012-9-1: 19237
* 2013-8-31: 19601
* also re-align food ctegories
use "G:\Dr.Brian Elbel’s Projects\CURRENT PROJECTS\GEO R01\Data\Food Environment Data\food_sources_01032018.dta", clear
count if (start<19601 & (stop==.|stop>19601))|(start<19237 & (stop==.|stop>19237)) //42,841

keep no name address boronum category ingrading nosqft largechain estabno start stop
tab cat
count if missing(nosq) & ingra==0 //2768 stores
tab cat if missing(nosq) & ingra==0 //2768 stores

gen cat2="FFOR" if category=="Restaurant - Fast Food"|category=="Restaurant - Other"
replace cat2="WS" if category=="Restaurant - Wait Service"
replace cat2="C6P" if category=="Chain Supermarket"
replace cat2="C6P" if (category=="Ind Supermarket"|category=="Large Grocery"| ///
	category=="Small Grocery") & nosq>=6000
replace cat2="BOD" if category=="Bodega/Conv Store"|category=="Small Grocery"| ///
	(category=="Large Grocery" & nosqft<=6000)|(category=="Ind Supermarket" & nosqft<=6000)
replace cat2=category if missing(cat2)
tab cat2 if (start<19601 & (stop==.|stop>19601))|(start<19237 & (stop==.|stop>19237))


/*
* create poorXrace variable
gen poor_race=1 if poor==1 & eth==2
replace poor_race=2 if poor==1 & eth==3
replace poor_race=3 if poor==1 & eth==4
replace poor_race=4 if poor==1 & eth==5
replace poor_race=5 if poor==0 & eth==2
replace poor_race=6 if poor==0 & eth==3
replace poor_race=7 if poor==0 & eth==4
replace poor_race=8 if poor==0 & eth==5

label define poor_race 1 "poor Asian" 2 "poor Hisp" 3 "poor black" 4 "poor white" ///
 5 "non-poor Asian" 6 "non-poor Hisp" 7 "non-poor black" 8 "non-poor white", replace
label values poor_race poor_race
tab poor_race if $sample
forvalues i=1/8 {
	unique(bds) if $sample & poor_race==`i'
}
.
*/






