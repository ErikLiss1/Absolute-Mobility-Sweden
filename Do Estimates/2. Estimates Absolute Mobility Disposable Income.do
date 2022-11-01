/*

This Do-file calculates aboute mobility using dipsoable income 
instead of earnings as is used in the benchmark model. The do-file is a 
replica of the DO-file "1. Estimate Absolute Mobility benchmark", but with disposable income
instead of earnings used to calculate absolute mobility.

*/

/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

* Computing Absolute Mobility for Disposable Income

forvalues a = 32(2)34 { 
forvalues b = 32(2)34 {
forvalues c = 1(1)2 {
* forvalues d = 0(1)1 {

clear

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

global TopAge = 			`a'
global AgeatBirth = 		`b'
global ParentChildKind = 	`c'
global ReportedIncome = 	1
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

gen 	ParentChildKind = 1 if Father == 1 & Sex == 1 //Father-Son
replace ParentChildKind = 2 if Father == 0 & Sex == 2 //Mother-Dts
replace ParentChildKind = 3 if Father == 1 & Sex == 2 //Father-Dts
replace ParentChildKind = 4 if Father == 0 & Sex == 1 //Mother-Son

replace ChildDispIncome		=. if ChildDispIncome == 0
replace ParentDispIncome	=. if ParentDispIncome == 0

gen ReportedIncome = ChildDispIncome != . & ParentDispIncome != .

keep if Age <= 				$TopAge
keep if ParentAgeatBirth <= $AgeatBirth
keep if ParentChildKind == 	$ParentChildKind
keep if ReportedIncome >= 	$ReportedIncome

sort 	ChildID Age
bysort	ChildID: keep if _N > ($TopAge - 30)

keep if BirthYearChild - $AgeatBirth + 30 >= 1978

sort 	ChildID ChildIncomeYear 
bysort	ChildID: ///
		egen MaxChildYear = max(ChildIncomeYear)
		
drop if MaxChildYear < (BirthYearChild + $TopAge)

drop MaxChildYear

sort 		BirthYearChild ChildID
collapse 	(mean) ParentDispIncome ChildDispIncome, ///
			by(BirthYearChild ChildID)

gen ChildParentDiff = ChildDispIncome - ParentDispIncome
	
gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

collapse 	(mean) AbsoluteMobility, ///
			by(BirthYearChild)
			
rename AbsoluteMobility AM_${estimate}

cd "$user_main\Absolute Mobility\Output Absolute Mobility"

save "Absolute Mobility DispIncome TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", replace
		
}
}	
}
* }

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

collapse ChildID, by(BirthYearChild)
keep BirthYearChild

cd "$user_main\Absolute Mobility\Output Absolute Mobility"

forvalues a = 32(2)34 { 
forvalues b = 32(2)34 {
forvalues c = 1(1)2 {
* forvalues d = 0(1)1 {

global ParentChildKind = 	`c'

merge 1:1 BirthYearChild using "Absolute Mobility DispIncome TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

}
}	
}
* }

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
save "Absolute Mobility DispIncome Merged", replace

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "3. Estimates Desc Statistics.do"

