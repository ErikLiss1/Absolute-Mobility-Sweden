
/* 

This DO-file does the following:

1. Merges all the income and background data for fathers, mothers & children to a single dataset. We start by loading the containing Child, Father and Mother ID numbers.
We then merge the child, father and mother income data to the same row and can easily be compared. Each child-father and child-mother combination is a separate observation. All non-matches is removed.
If a child has both a mother and father in the register, there will be two 
separate observations.

2. Inflation adjusts incomes to 2010 CPI levels.

3. Renames all variables to english.

The end product therefore constitutes the final dataset used to estimate 
absolute mobility

*/


/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

clear  

/* We start with the dataset containing the ID for all Children 
and their parents */

cd "$user_main\Absolute Mobility\Extract"
use "Merged_Bakgrund_Flergen.dta", clear

keep 	PersonLopNr FodelseAr ///
		LopNrFar FodelseArFar ///
		LopNrMor FodelseArMor ///
		Kon
		
/* 

We merge the data on child background variables and incomes. The background data only has one observation per individual, but the income data has annual data. This means that we will merge 1:m against the income dataset.

*/

cd "$user_main\Absolute Mobility\Extract"
merge 1:m PersonLopNr using "Flergen Income Merged Child.dta", ///
gen(ChildMerge)

* Renaming child variables to english:

rename ForvInk ChildEarning
rename DispInk ChildDispIncome
rename Ar ChildIncomeYear
rename FodelseAr BirthYearChild

/* 

We merge against the data set containing income and background data for fathers.
Since there there could be more than one child per father, we will merge 
using 1:m.

*/

merge m:1 LopNrFar Age using "Flergen Income Merged Father.dta", ///
gen(ParentMerge)

* We create a dummy for Child-Fathers pairs:

gen Father = 1

* We create a variable for parent age at child birth:

gen ParentAgeatBirth = BirthYearChild - FodelseArFar

* Translating variables to english:

rename ForvInk ParentEarning
rename DispInk ParentDispIncome
rename LopNrFar ParentID
rename FodelseArFar BirthYearParent
rename Ar ParentIncomeYear
rename Kon Sex
rename PersonLopNr ChildID

* Removing variables relating to mothers since they will be appended later:

drop LopNrMor FodelseArMor

tempfile data1
save `data1', replace

clear  

* We now do the same procedure for women: 

cd "$user_main\Absolute Mobility\Extract"
use "Merged_Bakgrund_Flergen.dta", clear

keep 	PersonLopNr FodelseAr ///
		LopNrFar FodelseArFar ///
		LopNrMor FodelseArMor ///
		Kon

******  Merging Child With Mother Incomes ******

cd "$user_main\Absolute Mobility\Extract"

merge 1:m PersonLopNr using "Flergen Income Merged Child.dta", ///
gen(ChildMerge)

rename ForvInk ChildEarning
rename DispInk ChildDispIncome
rename Ar ChildIncomeYear
rename FodelseAr BirthYearChild

merge m:1 LopNrMor Age using "Flergen Income Merged Mother.dta", ///
gen(ParentMerge)

gen Father = 0
gen ParentAgeatBirth = BirthYearChild - FodelseArMor

rename ForvInk ParentEarning
rename DispInk ParentDispIncome
rename LopNrMor ParentID
rename FodelseArMor BirthYearParent
rename Ar ParentIncomeYear
rename Kon Sex
rename PersonLopNr ChildID

drop LopNrFar FodelseArFar

* Append the child-father pairs to the child-mother pairs:

append using `data1'

* Removing unmatched observations:

keep if ChildMerge == 3 | ParentMerge == 3
drop ChildMerge ParentMerge

/*

Inflation Adjusting child incomes. We do this by merging all yearly 
income observations for each individual to each CPI year. This means that we
merge using m:1.

*/

merge m:1 ChildIncomeYear using "SwedenCPIIndexYearlyFrom1949.dta"
drop if _merge == 2
drop _merge

* Changing the base year to 2010:

gen CPIIndexCYearly2010 = CPIIndexYearlyMean / 1733

* Inflation adjusting by dividing by CPI:

replace ChildEarning = ChildEarning/CPIIndexCYearly2010
replace ChildDispIncome = ChildDispIncome/CPIIndexCYearly2010

drop CPIIndexCYearly2010 CPIIndexYearlyMean

/*

We repeat the procedure but for the parent incomes. This is done separately since 
parents and their children will earn their incomes at different points in time.
Each observation therefore shows the income of the child and parent att different
years but, at the same age. 

*/

merge m:1 ParentIncomeYear using "SwedenCPIIndexYearlyFrom1949.dta"
drop if _merge == 2
drop _merge

gen CPIIndexCYearly2010 = CPIIndexYearlyMean / 1733
replace ParentEarning = ParentEarning/CPIIndexCYearly2010
replace ParentDispIncome = ParentDispIncome/CPIIndexCYearly2010

drop CPIIndexCYearly2010 CPIIndexYearlyMean Ar

cd "$user_main\Absolute Mobility\Extract"
save "Children, Fathers, Mothers Merged", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Extract"
doedit "9. Household Data.do"

