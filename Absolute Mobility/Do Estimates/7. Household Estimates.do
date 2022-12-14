
/*

This DO-file estimates Absolute Mobility on houeshold level.

*/

/**************** Preamble: Set directories ****************/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

clear

cd "$user_main\Absolute Mobility/Extract"
use "Household Data.dta", clear

global TopAge = 			34
global AgeatBirth = 		34
global ParentChildKind = 	1
global ReportedIncome = 	1

rename Age Age1
rename FodelseAr ChildBirthYear1

* Removing obs in which head of household is outside of the proxy for lifetime income:

drop if Age1 < 30 & HouseholdHead==1
drop if Age1 > $TopAge & HouseholdHead==1

drop if Age2 < 30 & HouseholdHead==2
drop if Age2 > $TopAge & HouseholdHead==2		

* Creating variable for age at birth:

gen FatherAgeatBirth = ChildBirthYear1 - BirthYearFather
gen MotherAgeatBirth = ChildBirthYear1 - BirthYearMother

* Remove obs if head of household is older than max parent age at child birth (34):

drop if FatherAgeatBirth >= $AgeatBirth & MotherHead != 1
drop if MotherAgeatBirth >= $AgeatBirth & MotherHead == 1

/*

The first cohort estimated is determined by the fact that the first year 
for which we have income data for is 1968. Remember that cohorts must include 
income data for when the parent in 30 years of age. The first cohort we 
therefore can estimate absolute mobility for is therefore determined 
by that the head of household parent with the highest possible age at child birth is at least
30 years old in year 1968:

*/

gen HouseholdHeadBirthYear = ChildBirthYear1 if HouseholdHead==1
replace HouseholdHeadBirthYear = ChildBirthYear2 if HouseholdHead==2

keep if HouseholdHeadBirthYear - $AgeatBirth + 30 >= 1968

/*

In a few instances, the income of a individual is registered a year late, 
meaning that even though we removed observations where the individuals are
older or younger than the specified income span, we still have some income years
included when the individual is older than this since their income was registered
a year late. We therefore remove these income years.

*/

sort 	ChildID1 HouseholdHeadBirthYear 
bysort	ChildID1: ///
		egen MaxChildYear = max(HouseholdHeadBirthYear)
		
drop if MaxChildYear < (ChildBirthYear1 + $TopAge)
drop MaxChildYear

*drop if HouseholdHeadBirthYear > 1983

* We now combine child generation incomes. We start by giving a dummy for non missing incomes:

gen ChildDummy1 = ChildEarning1 !=.
gen ChildDummy2 = ChildEarning2 !=.

* We do the same in the parent generation:

gen ParentDummy1 = FatherEarning !=.
gen ParentDummy2 = MotherEarning !=.

* Counting the dummies to get number in households (1 or 2)

gen NumbChild = ChildDummy1 + ChildDummy2
gen NumbParent = ParentDummy1 + ParentDummy2
replace NumbParent = 1 if MotherHead == 1

* If Child Earning is missing we give it income 0 (so that we can combine incomes)

replace ChildEarning1 = 0 if ChildEarning1 ==.
replace ChildEarning2 = 0 if ChildEarning2 ==.

replace MotherEarning = 0 if MotherEarning ==.
replace FatherEarning = 0 if FatherEarning ==.

* Dividing household earning by number in houeshold:

gen ChildHouseholdEarning = (ChildEarning2 + ChildEarning1) / NumbChild
gen ParentHouseholdEarning = (MotherEarning + FatherEarning) / NumbParent

* We also have a household definition when we do not divide by number in houeshold:

gen ChildHouseholdEarningSum = (ChildEarning2 + ChildEarning1)
gen ParentHouseholdEarningSum = (MotherEarning + FatherEarning)

* Collapsing incomes so that we get mean income over all years:

sort 		ChildBirthYear1 ChildID1
collapse 	(mean) ParentHouseholdEarning ChildHouseholdEarning, ///
			by(ChildBirthYear1 ChildID1)

* Calculating absolute mobility for each individual:
			
gen ChildParentDiff = ChildHouseholdEarning - ParentHouseholdEarning
	
gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

* Collapsing to get absolute mobility per birthcohort 

collapse 	(mean) AbsoluteMobility, ///
			by(ChildBirthYear1)
			
* Renaming absolute mobility variable to the according chosen specifics
			
rename AbsoluteMobility AM_${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome}
rename ChildBirthYear BirthYearChild

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
save "Absolute Mobility Household TopAge 2 $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", replace
	
* Open next DO file:
	
cd "$user_main\Absolute Mobility\Do Estimates"
doedit "8. Labor Force Treshold.do"
	
