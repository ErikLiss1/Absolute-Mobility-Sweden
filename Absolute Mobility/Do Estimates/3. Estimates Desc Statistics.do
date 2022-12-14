
/*

This Do-file estimates descriptive statistics for a number of 
different specifications. The results for the main specification is then used
to create Table 1 in the paper.

*/

/**************** Preamble: Set directories ****************/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

forvalues a = 30(2)40 { 
forvalues b = 32(2)38 {
forvalues c = 1(1)4 {
forvalues d = 0(1)1 {

clear

******************************************************************

/*

See Do-file "1. Estimate Benchmark Absolute mobility.do" for details
about the section below

*/

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

global TopAge = 			`a'
global AgeatBirth = 		`b'
global ParentChildKind = 	`c'
global ReportedIncome = 	`d'
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

/*
		
Generating Log earninga variable so that Intergenerational Income Elasticity can be estimated  

*/
		
gen logChildEarning = log(ChildEarning)
gen logParentEarning = log(ParentEarning)

* Generating variables that the loop then replace per birth cohort 
	
gen Obs = .
gen meanChildEarning = .
gen meanParentEarning = .
gen meanEarningRatio = .
gen b_RelativeMobility = .
gen se_RelativeMobility = .
gen ChildEarningGini = .
gen ParentEarningGini = .
gen b_Elasticity = .
gen se_Elasticity = .

* Loop that replac descriptive statistics for each birth year:

levelsof BirthYearChild, local(lvlsBirthYear)
		
foreach i of local lvlsBirthYear {

* Number of Obs

sum ChildID if BirthYearChild == `i'
replace Obs = r(N) if BirthYearChild == `i'

* Mean Income for Children and Parents

sum ChildEarning if BirthYearChild == `i'
replace meanChildEarning = r(mean) if BirthYearChild == `i'

sum ParentEarning if BirthYearChild == `i'
replace meanParentEarning = r(mean) if BirthYearChild == `i'

* Mean Child-Parent Income Ratio

replace meanEarningRatio = 	meanChildEarning / ///
							meanParentEarning ///
							if BirthYearChild == `i'

* Relative Mobiliy - Intergenerational income Rank correlation
		
reg ChildRank ParentRank if BirthYearChild == `i', r
replace b_RelativeMobility = _b[ParentRank] if BirthYearChild == `i'
replace se_RelativeMobility = _se[ParentRank] if BirthYearChild == `i'

* Relative Mobiliy - Intergenerational income Elasticity

reg logChildEarning logParentEarning if BirthYearChild == `i', r
replace b_Elasticity = _b[logParentEarning] if BirthYearChild == `i'
replace se_Elasticity = _se[logParentEarning] if BirthYearChild == `i'

* Gini:

fastgini ChildEarning if BirthYearChild == `i'
replace ChildEarningGini = r(gini) if BirthYearChild == `i'

fastgini ParentEarning if BirthYearChild == `i'
replace ParentEarningGini = r(gini) if BirthYearChild == `i'

}

* Collapse to get a table with agregate descriptive statistics for each birth cohort:

collapse 	(mean) Obs ///
			b_RelativeMobility se_RelativeMobility ///
			ChildEarningGini ParentEarningGini meanEarningRatio ///
			meanChildEarning meanParentEarning ///
			b_Elasticity se_Elasticity, by(BirthYearChild)

* Renaming each variable to separate each specification:
			
rename Obs Obs_${estimate}
rename meanChildEarning meanChildEarning_${estimate}
rename meanParentEarning meanParentEarning_${estimate}
rename meanEarningRatio meanEarningRatio_${estimate}
rename b_RelativeMobility bRM_${estimate}
rename se_RelativeMobility seRM_${estimate}
rename ChildEarningGini ChildEarningGini_${estimate}
rename ParentEarningGini ParentEarningGini_${estimate}
rename b_Elasticity b_Elasticity_${estimate}
rename se_Elasticity se_Elasticity_${estimate}

cd "$user_main\Absolute Mobility\Output Absolute Mobility"

save "Desc TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", replace
		
}
}	
}
}

* Merging all estimates to a single dataset:

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

collapse ChildID, by(BirthYearChild)
keep BirthYearChild

cd "$user_main\Absolute Mobility\Output Absolute Mobility"

forvalues a = 30(2)40 { 
forvalues b = 32(2)38 {
forvalues c = 1(1)4 {
forvalues d = 0(1)1 {

global TopAge = 			`a'
global AgeatBirth = 		`b'
global ParentChildKind = 	`c'
global ReportedIncome = 	`d'

merge 1:1 BirthYearChild using "Desc TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

}
}	
}
}

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
save "Desc Merged", replace

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "4. Estimates Decomposition.do"

