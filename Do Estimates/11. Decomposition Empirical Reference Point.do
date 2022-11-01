
/*
This DO-file estimates the decomposition model but using the first birth cohort as
reference point distribution instead of the common log-normal distribution.
These estimates are used to create Figure A8.
*/

/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

*  Decomposition

/*
See Do-file "1. Estimate Benchmark Absolute mobility.do" for details
on the section below
*/

clear

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

global TopAge = 			34
global AgeatBirth = 		34
global ParentChildKind = 	1
global ReportedIncome = 	1
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 
 

gen 	ParentChildKind = 1 if Father == 1 & Sex == 1 //Father-Son
replace ParentChildKind = 2 if Father == 0 & Sex == 2 //Mother-Dts
replace ParentChildKind = 3 if Father == 1 & Sex == 2 //Father-Dts
replace ParentChildKind = 4 if Father == 0 & Sex == 1 //Mother-Son

replace ChildEarning	=. if ChildEarning == 0
replace ParentEarning	=. if ParentEarning == 0

gen ReportedIncome = ChildEarning != . & ParentEarning != .

keep if Age <= 				$TopAge
keep if ParentAgeatBirth <= $AgeatBirth
keep if ParentChildKind == 	$ParentChildKind
keep if ReportedIncome >= 	$ReportedIncome

sort 	ChildID Age
bysort	ChildID: keep if _N > ($TopAge - 30)	

keep if BirthYearChild - $AgeatBirth + 30 >= 1968

sort 	ChildID ChildIncomeYear 
bysort	ChildID: ///
		egen MaxChildYear = max(ChildIncomeYear)
		
drop if MaxChildYear < (BirthYearChild + $TopAge)

drop MaxChildYear	

sort 		BirthYearChild ChildID
collapse 	(mean) ParentEarning ChildEarning, ///
			by(BirthYearChild ChildID)
			
sort 		BirthYearChild ParentEarning
bysort 		BirthYearChild: ///
			gen ParentRank = _n

gen ChildParentDiff = ChildEarning - ParentEarning
	
gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0
			
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)
			
drop AbsoluteMobility ChildParentDiff
				
rename meanAbsoluteMobility AM_${estimate}

******************************************************************

*cd "$user_main\Absolute Mobility\Extract"
*save "Temporary", replace

use "Temporary", clear

tempfile data5
save `data5', replace

preserve

rename ChildEarning 	meanChildEarning
rename ParentEarning 	meanParentEarning

collapse (mean) meanParentEarning meanChildEarning, by(BirthYearChild)
		
tempfile data3
save `data3', replace

restore

keep if BirthYearChild == 1972
drop BirthYearChild

expand 12

bysort ChildID: gen BirthYearChild = 1971 + _n

*sort BirthYearChild ParentEarning
*bysort 		BirthYearChild: ///
*			gen ParentRank = _n

merge m:1 BirthYearChild using `data3'

rename _merge merge1 
		
preserve

keep ChildID BirthYearChild ChildEarning ParentEarning 

sort BirthYearChild

* Creating random variable:
	
bysort 	BirthYearChild: ///
		gen rnormal = rnormal()
		
sort BirthYearChild rnormal

* Generating Parent rank variable that we later merge based on.

bysort 		BirthYearChild: ///
			gen ParentRank = _n
			
gen 	rsortParentRank = 	ParentRank		
rename 	ChildEarning		rsortChildEarning
rename 	ParentEarning		rsortParentEarning

tempfile data2
save `data2', replace

restore

merge 1:1 BirthYearChild ParentRank using `data2'
rename _merge merg2

merge m:1 BirthYearChild using `data3'
rename _merge merg3

gen MeanIncomeGrowth = meanChildEarning / meanParentEarning * ParentEarning

gen ChildParentDiff = MeanIncomeGrowth - rsortParentEarning

* Computing Absolute Mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)
			
collapse meanAbsoluteMobility, by(BirthYearChild)

rename meanAbsoluteMobility HomneousGr_${estimate}			

merge 1:m BirthYearChild using `data5'
drop _merge

preserve

keep ChildID BirthYearChild ChildEarning ParentEarning 

sort BirthYearChild
	
* Creating random variable:
	
bysort 	BirthYearChild: ///
		gen rnormal = rnormal()
		
sort BirthYearChild rnormal

* Generating Parent rank variable that we later merge based on.

bysort 		BirthYearChild: ///
			gen ParentRank = _n
			
gen 	rsortParentRank = 	ParentRank		
rename 	ChildEarning		rsortChildEarning
rename 	ParentEarning		rsortParentEarning

tempfile data2
save `data2', replace

restore

* Merging the randomly scrambled parent income distribution

merge 1:1 BirthYearChild ParentRank using `data2'
drop _merge

* Generating variable for cross generational growth

egen meanChildEarning = mean(ChildEarning), by(BirthYearChild)
egen meanParentEarning = mean(ParentEarning), by(BirthYearChild)

gen MeanIncomeGrowth = ///
	(meanChildEarning / meanParentEarning) * ParentEarning

* Generaing variable for difference in income between parent and child.
	
gen ChildParentDiff = MeanIncomeGrowth - rsortParentEarning

* Computing Absolute Mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility ObservedGr_${estimate}

* Dispersion

/*
Applying the dispersion component only requires that we compare 
the observed parent and child distributions but with the income ranks
randomly ordered (since we have not yet applied the exchange component)
*/

gen ChildParentDiff = ChildEarning - rsortParentEarning

* Computing absolute mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility  ///
		Dispersion_${estimate}
			
* Exchange

/*
The exchange component is simply the residual between the estimated
absolute mobility and the dispersion component.
*/

gen Exchange_${estimate} = AM_${estimate}
	
collapse (mean) ///
	HomneousGr_${estimate} ///
	ObservedGr_${estimate} ///
	Dispersion_${estimate} ///
	Exchange_${estimate}, ///
	by(BirthYearChild)
	
* Computing Marginal Contributions

gen Marg_HomneousGr_${estimate} = ///
	HomneousGr_${estimate} - 0.5

gen Marg_ObservedGr_${estimate} = ///
	ObservedGr_${estimate} - HomneousGr_${estimate}

gen Marg_Dispersion_${estimate} = ///
	Dispersion_${estimate} - ObservedGr_${estimate}

gen Marg_Exchange_${estimate} = ///
	Exchange_${estimate} - Dispersion_${estimate}
	
cd "$user_main\Absolute Mobility\Output Absolute Mobility"

save "Decomposition Empirical Parent TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", replace



/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

*  Decomposition

*forvalues a = 32(2)40 { 
*forvalues b = 32(2)38 {
*forvalues c = 1(1)4 {
*forvalues d = 0(1)1 {

******************************************************************

/*

See Do-file "1. Estimate Benchmark Absolute mobility.do" for details
about the section below

*/

clear

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

global TopAge = 			34
global AgeatBirth = 		34
global ParentChildKind = 	2
global ReportedIncome = 	1
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 
 

gen 	ParentChildKind = 1 if Father == 1 & Sex == 1 //Father-Son
replace ParentChildKind = 2 if Father == 0 & Sex == 2 //Mother-Dts
replace ParentChildKind = 3 if Father == 1 & Sex == 2 //Father-Dts
replace ParentChildKind = 4 if Father == 0 & Sex == 1 //Mother-Son

replace ChildEarning	=. if ChildEarning == 0
replace ParentEarning	=. if ParentEarning == 0

gen ReportedIncome = ChildEarning != . & ParentEarning != .

keep if Age <= 				$TopAge
keep if ParentAgeatBirth <= $AgeatBirth
keep if ParentChildKind == 	$ParentChildKind
keep if ReportedIncome >= 	$ReportedIncome

sort 	ChildID Age
bysort	ChildID: keep if _N > ($TopAge - 30)	

keep if BirthYearChild - $AgeatBirth + 30 >= 1968

sort 	ChildID ChildIncomeYear 
bysort	ChildID: ///
		egen MaxChildYear = max(ChildIncomeYear)
		
drop if MaxChildYear < (BirthYearChild + $TopAge)

drop MaxChildYear	

sort 		BirthYearChild ChildID
collapse 	(mean) ParentEarning ChildEarning, ///
			by(BirthYearChild ChildID)
			
sort 		BirthYearChild ParentEarning
bysort 		BirthYearChild: ///
			gen ParentRank = _n

gen ChildParentDiff = ChildEarning - ParentEarning
	
gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0
			
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)
			
drop AbsoluteMobility ChildParentDiff
				
rename meanAbsoluteMobility AM_${estimate}

******************************************************************

*cd "$user_main\Absolute Mobility\Extract"
*save "Temporary", replace

tempfile data5
save `data5', replace

preserve

rename ChildEarning 	meanChildEarning
rename ParentEarning 	meanParentEarning

collapse (mean) meanParentEarning meanChildEarning, by(BirthYearChild)
		
tempfile data3
save `data3', replace

restore

keep if BirthYearChild == 1972
drop BirthYearChild

expand 12

bysort ChildID: gen BirthYearChild = 1971 + _n

*sort BirthYearChild ParentEarning
*bysort 		BirthYearChild: ///
*			gen ParentRank = _n

merge m:1 BirthYearChild using `data3'

rename _merge merge1 
		
preserve

keep ChildID BirthYearChild ChildEarning ParentEarning 

sort BirthYearChild

* Creating random variable:
	
bysort 	BirthYearChild: ///
		gen rnormal = rnormal()
		
sort BirthYearChild rnormal

* Generating Parent rank variable that we later merge based on.

bysort 		BirthYearChild: ///
			gen ParentRank = _n
			
gen 	rsortParentRank = 	ParentRank		
rename 	ChildEarning		rsortChildEarning
rename 	ParentEarning		rsortParentEarning

tempfile data2
save `data2', replace

restore

merge 1:1 BirthYearChild ParentRank using `data2'
rename _merge merg2

merge m:1 BirthYearChild using `data3'
rename _merge merg3

gen MeanIncomeGrowth = meanChildEarning / meanParentEarning * ParentEarning

gen ChildParentDiff = MeanIncomeGrowth - rsortParentEarning

* Computing Absolute Mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)
			
collapse meanAbsoluteMobility, by(BirthYearChild)

rename meanAbsoluteMobility HomneousGr_${estimate}			

merge 1:m BirthYearChild using `data5'
drop _merge

preserve

keep ChildID BirthYearChild ChildEarning ParentEarning 

sort BirthYearChild
	
* Creating random variable:
	
bysort 	BirthYearChild: ///
		gen rnormal = rnormal()
		
sort BirthYearChild rnormal

* Generating Parent rank variable that we later merge based on.

bysort 		BirthYearChild: ///
			gen ParentRank = _n
			
gen 	rsortParentRank = 	ParentRank		
rename 	ChildEarning		rsortChildEarning
rename 	ParentEarning		rsortParentEarning

tempfile data2
save `data2', replace

restore

* Merging the randomly scrambled parent income distribution

merge 1:1 BirthYearChild ParentRank using `data2'
drop _merge

* Generating variable for cross generational growth

egen meanChildEarning = mean(ChildEarning), by(BirthYearChild)
egen meanParentEarning = mean(ParentEarning), by(BirthYearChild)

gen MeanIncomeGrowth = ///
	(meanChildEarning / meanParentEarning) * ParentEarning

* Generaing variable for difference in income between parent and child.
	
gen ChildParentDiff = MeanIncomeGrowth - rsortParentEarning

* Computing Absolute Mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility ObservedGr_${estimate}

* Dispersion

/*
Applying the dispersion component only requires that we compare 
the observed parent and child distributions but with the income ranks
randomly ordered (since we have not yet applied the exchange component)
*/

gen ChildParentDiff = ChildEarning - rsortParentEarning

* Computing absolute mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility  ///
		Dispersion_${estimate}
			
* Exchange

/*
The exchange component is simply the residual between the estimated
absolute mobility and the dispersion component.
*/

gen Exchange_${estimate} = AM_${estimate}
	
collapse (mean) ///
	HomneousGr_${estimate} ///
	ObservedGr_${estimate} ///
	Dispersion_${estimate} ///
	Exchange_${estimate}, ///
	by(BirthYearChild)
	
* Computing Marginal Contributions

gen Marg_HomneousGr_${estimate} = ///
	HomneousGr_${estimate} - 0.5

gen Marg_ObservedGr_${estimate} = ///
	ObservedGr_${estimate} - HomneousGr_${estimate}

gen Marg_Dispersion_${estimate} = ///
	Dispersion_${estimate} - ObservedGr_${estimate}
	

gen Marg_Exchange_${estimate} = ///
	Exchange_${estimate} - Dispersion_${estimate}
	
cd "$user_main\Absolute Mobility\Output Absolute Mobility"

save "Decomposition Empirical Parent TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", replace

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "12. Decomposition Single Year.do"
