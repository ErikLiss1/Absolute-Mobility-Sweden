
/*

This DO-file estimates the decomposition model but on household data instead
of on men and women separately as in the benchmark specification. These 
estimates are used in A8.

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
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

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

* Drop if birth cohort is older than 


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

bysort 		ChildBirthYear1: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)
			
drop AbsoluteMobility ChildParentDiff
				
rename meanAbsoluteMobility AMTotal_${estimate}

*** Decomposition starts here

* Growth Component

/*

We collapse the data to get a variable for mean child and parent
incomes. We will use this to get the mean earning growth.

*/

egen meanMeanChild = mean(ChildHouseholdEarning), by(ChildBirthYear1)
egen meanMeanParent = mean(ParentHouseholdEarning), by(ChildBirthYear1)

* Mean Income:
gen meanMeanGrowth = meanMeanChild / meanMeanParent

/* 
We plug in the parameters in the closed form formula. Since we take the 
log of incomes and standard deviation, we should preferably choose values greater than one. We choose 2 as the parent mean income.
*/

*gen MeanC = log(MeanIncomeRatio*2)
gen MeanP = log(2)
gen SD = sqrt(exp(1))
gen LogSqrtSD = log(SD)

* We set SDp=SDc=log(${SD})
gen SDp = LogSqrtSD
gen SDc = LogSqrtSD

* We set the intergenerational correlation Rho to 0
gen Rho = 0

* Calculating Gini coefficient
gen Gini = 2*normal((log(SD)/2)*sqrt(2))-1

* Create variable for  Growth Rate for plots
* gen LogGrowth = MeanC - MeanP

gen MeanC = .

* Calculating Absolute Mobility
replace MeanC = log(meanMeanGrowth*2)
gen AbsoluteMobility = normal( ///
	((MeanC-MeanP)/sqrt(SDc^2-2*Rho*SDp*SDc+SDc^2)))
rename AbsoluteMobility MeanGrowth_${estimate}

/*

We save a separate data set in which we randomly reorder the 
parent ranks. We then merge this into the dataset. We can then
compare the observed parent income distribution with a parent 
income distribution that we apply the cross generational growht rate
on, while scrambling the income ranks.

*/


bysort 		ChildBirthYear1: ///
			gen ParentRank = _n

preserve

keep ChildID ChildBirthYear1 ChildHouseholdEarning ParentHouseholdEarning ChildHouseholdTotal ParentHouseholdTotal

sort ChildBirthYear1

* Creating random variable:
	
bysort 	ChildBirthYear1: ///
		gen rnormal = rnormal()

sort ChildBirthYear1 rnormal

* Generating Parent rank variable that we later merge based on.

bysort 		ChildBirthYear1: ///
			gen ParentRank = _n
			
gen 	rsortParentRank = 	ParentRank	
	
rename 	ChildHouseholdEarning		rsortChildEarning
rename 	ParentHouseholdEarning		rsortParentEarning

rename 	ChildHouseholdTotal			rsortChildTotal
rename 	ParentHouseholdTotal		rsortParentTotal

tempfile data2
save `data2', replace

restore

* Merging the randomly scrambled parent income distribution

merge 1:1 ChildBirthYear1 ParentRank using `data2'

drop _merge

* Generating variable for cross generational growth

gen MeanMeanGrowth = ///
	(meanMeanChild/ meanMeanParent) * ParentHouseholdEarning

* Generaing variable for difference in income between parent and child.
	
gen ChildParentDiffMean = MeanMeanGrowth - rsortParentEarning

* Computing Absolute Mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		ChildBirthYear1
bysort 		ChildBirthYear1: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility ObservedMean_${estimate}

gen ChildParentDiffMean = MeanTotalGrowth - rsortParentTotal

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		ChildBirthYear1
bysort 		ChildBirthYear1: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility ObservedTotal_${estimate}

* Dispersion

/*

Applying the dispersion component only requires that we compare 
the observed parent and child distributions but with the income ranks
randomly ordered (since we have not yet applied the rank component)

*/

gen ChildParentDiff = ChildHouseholdEarning - rsortParentEarning


* Computing absolute mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		ChildBirthYear1
bysort 		ChildBirthYear1: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility  ///
		DispMean_${estimate}
			
	
gen ChildParentDiff = ChildHouseholdTotal - rsortParentTotal

* Computing absolute mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		ChildBirthYear1
bysort 		ChildBirthYear1: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility  ///
		DispTotal_${estimate}
			
* Rank Component:

/*

The rank component is simply the residual between the estimated
absolute mobility and the dispersion component.

*/

gen ExchangeMean_${estimate} = AMMean_${estimate}

collapse (mean) ///
	AMTotal* ///
	AMMean* ///
	TotalGrowth* ///
	MeanGrowth* ///
	Observed* ///
	Disp* ///
	Exchange*, ///
	by(ChildBirthYear1)
	
* Mean:

gen Marg_MeanGrowth_${estimate} = ///
	MeanGrowth_${estimate} - 0.5

gen Marg_ObservedMean_${estimate} = ///
	ObservedMean_${estimate} - MeanGrowth_${estimate}

gen Marg_DispMean_${estimate} = ///
	DispMean_${estimate} - ObservedMean_${estimate}
	
gen Marg_ExchangeMean_${estimate} = ///
	ExchangeMean_${estimate} - DispMean_${estimate}
	

cd "$user_main\Absolute Mobility\Output Absolute Mobility"

save "Decomposition HouseHold TopAge $TopAge AgeatBirth $AgeatBirth ReportedIncome $ReportedIncome", replace

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "14. Estimates for Figure A9.do"
