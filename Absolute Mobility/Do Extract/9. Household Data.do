
/*

This Do-file builds a dataset allocating individuals into households.
This is later used to estimate houeshold absolute mobility.

*/

/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working Directory
global connectionstring "" // Your connectionstring to SCL Server

/***********************************************************/

global LISA1 1996(1)2004

************************************************************************
****          		 Extract data from SQL 							****
************************************************************************

/*

Because we compare the income of child generation households against their parents'
income, we will first create a dataset containing all houesholds married 
or in partnership. Individuals not married or in partnership will later be 
included.

*/

*Extract and load income variables, per year, and family type.
cd "$user_main/Absolute Mobility/Extract"
forvalues lisayyyy = $LISA1 {
	display "`lisayyyy'"
	clear
	odbc load ///
		PersonLopNr ///
		FamIdLopNr ///
		Ar ///
		FamStF ///
		ForvInk ///
		, ///
	table("LISA`lisayyyy'_Individ")connectionstring("$connectionstring")
	
* Keeping observations in partnerships or married: 
	
	destring FamStF, replace
	keep if FamStF < 200
	drop FamStF
	
	tempfile l`lisayyyy'
	save `l`lisayyyy''
	
}

*Append years to one dataset
clear
forvalues lisayyyy = $LISA1 {

 append using `l`lisayyyy''
 
}

**** Edit Variables ****

destring Ar, replace
bysort Ar PersonLopNr: keep if _n == 1

compress

tempfile data1
save `data1', replace

global LISA2 2005(1)2017

* Doing the same procedure but for income years 2005-2017

*Extract and load income variables and family type per year
cd "$user_main/Absolute Mobility/Extract"
forvalues lisayyyy = $LISA2 {
	display "`lisayyyy'"
	clear
	odbc load ///
		PersonLopNr ///
		FamIdLopNr ///
		Ar ///
		FamStF ///
		ForvInk ///
		, ///
	table("LISA`lisayyyy'_Individ")connectionstring("DRIVER={ODBC Driver 17 for SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")
	
	destring ForvInk, replace
	destring FamStF, replace
	keep if FamStF < 200
	drop FamStF
	
	tempfile l`lisayyyy'
	save `l`lisayyyy''
	
}

*Append years to one dataset
clear
forvalues lisayyyy = $LISA2 {

 append using `l`lisayyyy'', force
 
}

destring Ar, replace
bysort Ar PersonLopNr: keep if _n == 1

append using `data1'

preserve

* Income will included later from the aleady extraced income data, so we drpp them here:

drop ForvInk

/* 
Individuals could throughout their lifetime be part of different households.
We assign individuals to households that they spent most time in. This is done in two steps:
*/

* Create variable for number of years spent in different houesholds:

sort Ar FamIdLopNr PersonLopNr

sort PersonLopNr FamIdLopNr
bysort PersonLopNr FamIdLopNr: gen YearsHousehold = _N

* Create variable for number of years spent in different houesholds:

sort PersonLopNr YearsHousehold
bysort PersonLopNr: keep if _n == _N

drop Ar

cd "$user_main/Absolute Mobility/Extract"
save "Family ID", replace

restore 

preserve

collapse (mean) ForvInk, by(Ar FamIdLopNr PersonLopNr)

save "Family ID Income", replace

restore 

/*

We now load the previously extracted child income data and merge 
it into the family ID variables:

*/

global Targetgroup Child
global TargetVar PersonLopNr
global TargetBirthYear FodelseAr

cd "$user_main\Absolute Mobility\Extract"
use "Flergen Income Merged Child.dta", clear

*drop _merge

keep $TargetVar $TargetBirthYear Kon ForvInk Ar

rename $TargetVar PersonLopNr

/*

Assigning all child income data into households.
(unless not married or in partnership, in which case they will be merge==1 and kept in the data).
Each houehold can have many many individuals so we merge m:1.

*/

cd "$user_main\Absolute Mobility\Extract"
merge m:1 PersonLopNr using "Family ID"

drop _merge

* Different household will have different number of adults in them.
* We create a variable counting the number of adults in the household

sort Ar FamIdLopNr 
bysort Ar FamIdLopNr: gen FamType = _N

replace FamType = . if FamIdLopNr ==.

gen Age = Ar - $TargetBirthYear

tempfile Type3
save `Type3', replace

* For simplicity, keeping only if there are two married or in two in a partnership.

drop if FamType > 2

/*

The next goal is to put the income of each partner in a household on different 
rows but the same observation. This is because each individual in the child generation
will in one case be a child and in another case a spouse. Children not living 
with a spouse or partner will only appear as children i nthe dataset and 
not as second time as a spouse.

We first give each person in the houeshold a separate ID number. Men will have family
number 1 and women family number 2. 

*/

sort Ar FamIdLopNr Kon
bysort Ar FamIdLopNr: gen FamNumb = _n

/*

Next, we create 4 datasets. 

One where household member 1 is the child (denoted Type 1).
One where family member 1 is the spouse (denoted Type 21).

One where household member 2 is the child (denoted Type 2). 
One where family member 2 is the spouse (denoted Type 12)

*/

local Constant = 2

foreach i in 1 2 {

preserve

* We keep only households with 2 incomes

keep if FamType == 2 

* Famnumb is if the within household personal number. We keep one at the time:

keep if FamNumb == `i'

* Renaming household income to the within household ID number.

rename ForvInk ChildEarning`i'
rename PersonLopNr PersonLopNr`i'
rename FodelseAr ChildBirthYear`i'
rename Age Age`i'
rename Kon Sex`i'

* Saving Data for household ID

tempfile Type`i'
save `Type`i'', replace

/*

Each child to appear two times. One time as child and one time as spouse.

*/

replace FamNumb = `Constant'

rename ChildEarning`i' ChildEarning`Constant'
rename PersonLopNr`i' PersonLopNr`Constant'
rename ChildBirthYear`i' ChildBirthYear`Constant'
*rename FamType FamType`i'
rename Age`i' Age`Constant'
rename Sex`i' Sex`Constant'

tempfile Type`i'`Constant'
save `Type`i'`Constant'', replace

local Constant = `Constant' - 1

restore

}

* Here we merge HouseID-numb 1 (type1) with HouseID-numb two (type21).
* Thus, HouseID-numb 1 is the child, and HouseID-numb 2 is the spouse

use `Type1', clear
merge 1:1 FamIdLopNr Ar using `Type2', gen(merge21) update
tempfile Type1
save `Type1', replace

* Here we merge HouseID-numb 2 (type21) with HouseID-numb 1 (type21).
* Thus, HouseID-numb 2 is the child, and HouseID-numb 1 is the spouse

use `Type21', clear
merge 1:1 FamIdLopNr Ar using `Type12', gen(merge12) update

append using `Type1'

* if there is a man in the houeshold, he will be the houeshold head.

gen 	HouseholdHead = 1 if ChildEarning1 !=. & Sex1==1
replace HouseholdHead = 2 if ChildEarning2 !=. & Sex2==1

* If there is no man in the household, family ID 1 will be head of houeshold
replace HouseholdHead = 1 if ChildEarning1 !=. & Sex1==2 & Sex2=2

* If there is only one adult in household, he/she will be head of household.

replace HouseholdHead = 1 if ChildEarning2 ==.

* We only include household where both spouses are between age 30 and 40.

drop if Age1 <= 30 & HouseholdHead==1
drop if Age1 >= 40 & HouseholdHead==1

drop if Age2 <= 30 & HouseholdHead==2
drop if Age2 >= 40 & HouseholdHead==2

tempfile Type1
save `Type1', replace

/*

So far we have not included household with no partner or spouse.
We previously saved Type3 as a dataset before removing households with only
one spouse. We will now load that dataset again so that we can include household
with no spouse or partner.

*/

use `Type3', clear

* Keeping only households with no partner or spouse:

keep if FamType == 1

* Keeping only households between age 30 and 40:

keep if Age >= 30 & Age <= 40

* The individual in households with no partner or spouse will always have household ID 1:

rename ForvInk ChildEarning1
rename PersonLopNr PersonLopNr1
rename FodelseAr ChildBirthYear1
rename Age Age1
rename Kon Sex1

* Now appending all the houesholds with no spouse or pratner with the ones with.

append using `Type1'

* Next, we inflation adjust incomes.

merge m:1 Ar using "SwedenCPIIndexYearlyFrom1949.dta"
drop if _merge == 2
drop _merge

* Next, adjusting inflation index to 2010:

gen CPIIndexCYearly2010 = CPIIndexYearlyMean / 1733

* Inflation adjusting by dividing by CPI:

replace ChildEarning1 = ChildEarning1/CPIIndexCYearly2010
replace ChildEarning2 = ChildEarning2/CPIIndexCYearly2010

drop CPIIndexCYearly2010 CPIIndexYearlyMean

/*

We now merge in the parent ID number to the child through multigenerational
register.
		
*/

rename PersonLopNr1 PersonLopNr
rename ChildBirthYear1 FodelseAr
drop Ar
	
cd "$user_main\Absolute Mobility/Extract"
merge m:1 PersonLopNr FodelseAr ///
		using "Merged_Bakgrund_Flergen.dta", ///
		keepusing(LopNrFar LopNrMor FodelseArMor) ///
		gen(ChildMerge) 

rename Age1 Age

/*

We now merge the father income into the data. We merge on when the head of household
in both generations are the same age.
		
*/

cd "$user_main\Absolute Mobility/Extract"
merge m:1 LopNrFar Age using "Flergen Income Merged Father.dta", ///
gen(FatherMerge)

/*

We now merge the mother income into the data. In case there is no father,
mothers will be the head of household and is merged to the same age as the 
head of houeshold in the child generation:
		
*/

rename ForvInk FatherEarning
drop DispInk
rename LopNrFar FatherID

merge m:1 LopNrMor Age using "Flergen Income Merged Mother.dta", ///
gen(MotherMerge1)

drop DispInk

* Mother head is a variable to highlight parents with no father.

gen MotherHead = 1 if FatherID ==. & LopNrMor!=. & PersonLopNr !=.

/* 

In case the mother is the Head of household, her income will be counted 
as father earning and the ID number will be that of the father.

*/

replace FatherEarning = ForvInk if MotherHead == 1
replace FatherID = 	LopNrMor if MotherHead == 1
replace BirthYearFather = FodelseArMor if MotherHead == 1

drop ForvInk

/*

We now merge the mother income into the data. In case there is a father,
mothers will be merged in the the same income year of the head of houeshold.
Thus incomes are compared when the head of households of both generations 
are the same age.
		
*/

merge m:1 LopNrMor Ar using "Flergen Income Merged Mother.dta", ///
gen(MotherMerge2)

rename ForvInk MotherEarning
drop DispInk
rename LopNrMor MotherID
rename FodelseArMor BirthYearMother

/*

In case the mother is the head, mother earning is missing (so that it is not
counted twice).
		
*/

replace MotherEarning = . if MotherHead == 1
replace BirthYearMother = . if MotherHead == 1
replace MotherID =. if MotherHead == 1

/*

keeping only observations where we have at least one match to the parent
generation:
		
*/

keep if FatherMerge == 3 | MotherMerge1 == 3 | MotherMerge2 == 3

/*

We now inflation adjust the praent generation income:
		
*/

merge m:1 Ar using "SwedenCPIIndexYearlyFrom1949.dta"
drop if _merge == 2
drop _merge

* Changing the base year to 2010:

gen CPIIndexCYearly2010 = CPIIndexYearlyMean / 1733

* Inflation adjusting by dividing by CPI:

replace MotherEarning = MotherEarning/CPIIndexCYearly2010
replace FatherEarning = FatherEarning/CPIIndexCYearly2010

*replace ChildDispIncome = ChildDispIncome/CPIIndexCYearly2010

drop CPIIndexCYearly2010 CPIIndexYearlyMean

drop Ar
rename PersonLopNr ChildID1
rename PersonLopNr2 ChildID2

cd "$user_main\Absolute Mobility/Extract"
save "Household Data.dta", replace
