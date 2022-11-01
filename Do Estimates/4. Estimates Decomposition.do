

/*

This Do-file runs the decomposition model for a number of 
different specifications. The main specification is then used in Figure 5 in
the paper (see Do-File "Figure 5 Decomposition.do")

*/

/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

*  Decomposition

forvalues a = 32(2)40 { 
forvalues b = 32(2)38 {
forvalues c = 1(1)4 {
forvalues d = 0(1)1 {

******************************************************************

/*

See Do-file "1. Estimate Benchmark Absolute mobility.do" for details
about the section below until row 80

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

sort 		BirthYearChild ChildID
collapse 	(mean) ParentEarning ChildEarning, ///
			by(BirthYearChild ChildID)
			
* Creating a parent rank variable necssary for the rank component:
			
sort 		BirthYearChild ParentEarning
bysort 		BirthYearChild: ///
			gen ParentRank = _n
			
* Estimating absolute mobility for calibration:

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

* Generating variable for cross generational growth:

gen MeanIncomeRatio = ///
	(meanChildEarning / meanParentEarning)

/* 
We plug in the parameters in the closed form formula shown in equation 2 in the paper. 
Since we take the log of incomesn, we should preferably choose values greater than one. We choose 2 as the parent mean. The standard deviation is given by equation 2 in the paper.
*/

gen MeanC = log(MeanIncomeRatio*2)
gen MeanP = log(2)
gen SD = sqrt(exp(1))
gen LogSqrtSD = log(SD)

* We set SDp=SDc=log(${SD})
gen SDp = LogSqrtSD
gen SDc = LogSqrtSD

* We set the intergenerational correlation Rho to 0 (see equation 2)
gen Rho = 0

* Calculating Gini coefficient for the reference point distribution (log normal distribution):
gen Gini = 2*normal((log(SD)/2)*sqrt(2))-1

* Create variable for  Growth Rate for plots
gen LogGrowth = MeanC - MeanP

* Calculating Absolute Mobility
gen AbsoluteMobility = normal( ///
	((MeanC-MeanP)/sqrt(SDc^2-2*Rho*SDp*SDc+SDc^2)))

* Renaming to component name. This is the growth component: 
rename AbsoluteMobility HomneousGr_${estimate} // Growth component
		
/*

We save the file in order to merge it into the rest of the data once we
restore the data.

*/

tempfile data1
save `data1', replace

restore

merge m:1 BirthYearChild using `data1'

drop _merge

* Parent Dispersion component:

/*

We save a separate data set in which we randomize the 
parent ranks. We then merge this into the dataset. We can then
compare the observed parent income distribution with a parent 
income distribution that we apply the cross generational growht rate
on, while income ranks are random.

*/

preserve

keep ChildID BirthYearChild ChildEarning ParentEarning 

sort BirthYearChild
	
* Creating random variable:
	
bysort 	BirthYearChild: ///
		gen rnormal = rnormal()
		
sort BirthYearChild rnormal

* Generating a Parent rank based on the randomization above:

bysort 		BirthYearChild: ///
			gen ParentRank = _n
			
* Rank, child inome and Parent income for a random reranked distribution.
			
gen 	rsortParentRank = 	ParentRank		
rename 	ChildEarning		rsortChildEarning
rename 	ParentEarning		rsortParentEarning

tempfile data2
save `data2', replace

restore

* Merging the randomized parent income distribution

merge 1:1 BirthYearChild ParentRank using `data2'

drop _merge

* Generating variable for cross generational growth

gen MeanIncomeGrowth = ///
	(meanChildEarning / meanParentEarning) * ParentEarning

* Generaing variable for difference in income between parent and child.
	
gen ChildParentDiff = MeanIncomeGrowth - rsortParentEarning

* Computing Absolute Mobility for Parent Dispersion component:

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff

* Renaming variable to component name. This is the Parent dispersion component:
			
rename meanAbsoluteMobility ObservedGr_${estimate}

* Child Dispersion component:

/*

Applying the dispersion component only requires that we compare 
the observed parent and child distributions but with the income ranks
randomly ordered (since we have not yet applied the rank component)

*/

gen ChildParentDiff = ChildEarning - rsortParentEarning

* Computing absolute mobility for Child dispersion component

gen 	AbsoluteMobility = 1 if ChildParentDiff >= 0
replace AbsoluteMobility = 0 if ChildParentDiff < 0

sort 		BirthYearChild
bysort 		BirthYearChild: ///
			egen meanAbsoluteMobility = mean(AbsoluteMobility)

drop AbsoluteMobility ChildParentDiff
			
* Renaming to child dispersion component:
			
rename meanAbsoluteMobility  ///
		Dispersion_${estimate}
			
* Rank Component:

/*

The rank component is simply the residual between the estimated
absolute mobility and the dispersion component.

*/

gen Exchange_${estimate} = AM_${estimate}
	
* Collapse by each birth cohort:
	
collapse (mean) ///
	HomneousGr_${estimate} ///
	ObservedGr_${estimate} ///
	Dispersion_${estimate} ///
	Exchange_${estimate}, ///
	by(BirthYearChild)
	
* Computing Marginal Contributions

* Growth component:
gen Marg_HomneousGr_${estimate} = ///
	HomneousGr_${estimate} - 0.5

* Parent dispersion component:
gen Marg_ObservedGr_${estimate} = ///
	ObservedGr_${estimate} - HomneousGr_${estimate}

* Child dispersion component:
gen Marg_Dispersion_${estimate} = ///
	Dispersion_${estimate} - ObservedGr_${estimate}
	
* Rank Component:
gen Marg_Exchange_${estimate} = ///
	Exchange_${estimate} - Dispersion_${estimate}
	
cd "$user_main\Absolute Mobility\Output Absolute Mobility"

save "Decomposition TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", replace

}
}	
}
}

* Saving all specifications to a single dataset:

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

collapse ChildID, by(BirthYearChild)
keep BirthYearChild

cd "$user_main\Absolute Mobility\Output Absolute Mobility"

forvalues a = 32(2)40 { 
forvalues b = 32(2)38 {
forvalues c = 1(1)4 {
forvalues d = 0(1)1 {

global TopAge = 			`a'
global AgeatBirth = 		`b'
global ParentChildKind = 	`c'
global ReportedIncome = 	`d'

merge 1:1 BirthYearChild using "Decomposition TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

}
}	
}
}

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
save "Decomposion Merged", replace

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "5. Parent Dispersion Swedish Data.do"
