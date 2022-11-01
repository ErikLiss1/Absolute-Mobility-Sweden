
/***********************************************************

This DO-file merges income data with the background data for mothers.
We repeat this procedure for children and mothers so that we have the
income and background data for all three. These three can then easily be merged
together to a single dataset where we can compare child and parent incomes. 
This is for the individual earning comparon only. 
See Do-file "Household level" for how Household dataset is created.

***********************************************************/

***********************************************************/


/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working Directory
global connectionstring "" // Your connectionstring to SCL Server

/***********************************************************/


/* 
Using these globals will allow us to make the DO-files for children, fathers &
mothers similar.
*/

global Targetgroup Mother
global TargetVar LopNrMor
global TargetBirthYear FodelseArMor

cd "$user_main\Absolute Mobility\Extract"
use "Merged_Bakgrund_Flergen.dta", clear

/* 
We only need the variables Mother's ID number, birth year and sex from the background data set:
*/

keep $TargetVar $TargetBirthYear

rename $TargetVar PersonLopNr

/* 

Merging the background data with the income data. Since each parent can have more than one child, there will be more than one observation per parent. The income tax data has annual income data so it will also have more than one observation per parent. This means that we will merge m:m against the income dataset.

*/

cd "$user_main\Absolute Mobility\Extract"
merge m:m PersonLopNr using "Income Tax 1968-1989.dta"

keep if _merge == 3
drop _merge

rename PersonLopNr $TargetVar

* Generating Age variable, and keeping only individual between 30 and 40 years old:

gen Age = Ar - $TargetBirthYear
keep if Age >= 30 & Age <= 40

tempfile data1
save `data1', replace

/* We now repeat the previous procedure but for the income data 1990-2005: */

clear

cd "$user_main\Absolute Mobility\Extract"
use "Merged_Bakgrund_Flergen.dta", clear

keep $TargetVar $TargetBirthYear

rename $TargetVar PersonLopNr

cd "$user_main\Absolute Mobility\Extract"
merge m:m PersonLopNr using "LISA 1990-2005.dta"

keep if _merge == 3
drop _merge

rename PersonLopNr $TargetVar

gen Age = Ar - $TargetBirthYear
keep if Age >= 30 & Age <= 40

tempfile data2
save `data2', replace

clear

/* We now repeat the previous procedure but for the income data 2006-2017: */

cd "$user_main\Absolute Mobility\Extract"
use "Merged_Bakgrund_Flergen.dta", clear

keep $TargetVar $TargetBirthYear

rename $TargetVar PersonLopNr

cd "$user_main\Absolute Mobility\Extract"
merge m:m PersonLopNr using "LISA 2006-2017.dta"

keep if _merge == 3
drop _merge

rename PersonLopNr $TargetVar

gen Age = Ar - $TargetBirthYear
keep if Age >= 30 & Age <= 40

append using `data1'
append using `data2'

bysort FodelseAr LopNrMor Ar Age: keep if _n == 1

cd "$user_main\Absolute Mobility\Extract"
save "Flergen Income Merged $Targetgroup.dta", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Extract"
doedit "8. Merging Children, Fathers and Mothers.do"
