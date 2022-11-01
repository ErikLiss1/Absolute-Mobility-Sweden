
/*
This do-file estimates the counterfactual absolute mobility rate by holding 
parent and child generation female labor fore participation rate fixed.
*/


/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working 
global connectionstring "" // Your connectionstring to SCL Server

/***********************************************************/

clear

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

* We use the benchmark settings.

global TopAge = 			34
global AgeatBirth = 		34
global ParentChildKind = 	2
global ReportedIncome = 	1
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

/*
See Do-file "1. Estimate Benchmark Absolute mobility.do" for details
on the section below
*/

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

* We merge with the yearly labor force threshold. First the Child generation:
			
rename ChildIncomeYear Year 

cd "$user_main\Absolute Mobility/Extract"
merge m:1 Year using "Labor Force Threshold.dta"

keep if _merge == 3
drop _merge

rename Year ChildIncomeYear 
rename LaborThreshold LaborThresholdChild

* Inflation adjusting the child generation labor force threshold

merge m:1 	ChildIncomeYear using "SwedenCPIIndexYearlyFrom1949.dta", ///
			keepusing(CPIIndexYearlyMean)
			
drop if _merge == 2
drop _merge

* Changing the base year to 2010:

gen CPIIndexCYearly2010 = CPIIndexYearlyMean / 1733

* Inflation adjusting by dividing by CPI:

replace LaborThresholdChild = LaborThresholdChild/CPIIndexCYearly2010
drop CPIIndexCYearly2010 CPIIndexYearlyMean

* We merge with the yearly labor force threshold for the parent generation:

rename ParentIncomeYear Year

cd "$user_main\Absolute Mobility/Extract"
merge m:1 Year using "Labor Force Threshold.dta"

keep if _merge == 3
drop _merge

rename Year ParentIncomeYear 
rename LaborThreshold LaborThresholdParent

* Inflation adjusting the parent generation labor force threshold

merge m:1 	ParentIncomeYear using "SwedenCPIIndexYearlyFrom1949.dta", ///
			keepusing(CPIIndexYearlyMean)
			
drop if _merge == 2
drop _merge

* Changing the base year to 2010:

gen CPIIndexCYearly2010 = CPIIndexYearlyMean / 1733

* Inflation adjusting by dividing by CPI:

replace LaborThresholdParent = LaborThresholdParent/CPIIndexCYearly2010
drop CPIIndexCYearly2010 CPIIndexYearlyMean

* Collapsing yearly earnings and participation tresholds to get lifetime proxy

sort 		BirthYearChild ChildID
collapse 	(mean) LaborThresholdParent LaborThresholdChild ///
			ParentEarning ChildEarning, ///
			by(BirthYearChild ChildID)
			
* Creating dummy for if parent is working
			
gen WorkingParent = 1 if ParentEarning >= LaborThresholdParent
replace WorkingParent = 0 if ParentEarning < LaborThresholdParent

* Creating dummy for if child is working

gen WorkingChild = 1 if ChildEarning >= LaborThresholdChild
replace WorkingChild = 0 if ChildEarning < LaborThresholdChild

* Generate Parent Income Rank (needed for simulation)

sort 		BirthYearChild ParentEarning
bysort 		BirthYearChild: ///
			gen ParentRank = _n

* Calculate Benchmark Absolute Mobility (needed for simulation)

gen ChildParentDiff = ChildEarning - ParentEarning
	
gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0
			
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)
			
drop AbsoluteMobility ChildParentDiff
				
rename meanAbsoluteMobility AM_${estimate}

*****************************************************************

* Generating variables that we later replace in loop by birth cohort:

* Generating variables that we later replace in loop by birth cohort:

gen meanChildEarning = .
gen meanParentEarning = .

foreach k in 0 1 {

gen GroupMeanChild`k' = .
gen GroupMeanParent`k' = .

gen WorkerParent`k'_Count = .
gen WorkerChild`k'_Count = .

gen WorkerChild`k'_Perc = .
gen WorkerParent`k'_Perc = .

}

levelsof BirthYearChild, local(lvlsBirthYear)
foreach i of local lvlsBirthYear {
	
sum ChildEarning if BirthYearChild == `i'
replace meanChildEarning = r(mean) if BirthYearChild == `i'

sum ParentEarning if BirthYearChild == `i'
replace meanParentEarning = r(mean) if BirthYearChild == `i'

foreach k in 0 1 {

sum ChildEarning if WorkingChild == `k' & BirthYearChild == `i'

* Calculate group means for working and not working in child generations
replace GroupMeanChild`k' = r(mean) if BirthYearChild == `i'

* Count working and not working children by birth cohort
replace WorkerChild`k'_Count = r(N) if BirthYearChild == `i'

sum ParentEarning if WorkingParent == `k' & BirthYearChild == `i'

* Calculate group means for working and not working in parent generations
replace GroupMeanParent`k' = r(mean) if BirthYearChild == `i'

* Count working and not working parents by birth cohort
replace WorkerParent`k'_Count = r(N) if BirthYearChild == `i'

}

foreach k in 0 1 {

* Calculate percentage working in child generation:
replace WorkerChild`k'_Perc = WorkerChild`k'_Count / (WorkerChild0_Count + WorkerChild1_Count) if BirthYearChild == `i'

* Calculate percentage not working in parent generation:
replace WorkerParent`k'_Perc = WorkerParent`k'_Count / (WorkerParent0_Count + WorkerParent1_Count) if BirthYearChild == `i'

}
}

tempfile master
save `master', replace

/*

We first simulate absolute mobility holding the distribution across cohorts and
generations fixed, as well as holding the mean income growth and to the level 
it would have been if participation would have been fixed to the level of 
the first birth cohort's mother generation.

*/

* Creating a variable containing the mean of the first birth cohort's mother generation.

sum WorkerParent1_Perc if WorkingParent == 1 & BirthYearChild == 1973
local mean = r(mean)

gen Working1973 = `mean'

/*
Cross generational growth is adjusted from (mean child earning / mean parent earning)
into the group mean of workers and non workers, but weights for workers are
fixed to Working1973 and weights of non workers are fixed to 1-Working1973.
*/

gen NewGrowth = (GroupMeanChild1 * Working1973 + GroupMeanChild0 * (1-Working1973)) / ///
				(GroupMeanParent1 * Working1973 + GroupMeanParent0 * (1-Working1973)) ///

				
* Saving estimates:	

preserve
		
collapse (mean) NewGrowth meanParentEarning meanChildEarning, by(BirthYearChild)
				
tempfile data3
save `data3', replace


/*
Since we want to hold the distribution fixed we create fictive distributions
for all birth cohorts that are replicas of the 1972 parent generation cohorts.
*/

restore

keep if BirthYearChild == 1972

* Only keep year and parent earning variables:
drop BirthYearChild NewGrowth meanChildEarning meanParentEarning

* Expand creates 12 replicas:

expand 12

* generate birth cohort years:

bysort ChildID: gen BirthYearChild = 1971 + _n

* We now merge the replicas to the counterfactual growth rate holding participation constant:

merge m:1 BirthYearChild using `data3'

rename _merge merge1 
	
preserve

keep ChildID BirthYearChild ChildEarning ParentEarning 

sort BirthYearChild

* Rank changes are random, thus creating a random variable:
	
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

* Merging to random ranks:

merge 1:1 BirthYearChild ParentRank using `data2'

rename _merge merge2

/*

We have two different simulated child distributions: 

1. One where the mothers to the first birth cohort is multiplied by the empirical mean income growth: (mean child earning / mean parent earning)

2. Another where growth is the weighted sum when holding participation fixed where 
weights for workers are fixed to Working1973 and weights of 
non workers are fixed to 1-Working1973.

*/

gen MeanIncomeGrowth = ///
	(meanChildEarning / meanParentEarning) * ParentEarning
	
gen MeanIncomeGrowth2 = ///
	ParentEarning * NewGrowth
	
* Generating variable for difference in income for specification 1.
	
gen ChildParentDiff = MeanIncomeGrowth - rsortParentEarning

* Computing Absolute Mobility for specification 1.

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility ObservedGr_1

* Generating variable for difference in income for specification 2.

gen ChildParentDiff = MeanIncomeGrowth2 - rsortParentEarning

* Computing absolute mobility for specification 2.

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility ObservedGr_2

* We collapse the results by birth cohort and then merge with the starting dataset:

collapse ObservedGr_1 ObservedGr_2, by(BirthYearChild)

merge 1:m BirthYearChild using `master' 

/*
Next, we allow the parent distribution to change across cohorts (still holding 
the shape of the distribution constant across generations). We do this by 
using the empirical parent distributions and add the cross generational
growth rate (ranks are random).
*/

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

* Merging the randomly reordered parent income distribution

merge 1:1 BirthYearChild ParentRank using `data2'
drop _merge

* Multyplying the empirical cross generational growth rate:

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
			
rename meanAbsoluteMobility ObservedGr_3

* Collapsing and saving all estimates:

collapse ObservedGr_1 ObservedGr_2 ObservedGr_3, by(BirthYearChild)

cd "$user_main\Absolute Mobility\Estimates"
save "Female Labor Participation Counterfactuals"

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "11. Decomposition Empirical Reference Point.do"
