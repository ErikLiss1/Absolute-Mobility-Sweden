
/*

We estimate aboslute mobility for a number of different spcifications using the following globals:

TopAge: Top age 30 means that we estimate Absolute mobility at Age 30. Top age 32 means 
that we estimate aboslute mobility of avering incomes between age 30 to 32. 
Age income spans estaimted are 30, 30-32, 30-34, 30-36, 30-38, 30-40. 
AgeatBirth: Maximum parent age at child birth span: 32, 34, 36, 38. In this case, 32 means
that we only include a parent that was between age 18-32 when the child was born.
AgeatBirth=34 means we only include a parent that was between age 18-34 and so on.
ParentChildKind: 4 different child-parent combinations:

1: Father-Son
2: Mother-Dts
3: Father-Dts
4: Mother-Son

We estimate absolute mobility for all these combinations but only report 
combination 1 and 2 in the paper.
Note that we estimate absolute mobility on household level in another 
DO-file (see do-file "8. HouseHold Estimates")

ReportedIncome: We estimate absolute mobility both removing individuals
with no taxable income in a year (1) , and including these (0).

*/


/**************** Preamble: Set directories ****************/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

* Computing Absolute Mobility:

forvalues a = 30(2)40 { 
forvalues b = 32(2)38 {
forvalues c = 1(1)4 {
forvalues d = 0(1)1 {

clear

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

global TopAge = 			`a'
global AgeatBirth = 		`b'
global ParentChildKind = 	`c'
global ReportedIncome = 	`d'

gen 	ParentChildKind = 1 if Father == 1 & Sex == 1 //Father-Son
replace ParentChildKind = 2 if Father == 0 & Sex == 2 //Mother-Dts
replace ParentChildKind = 3 if Father == 1 & Sex == 2 //Father-Dts
replace ParentChildKind = 4 if Father == 0 & Sex == 1 //Mother-Son

* Change zero income earnings to missing:

replace ChildEarning	=. if ChildEarning == 0
replace ParentEarning	=. if ParentEarning == 0

* Generating dummy variable if either children or parent earning is missing:

gen ReportedIncome = ChildEarning != . & ParentEarning != .

* Removing observations outside of the chosen age span:
keep if Age <= 				$TopAge

* Remove obs in which parent is older than the max parent age at child birth: 
keep if ParentAgeatBirth <= $AgeatBirth

* Keep only observations with the given child-parent pair type:
keep if ParentChildKind == 	$ParentChildKind

* Including or excluding missing earnings:
keep if ReportedIncome >= 	$ReportedIncome

/*

Since we in the Reported Income=1 specification only want to incluce child-parent pairs in which we have non-missing 
incomes for ALL years, we must remove any Child-Parent pair in which the 
number of income years is below that of the number of income years within the
specified income span.

*/
 
sort 	ChildID Age
bysort	ChildID: keep if _N > ($TopAge - 30)

/*

The first cohort that we can estimate absolute mobility for depends on which 
year that is the first year for which we have income data for, which is 1968. Also recall that cohorts must include income data for when the parent in 30 years of age. The first cohort we can estimate absolute mobility for is therefore determined 
by that the parent with the highest possible age at child birth is at least
30 years old in year 1968:

*/

keep if BirthYearChild - $AgeatBirth + 30 >= 1968

/*

In a few instances, the income of a individual is registered a year late, 
meaning that even though we removed observations where the individuals are
older or younger than the specified income span, we still have some income years
included when the individual is older than this since their income was registered
a year late. We therefore remove these income years.

*/

sort 	ChildID ChildIncomeYear 
bysort	ChildID: ///
		egen MaxChildYear = max(ChildIncomeYear)
		
drop if MaxChildYear < (BirthYearChild + $TopAge)

drop MaxChildYear

/*

We now collapse all observations so that we get the average income of the
individual for the specific years. 

*/

sort 		BirthYearChild ChildID
collapse 	(mean) ParentEarning ChildEarning, ///
			by(BirthYearChild ChildID)

* Calculating absolute mobility for each individual:
			
gen ChildParentDiff = ChildEarning - ParentEarning
	
gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

* Collapsing to get absolute mobility per birthcohort 

collapse 	(mean) AbsoluteMobility, ///
			by(BirthYearChild)
			
* Renaming absolute mobility variable to the specification used in this loop:
			
rename AbsoluteMobility AM_${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome}

cd "$user_main\Absolute Mobility\Output Absolute Mobility"

save "Absolute Mobility TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", replace
		
}
}	
}
}

/*

Below we create a dataset containing all absolute mobility estaimtes givencombinationsby all the combinations of specifciation above: 

*/

/*

We start by collapsing all birth cohorts so that we could merge by birth 
cohort to this dataset.

*/

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

* Merging each collapsed absolute mobility specification to a single data set:

merge 1:1 BirthYearChild using "Absolute Mobility TopAge $TopAge AgeatBirth $AgeatBirth ReportedIncome $ReportedIncome", nogenerate

}
}	
}
}

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
save "Absolute Mobility Merged", replace

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "2. Estimates Absolute Mobility Disposable Income.do"
