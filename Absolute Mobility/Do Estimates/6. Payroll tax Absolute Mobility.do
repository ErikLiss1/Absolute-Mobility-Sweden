
/*

This dataset estimates absolute mobility assuming employees bear the whole
tax burden of the payroll tax.

*/


/**************** Preamble: Set directories ****************/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

* Computing Absolute Mobility:

forvalues a = 34(1)34 { 
forvalues b = 34(1)34 {
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

Since we only want to incluce child-parent pairs in which we have non-missing 
incomes for ALL years, we must remove any Child-Parent pair in which the 
number of income years is below that the number of income years within the
specified income span.

*/
 
sort 	ChildID Age
bysort	ChildID: keep if _N > ($TopAge - 30)

/*

The first cohort estimated is determined by the fact that the first year 
for which we have income data for is 1968. Remember that cohorts must include 
income data for when the parent in 30 years of age. The first cohort we 
therefore can estimate absolute mobility for is therefore determined 
by that the parent with the highest possible age at child birth is at least
30 years old in year 1968:

*/

keep if BirthYearChild - $AgeatBirth + 30 >= 1970

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

gen Childpayrolltax = .
gen Parentpayrolltax = . 

/*

Imputing the payroll tax (in percentage) for both parents and children:

*/

foreach p in Parent Child {

replace `p'payrolltax = 	11.65	if `p'IncomeYear ==	1970
replace `p'payrolltax = 	13.52	if `p'IncomeYear ==	1971
replace `p'payrolltax = 	14.41	if `p'IncomeYear ==	1972
replace `p'payrolltax = 	16.61	if `p'IncomeYear ==	1973
replace `p'payrolltax = 	21.01	if `p'IncomeYear ==	1974
replace `p'payrolltax = 	25.37	if `p'IncomeYear ==	1975
replace `p'payrolltax = 	29.49	if `p'IncomeYear ==	1976
replace `p'payrolltax = 	32.68	if `p'IncomeYear ==	1977
replace `p'payrolltax = 	31.71	if `p'IncomeYear ==	1978
replace `p'payrolltax = 	32.06	if `p'IncomeYear ==	1979
replace `p'payrolltax = 	33.16	if `p'IncomeYear ==	1980
replace `p'payrolltax = 	33.63	if `p'IncomeYear ==	1981
replace `p'payrolltax = 	33.06	if `p'IncomeYear ==	1982
replace `p'payrolltax = 	36.76	if `p'IncomeYear ==	1983
replace `p'payrolltax = 	36.16	if `p'IncomeYear ==	1984
replace `p'payrolltax = 	36.46	if `p'IncomeYear ==	1985
replace `p'payrolltax = 	36.45	if `p'IncomeYear ==	1986
replace `p'payrolltax = 	37.08	if `p'IncomeYear ==	1987
replace `p'payrolltax = 	37.07	if `p'IncomeYear ==	1988
replace `p'payrolltax = 	37.47	if `p'IncomeYear ==	1989
replace `p'payrolltax = 	38.97	if `p'IncomeYear ==	1990
replace `p'payrolltax = 	38.02	if `p'IncomeYear ==	1991
replace `p'payrolltax = 	34.83	if `p'IncomeYear ==	1992
replace `p'payrolltax = 	31		if `p'IncomeYear ==	1993
replace `p'payrolltax = 	31.36	if `p'IncomeYear ==	1994
replace `p'payrolltax = 	32.86	if `p'IncomeYear ==	1995
replace `p'payrolltax = 	33.06	if `p'IncomeYear ==	1996
replace `p'payrolltax = 	32.92	if `p'IncomeYear ==	1997
replace `p'payrolltax = 	33.03	if `p'IncomeYear ==	1998
replace `p'payrolltax = 	33.06	if `p'IncomeYear ==	1999
replace `p'payrolltax = 	32.92	if `p'IncomeYear ==	2000
replace `p'payrolltax = 	32.82	if `p'IncomeYear ==	2001
replace `p'payrolltax = 	32.82	if `p'IncomeYear ==	2002
replace `p'payrolltax = 	32.82	if `p'IncomeYear ==	2003
replace `p'payrolltax = 	32.7	if `p'IncomeYear ==	2004
replace `p'payrolltax = 	32.46	if `p'IncomeYear ==	2005
replace `p'payrolltax = 	32.28	if `p'IncomeYear ==	2006
replace `p'payrolltax = 	32.42	if `p'IncomeYear ==	2007
replace `p'payrolltax = 	32.42	if `p'IncomeYear ==	2008
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2009
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2010
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2011
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2012
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2013
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2014
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2015
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2016
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2017
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2018
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2019
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2020
replace `p'payrolltax = 	31.42	if `p'IncomeYear ==	2021

* Chaning to decimal form:

replace `p'payrolltax = `p'payrolltax/100

* Earning after payroll taxes:

replace `p'Earning = `p'Earning/(1-`p'payrolltax)

}

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
			
* Renaming absolute mobility variable to the according chosen specifics
			
rename AbsoluteMobility AM_${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome}

cd "$user_main\Absolute Mobility\Output Absolute Mobility"

save "Pay Roll Absolute Mobility TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", replace
		
}
}	
}
}

cd "$user_main\Absolute Mobility\Extract"
use "Children, Fathers, Mothers Merged", clear

/*

Merging all birth cohorts so that we could merge by birth 
cohort to this dataset.

*/

collapse ChildID, by(BirthYearChild)
keep BirthYearChild

cd "$user_main\Absolute Mobility\Output Absolute Mobility"

forvalues a = 34(1)34 { 
forvalues b = 34(1)34 {
forvalues c = 1(1)4 {
forvalues d = 0(1)1 {

global TopAge = 			`a'
global AgeatBirth = 		`b'
global ParentChildKind = 	`c'
global ReportedIncome = 	`d'

* Merging each collapsed absolute mobility specification to a single data set:

merge 1:1 BirthYearChild using "Pay Roll Absolute Mobility TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

}
}	
}
}

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
save "Pay Roll Absolute Mobility Merged", replace

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "7. Household Estimates.do"
