
/**************** Preamble: Set directories ****************/

// user specific paths
global user_main " " // Your working directory

/***********************************************************/
*

foreach y in par {
forvalues k = 1940(1)1984 {

use "${user_main}/Samples/`y'_sample_`k'.dta", clear

keep year income 
replace year = `k'

sort income

drop if income <= 0

* gen rank = _n

rename income parent_income

fastgini parent_income

gen USGini = r(gini)

gen randomdistribution = runiform()

sort randomdistribution

gen rank = _n

tempfile Child
save `Child', replace

foreach i in 001 005 01 02 03 04 {

use "${user_main}/Samples/`y'_sample_`k'.dta", clear

keep year income 

sort income
replace year = `k'

drop if income <= 0

gen rank = _n

rename income child_income

merge 1:1 rank using `Child', nogen

gen GenerationN = 30

gen Growth`i'= child_income*(1.`i'^GenerationN)

gen ChildParentDiff`i' = Growth`i' - parent_income

gen AbsoluteMobility`i' = 1 if  ChildParentDiff`i' >= 0
replace AbsoluteMobility`i' = 0 if  ChildParentDiff`i' < 0

keep AbsoluteMobility`i' year USGini 
collapse USGini AbsoluteMobility`i', by(year)

tempfile l`i'
save `l`i''

}

use "`l001'", clear

foreach i in 005 01 02 03 04 {
	
merge 1:1 year using `l`i'', nogen

}

tempfile l`k'
save `l`k'', replace

}

use "`l1940'", clear

forvalues k = 1941(1)1984 {
	
append using "`l`k''"

}

save "${user_main}/Samples/`y' Estimates from US Samples", replace

}

use "${user_main}/Samples/par Estimates from US Samples", clear

rename AbsoluteMobility001 AbsoluteMobility1
rename AbsoluteMobility005 AbsoluteMobility5
rename AbsoluteMobility01 AbsoluteMobility10
rename AbsoluteMobility02 AbsoluteMobility20
rename AbsoluteMobility03 AbsoluteMobility30
rename AbsoluteMobility04 AbsoluteMobility40

reshape long AbsoluteMobility, i(year USGini) j(GrowthRate)

gen Sample = 3

rename USGini Gini
rename year BirthYearChild

save "${user_main}/Do Parent Dispersion Effect/Samples/par Estimates from US Samples", replace
