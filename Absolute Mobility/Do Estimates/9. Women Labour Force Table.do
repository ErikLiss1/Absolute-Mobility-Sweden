
/*****

This Do-file generates descriptive statistics for labor force participation.

*****/

/**************** Preamble: Set directories ****************/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

/*

See Do-file "1. Estimate Benchmark Absolute mobility.do" for details
about the section below

*/

clear

forvalues c = 1(1)2 {

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

* We use the benchmark specifications, for both father-sons and mothers-daughters.

global TopAge = 			34
global AgeatBirth = 		34
global ParentChildKind = 	`c'
global ReportedIncome = 	0
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

***** Separating between working and not working:
			
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

replace LaborThresholdChild = LaborThresholdChild / CPIIndexCYearly2010
drop CPIIndexCYearly2010 CPIIndexYearlyMean

* We merge with the yearly labor force threshold for the parent generation:

rename ParentIncomeYear Year 

cd "$user_main\Absolute Mobility/Extract"
merge m:1 Year using "Labor Force Threshold.dta"

keep if _merge == 3
drop _merge

rename Year ParentIncomeYear 
rename LaborThreshold LaborThresholdParent

* Inflation adjusting the child generation labor force threshold

merge m:1 	ParentIncomeYear using "SwedenCPIIndexYearlyFrom1949.dta", ///
			keepusing(CPIIndexYearlyMean)
			
drop if _merge == 2
drop _merge

* Changing the base year to 2010:

gen CPIIndexCYearly2010 = CPIIndexYearlyMean / 1733

* Inflation adjusting by dividing by CPI:

replace LaborThresholdParent = LaborThresholdParent/CPIIndexCYearly2010
drop CPIIndexCYearly2010 CPIIndexYearlyMean

******************************************************************

* Collapsing yearly earnings and participation tresholds to get lifetime proxy

sort 		BirthYearChild ChildID
collapse 	(mean) LaborThresholdParent LaborThresholdChild ///
			ParentEarning ChildEarning, ///
			by(BirthYearChild ChildID Father Sex)
			
* Creating dummy for if parent is working
			
gen WorkingParent = 1 if ParentEarning >= LaborThresholdParent
replace WorkingParent = 0 if ParentEarning < LaborThresholdParent

* Creating dummy for if child is working

gen WorkingChild = 1 if ChildEarning >= LaborThresholdChild
replace WorkingChild = 0 if ChildEarning < LaborThresholdChild

* Generating variables that we later replace in loop by birth cohort:

gen WithinGiniParent = .
gen BetweenGiniParent = .

gen WithinGiniChild = .
gen BetweenGiniChild = .

gen WithinGiniParentWork1 = .
gen WithinGiniChildWork1 = .

gen WithinGiniParentWork0 = .
gen WithinGiniChildWork0 = .

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

**********************

* Calculate Gini within and between workers and not workers in parent generation:

ginidesc 	ParentEarning if BirthYearChild == `i', ///
			by(WorkingParent) m(Mat1) gkmat(Vect1) 
			
local Within = Mat1[3,1]
local Between = Mat1[2,1]
local WithinWorker0 = Vect1[1,2]
local WithinWorker1 = Vect1[2,2]

replace WithinGiniParent = `Within' if BirthYearChild == `i'
replace BetweenGiniParent = `Between' if BirthYearChild == `i'
replace WithinGiniParentWork0 = `WithinWorker0' if BirthYearChild == `i'
replace WithinGiniParentWork1 = `WithinWorker1' if BirthYearChild == `i'

* Calculate Gini within and between workers and not workers in child generation:

ginidesc 	ChildEarning if BirthYearChild == `i', ///
			by(WorkingChild) m(Mat2) gkmat(Vect2) 
			
local Within = Mat2[3,1]
local Between = Mat2[2,1]
local WithinWorker0 = Vect2[1,2]
local WithinWorker1 = Vect2[2,2]

replace WithinGiniChild = `Within' if BirthYearChild == `i'
replace BetweenGiniChild = `Between' if BirthYearChild == `i'
replace WithinGiniChildWork0 = `WithinWorker0' if BirthYearChild == `i'
replace WithinGiniChildWork1 = `WithinWorker1' if BirthYearChild == `i'

}

* Collapsing results so that we get aggregated results in a single table:

collapse 	(mean) AM_34_34_$ParentChildKind_1 WithinGiniParent BetweenGiniParent WithinGiniChild BetweenGiniChild WithinGiniParentWork0 WithinGiniParentWork1 WithinGiniChildWork0 WithinGiniChildWork1 GroupMeanChild0 GroupMeanParent0 WorkerParent0_Count WorkerChild0_Count WorkerChild0_Perc WorkerParent0_Perc GroupMeanChild1 GroupMeanParent1 WorkerParent1_Count WorkerChild1_Count WorkerChild1_Perc WorkerParent1_Perc, by(BirthYearChild)
	
cd "$user_main\Absolute Mobility\Output Absolute Mobility"
save "Desc Labour Force Participation TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", replace

}

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "10. Women Labour Force Counterfactual.do"
