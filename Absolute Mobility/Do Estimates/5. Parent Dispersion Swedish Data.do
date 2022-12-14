

/*

This do file estimates the parent dispersion component for swedish mothers and 
fathers. This is later used to compare against the swedish paent dispersion component
against parent dispersion component for  US parent distribution.

*/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

* Setting benchmark specifications:

global TopAge = 			34
global AgeatBirth = 		34
global ReportedIncome = 	1

********************

/*

See Do-file "1. Estimate Benchmark Absolute mobility.do" for details
about the section below

*/

forvalues c = 1(1)2 {

clear

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

global TopAge = 			34
global AgeatBirth = 		34
global ReportedIncome = 	1
global ParentChildKind = 	`c'
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

* Calculating benchmark absolute mobility:
			
gen ChildParentDiff = ChildEarning - ParentEarnin

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0
			
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)
			
drop AbsoluteMobility ChildParentDiff
		
* Renaming absolute mobility to which specification used:
		
rename meanAbsoluteMobility AM_${estimate}


/*

Now calculating the parent dispersoin component for different cumulated growth 
rates over 30 years, conditioning on intergeneratoinal income correlation at 0.

*/

preserve

keep ChildID BirthYearChild ChildEarning ParentEarning 

/*

Setting intergenerational income correlation to 0:

*/


sort BirthYearChild	
bysort 	BirthYearChild: ///
		gen rnormal = rnormal()
		
sort BirthYearChild rnormal
bysort 		BirthYearChild: ///
			gen ParentRank = _n
			
/*

In case we want to later insect the randomization we will create randomized 
earning  variables with the name rsort

*/
	
gen 	rsortParentRank = 	ParentRank		
rename 	ChildEarning		rsortChildEarning
rename 	ParentEarning		rsortParentEarning

tempfile data2
save `data2', replace

restore

/*

We now merge the randomized earning variables into the 

*/

merge 1:1 BirthYearChild ParentRank using `data2'

drop _merge

* growth is acumulated across 30 years:

gen GenerationN = 30

* We use growth rates 0.1%, 0.5%, 1%, 2%, 3%, 4%.

foreach i in 001 005 01 02 03 04 {
	
* Generating variable for Earning mulitplied by cumulative growth rate:

gen Growth`i'= ParentEarning*(1.`i'^GenerationN)

* Calculating absolute mobility:

gen ChildParentDiff`i' = Growth`i' - rsortParentEarning

gen AbsoluteMobility`i' = 1 if  ChildParentDiff`i' >= 0
replace AbsoluteMobility`i' = 0 if  ChildParentDiff`i' < 0
			
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility`i' = mean(AbsoluteMobility`i')

* Renaming absolute mobility to the specific growth rate used:
			
drop Growth`i' AbsoluteMobility`i'
rename meanAbsoluteMobility`i' AbsoluteMobility`i'

}

* We collapse all estimate by birth cohort:

collapse (mean) AbsoluteMobility*, by(BirthYearChild)

rename AbsoluteMobility001 AbsoluteMobility1
rename AbsoluteMobility005 AbsoluteMobility5
rename AbsoluteMobility01 AbsoluteMobility10
rename AbsoluteMobility02 AbsoluteMobility20
rename AbsoluteMobility03 AbsoluteMobility30
rename AbsoluteMobility04 AbsoluteMobility40

* Because the US Sample is in long format, we will also change this data set to long:

reshape long AbsoluteMobility, i(BirthYearChild) j(GrowthRate)

* To get the Gini coefficient, we merged with the desciptive table:

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
merge m:m BirthYearChild using "Desc TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate keepusing(ParentEarningGini_${estimate})

gen Sample = `c'
rename ParentEarningGini_${estimate} Gini

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
save "Growth_Elasticity_${estimate}.dta", replace

}

* Appending men and women's results:

global TopAge = 			34
global AgeatBirth = 		34
global ReportedIncome = 	1
global ParentChildKind = 	1
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Growth_Elasticity_${estimate}.dta", clear

global ParentChildKind = 	2
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

append using "Growth_Elasticity_${estimate}.dta"

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
save "Growth_Elasticity_${estimate}.dta", replace

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "6. Payroll tax Absolute Mobility.do"
