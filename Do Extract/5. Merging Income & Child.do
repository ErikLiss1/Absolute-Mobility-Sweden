
/***********************************************************

This DO-file merges income data with the background data for children. In
the subsequent do-file we repeat this for mothers and fathers so that we have the
income and background data for all three. These three can then easily be merged
together to a single dataset where we can compare child and parent incomes. 
This is for the individual earning comparon only. 
See Do-file "Household level" for how Household dataset is created.

***********************************************************/



/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/


/* 
Using these globals will allow us to make the DO-files for children, fathers &
mothers similar.
*/

global Targetgroup Child
global TargetVar PersonLopNr
global TargetBirthYear FodelseAr

cd "$user_main\Absolute Mobility\Extract"
use "Merged_Bakgrund_Flergen.dta", clear

/* 
We only need the variables Personal ID number, birth year and sex from the background data set:
*/

keep $TargetVar $TargetBirthYear Kon

rename $TargetVar PersonLopNr

/* 
Merging the background data with the income data. The background data only
has one observation per individual, but the income tax data has annual income data. This means that we will merge 1:m against the income dataset. We merge against the 
1968-1989 data, 1990-2005 data and 2006-2017 data separately as the dataset
otherwise will be too big. 
*/

cd "$user_main\Absolute Mobility\Extract"
merge 1:m PersonLopNr using "Income Tax 1968-1989.dta"

keep if _merge == 3
drop _merge

rename PersonLopNr $TargetVar

* Generating Age variable, and keeping only individual between 30 and 40 years old:

gen Age = Ar - $TargetBirthYear
keep if Age >= 30 & Age <= 40

tempfile data1
save `data1', replace

clear

/* We now repeat the previous procedure but for the income data 1990-2005: */

cd "$user_main\Absolute Mobility\Extract"
use "Merged_Bakgrund_Flergen.dta", clear

keep $TargetVar $TargetBirthYear Kon

rename $TargetVar PersonLopNr

cd "$user_main\Absolute Mobility\Extract"
merge 1:m PersonLopNr using "LISA 1990-2005.dta"

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

keep $TargetVar $TargetBirthYear Kon

rename $TargetVar PersonLopNr

cd "$user_main\Absolute Mobility\Extract"
merge 1:m PersonLopNr using "LISA 2006-2017.dta"

keep if _merge == 3
drop _merge

rename PersonLopNr $TargetVar

gen Age = Ar - $TargetBirthYear
keep if Age >= 30 & Age <= 40

* We append all files, and save data set:

append using `data1'
append using `data2'

cd "$user_main\Absolute Mobility\Extract"
save "Flergen Income Merged $Targetgroup.dta", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Extract"
doedit "6. Merging Income & Fathers.do"
