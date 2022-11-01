
/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working Directory
global connectionstring "" // Your connectionstring to SCL Server

/***********************************************************/

** Mean:

global TopAge = 			34
global AgeatBirth = 		34
global ParentChildKind = 	1
global ReportedIncome = 	1
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Decomposition HouseHold TopAge $TopAge AgeatBirth $AgeatBirth ReportedIncome $ReportedIncome", clear

rename ChildBirthYear1 BirthYearChild

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

label variable BirthYearChild ///
"Birth Cohort"

label variable AMMean_${estimate} ///
"{it: A(y{superscript: p}, y{superscript: c}}) Cohort Absolute Mobility"

label variable  Marg_MeanGrowth_${estimate} "{it: {&Delta}G} Growth component"

label variable  Marg_ObservedMean_${estimate}	///
"{it: {&Delta}D{subscript: p}} Parent dispersion component"

label variable  Marg_DispMean_${estimate} ///
"{it: {&Delta}D{subscript: c}} Child dispersion component"

label variable  Marg_ExchangeMean_${estimate} ///
"{it: {&Delta}R} Rank component"

* Adjusting values for graphs:

replace AMMean_${estimate} = AMMean_${estimate} - 0.5

global Component1 "Marg_DispMean_${estimate} Marg_ObservedMean_${estimate} Marg_MeanGrowth_${estimate}"


foreach i of varlist $Component1 {

replace Marg_ExchangeMean_${estimate} = ///
		Marg_ExchangeMean_${estimate} + `i' ///
		if Marg_ExchangeMean_${estimate} >= 0 & `i' >= 0
		
replace Marg_ExchangeMean_${estimate} = ///
		Marg_ExchangeMean_${estimate} - `i' ///
		if Marg_ExchangeMean_${estimate} < 0 & `i' < 0

}

global Component2 "Marg_ObservedMean_${estimate} Marg_MeanGrowth_${estimate}"
	
foreach i of varlist $Component2 {

replace Marg_DispMean_${estimate} = ///
		Marg_DispMean_${estimate} + `i' ///
		if Marg_DispMean_${estimate} >= 0 & `i' >= 0
		
replace Marg_DispMean_${estimate} = ///
		Marg_DispMean_${estimate} - `i' ///
		if Marg_DispMean_${estimate} < 0 & `i' < 0

}

global Component3 "Marg_MeanGrowth_${estimate}"

foreach i of varlist $Component3 {

replace Marg_ObservedMean_${estimate} = ///
		Marg_ObservedMean_${estimate} + `i' ///
		if Marg_ObservedMean_${estimate} >= 0 & `i' >= 0
		
replace Marg_ObservedMean_${estimate} = ///
		Marg_ObservedMean_${estimate} - `i' ///
		if Marg_ObservedMean_${estimate} < 0 & `i' < 0

}

global bw = 0.5

twoway 	///
		(bar Marg_ExchangeMean_${estimate} BirthYearChild, ///
		fcolor(white) barwidth($bw)) ///
		(bar Marg_DispMean_${estimate} BirthYearChild, ///
		fcolor(black) barwidth($bw)) ///
		(bar Marg_ObservedMean_${estimate} BirthYearChild, ///
		barwidth($bw )) ///
		(bar Marg_MeanGrowth_${estimate} BirthYearChild, ///
		barwidth($bw )) ///
		(line AMMean_${estimate} BirthYearChild) ///
		, graphregion(fcolor(white) lcolor(white)) /// 	 
		plotregion(lcolor(black)) name(Mean, replace) ///
		legend(cols(1) region(lcolor(white))) xlabel(1972(1)1983) ///
		scheme(s2mono) title("Household Decomposition") xtitle(" ") ///
		ylabel(0.0 "50%" 0.1 "60%" 0.2 "70%" 0.3 "80%" 0.4 "90%")
		

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
graph export "Mean.png", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Figure A9 Comparisons.do"

		
			
