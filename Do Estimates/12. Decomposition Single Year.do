
/*
This DO-file estimates the decomposition model but on single year income
data instead of averaging incomes over several years as in the benchmark specification. 
These estimates are used in Figure A2 and A3.
*/

/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

*  Decomposition

forvalues a = 34(1)34 { 
forvalues b = 34(1)34 {
forvalues c = 1(1)2 {
forvalues d = 1(1)1 {

******************************************************************

/*
See Do-file "1. Estimate Benchmark Absolute mobility.do" for details
on the section below
*/

clear

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

keep if Age == 				$TopAge
keep if ParentAgeatBirth <= $AgeatBirth
keep if ParentChildKind == 	$ParentChildKind
keep if ReportedIncome >= 	$ReportedIncome	

keep if BirthYearChild - $AgeatBirth + 30 >= 1968

sort 	ChildID ChildIncomeYear 
bysort	ChildID: ///
		egen MaxChildYear = max(ChildIncomeYear)
		
drop if MaxChildYear < (BirthYearChild + $TopAge)

drop MaxChildYear	
			
sort 		BirthYearChild ParentEarning
bysort 		BirthYearChild: ///
			gen ParentRank = _n

gen ChildParentDiff = ChildEarning - ParentEarning
	
gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0
			
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)
			
drop AbsoluteMobility ChildParentDiff
				
rename meanAbsoluteMobility AM_${estimate}

******************************************************************

preserve

* Growth Component

/*
We collapse the data to get a variable for mean child and parent
incomes. We will use this to get the mean earning growth.
*/

collapse (mean) ChildEarning ParentEarning, by(BirthYearChild)

rename ChildEarning 	meanChildEarning
rename ParentEarning 	meanParentEarning

* Generating variable for cross generational earning ratio:

gen MeanIncomeRatio = ///
	(meanChildEarning / meanParentEarning)

/* 
We plug in the parameters in the closed form formula. Since we take the 
log of incomes and standard deviation, we should preferably choose values greater than one (Since logged values below 1 will yield negative values. We choose 2 as the parent mean income but this could be any number.
*/

gen MeanC = log(MeanIncomeRatio*2)
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

* Create variable for Growth rate for plots
gen LogGrowth = MeanC - MeanP

* Calculating Absolute Mobility
gen AbsoluteMobility = normal( ///
	((MeanC-MeanP)/sqrt(SDc^2-2*Rho*SDp*SDc+SDc^2)))
	
rename AbsoluteMobility HomneousGr_${estimate}

/*

We save the file in order to merge it into the rest of the data once we
restore the data.

*/

tempfile data1
save `data1', replace

restore

merge m:1 BirthYearChild using `data1'

drop _merge

* Growth Component using Observed Income Vectors

/*

We save a separate data set in which we randomly scrambled the 
parent ranks. We then merge this into the dataset. We can then
compare the observed parent income distribution with a parent 
income distribution that we apply the cross generational growht rate
on, while scrambling the income ranks.

*/

preserve

keep ChildID BirthYearChild ChildEarning ParentEarning 

sort BirthYearChild
	
* Creating random variable:
	
bysort 	BirthYearChild: ///
		gen rnormal = rnormal()
		
sort BirthYearChild rnormal

* Generating Parent rank variable that we later merge based on.

bysort 		BirthYearChild: ///
			gen ParentRank = _n
			
gen 	rsortParentRank = 	ParentRank		
rename 	ChildEarning		rsortChildEarning
rename 	ParentEarning		rsortParentEarning

tempfile data2
save `data2', replace

restore

* Merging the randomly scrambled parent income distribution

merge 1:1 BirthYearChild ParentRank using `data2'

drop _merge

* Generating variable for cross generational growth

gen MeanIncomeGrowth = ///
	(meanChildEarning / meanParentEarning) * ParentEarning

* Generaing variable for difference in income between parent and child.
	
gen ChildParentDiff = MeanIncomeGrowth - rsortParentEarning

* Computing Absolute Mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility ObservedGr_${estimate}

* Dispersion

/*
Applying the dispersion component only requires that we compare 
the observed parent and child distributions but with the income ranks
randomly ordered (since we have not yet applied the exchange component)
*/

gen ChildParentDiff = ChildEarning - rsortParentEarning

* Computing absolute mobility

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
rename meanAbsoluteMobility  ///
		Dispersion_${estimate}
			
* Exchange

/*
The exchange component is simply the residual between the estimated
absolute mobility and the dispersion component.
*/

gen Exchange_${estimate} = AM_${estimate}
	
collapse (mean) ///
	HomneousGr_${estimate} ///
	ObservedGr_${estimate} ///
	Dispersion_${estimate} ///
	Exchange_${estimate}, ///
	by(BirthYearChild)
	
* Computing Marginal Contributions

gen Marg_HomneousGr_${estimate} = ///
	HomneousGr_${estimate} - 0.5

gen Marg_ObservedGr_${estimate} = ///
	ObservedGr_${estimate} - HomneousGr_${estimate}

gen Marg_Dispersion_${estimate} = ///
	Dispersion_${estimate} - ObservedGr_${estimate}
	

gen Marg_Exchange_${estimate} = ///
	Exchange_${estimate} - Dispersion_${estimate}
	
cd "$user_main\Absolute Mobility\Output Absolute Mobility"

save "Decomposition TopAge Single Year $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", replace

}
}	
}
}

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "13. Household Decomposition.do"
