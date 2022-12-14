
/**************** Preamble: Set directories ****************/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

* Generating Decomposition Table:

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Absolute Mobility Merged", clear

global TopAge = 			34
global AgeatBirth = 		34
global ReportedIncome = 	1
global ParentChildKind = 	1

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

keep BirthYearChild AM_${estimate}

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
merge 1:1 BirthYearChild using "Decomposition Empirical Parent TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

drop if Marg_HomneousGr_${estimate} ==.

drop HomneousGr_${estimate} ObservedGr_${estimate} Dispersion_${estimate} Exchange_${estimate}

replace AM_${estimate} = round(AM_${estimate}, 0.01)
replace Marg_HomneousGr_${estimate} = round(Marg_HomneousGr_${estimate}, 0.001)
replace Marg_ObservedGr_${estimate} = round(Marg_ObservedGr_${estimate}, 0.1)
replace Marg_Dispersion_${estimate} = round(Marg_Dispersion_${estimate}, 0.001)
replace Marg_Exchange_${estimate} = round(Marg_Exchange_${estimate}, 0.001)


label variable BirthYearChild ///
"Birth Cohort"

label variable AM_${estimate} ///
"{it: A(y{superscript: p}, y{superscript: c}}) Cohort Absolute Mobility"

label variable  Marg_HomneousGr_${estimate} ///
"{it: {&Delta}G} Growth component"

label variable  Marg_ObservedGr_${estimate}	///
"{it: {&Delta}D{subscript: p}} Parent dispersion component"

label variable  Marg_Dispersion_${estimate} ///
"{it: {&Delta}D{subscript: c}} Child dispersion component"

label variable  Marg_Exchange_${estimate} ///
"{it: {&Delta}E} Rank component"

save "Decomposition Table Men", replace
export excel "Decomposition Table Men", firstrow(varlabels) replace

* Adjusting values for graphs:

replace AM_${estimate} = AM_${estimate} - 0.5

global Component1 "Marg_Dispersion_${estimate} Marg_ObservedGr_${estimate} Marg_HomneousGr_${estimate}"

foreach i of varlist $Component1 {

replace Marg_Exchange_${estimate} = ///
		Marg_Exchange_${estimate} + `i' ///
		if Marg_Exchange_${estimate} >= 0 & `i' >= 0
		
replace Marg_Exchange_${estimate} = ///
		Marg_Exchange_${estimate} - `i' ///
		if Marg_Exchange_${estimate} < 0 & `i' < 0

}

global Component2 "Marg_ObservedGr_${estimate} Marg_HomneousGr_${estimate}"
	
foreach i of varlist $Component2 {

replace Marg_Dispersion_${estimate} = ///
		Marg_Dispersion_${estimate} + `i' ///
		if Marg_Dispersion_${estimate} >= 0 & `i' >= 0
		
replace Marg_Dispersion_${estimate} = ///
		Marg_Dispersion_${estimate} - `i' ///
		if Marg_Dispersion_${estimate} < 0 & `i' < 0

}

global Component3 "Marg_HomneousGr_${estimate}"

foreach i of varlist $Component3 {

replace Marg_ObservedGr_${estimate} = ///
		Marg_ObservedGr_${estimate} + `i' ///
		if Marg_ObservedGr_${estimate} >= 0 & `i' >= 0
		
replace Marg_ObservedGr_${estimate} = ///
		Marg_ObservedGr_${estimate} - `i' ///
		if Marg_ObservedGr_${estimate} < 0 & `i' < 0

}

global bw = 0.5

twoway 	///
		(bar Marg_Exchange_${estimate} BirthYearChild, ///
		fcolor(white) barwidth($bw)) ///
		(bar Marg_Dispersion_${estimate} BirthYearChild, ///
		fcolor(black) barwidth($bw)) ///
		(bar Marg_ObservedGr_${estimate} BirthYearChild, ///
		barwidth($bw)) ///
		(bar Marg_HomneousGr_${estimate} BirthYearChild, ///
		barwidth($bw)) ///
		(line AM_${estimate} BirthYearChild) ///
		, graphregion(fcolor(white) lcolor(white)) /// 	 
		plotregion(lcolor(black)) name(Men, replace) ///
		legend(cols(1) region(lcolor(white))) xlabel(1972(1)1983) ///
		scheme(s2mono) title("A.") xtitle(" ") ///
		ylabel(0.0 "50%" 0.1 "60%" 0.2 "70%" 0.3 "80%" 0.4 "90%")
	
cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
graph export "Figure A7 Decomposition Men Emprical Parent.png", as(png) replace
graph export "Figure A7 Decomposition Men Empirical Parent.pdf", as(pdf) replace
graph export "Figure A7 Decomposition Men Empirical Parent.tif", as(pdf) replace

* Generating Decomposition Table:

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Absolute Mobility Merged", clear

global TopAge = 			34
global AgeatBirth = 		34
global ReportedIncome = 	1
global ParentChildKind = 	2

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

* keep BirthYearChild AM_${estimate}

merge 1:1 BirthYearChild using "Decomposition Empirical Parent TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

drop if Marg_HomneousGr_${estimate} ==.

drop HomneousGr_${estimate} ObservedGr_${estimate} Dispersion_${estimate} Exchange_${estimate}

replace AM_${estimate} = round(AM_${estimate}, 0.01)
replace Marg_HomneousGr_${estimate} = round(Marg_HomneousGr_${estimate}, 0.001)
replace Marg_ObservedGr_${estimate} = round(Marg_ObservedGr_${estimate}, 0.001)
replace Marg_Dispersion_${estimate} = round(Marg_Dispersion_${estimate}, 0.001)
replace Marg_Exchange_${estimate} = round(Marg_Exchange_${estimate}, 0.001)

label variable BirthYearChild ///
"Birth Cohort"

label variable AM_${estimate} ///
"{it: A(y{superscript: p}, y{superscript: c}}) Cohort Absolute Mobility"

label variable  Marg_HomneousGr_${estimate} ///
"{it: {&Delta}G} Growth component"

label variable  Marg_ObservedGr_${estimate}	///
"{it: {&Delta}D{subscript: p}} Parent dispersion component"

label variable  Marg_Dispersion_${estimate} ///
"{it: {&Delta}D{subscript: c}} Child dispersion component"

label variable  Marg_Exchange_${estimate} ///
"{it: {&Delta}E} Rank component"

save "Decomposition Table Men", replace
export excel "Decomposition Table Men", firstrow(varlabels) replace

* Adjusting values for graphs:

replace AM_${estimate} = AM_${estimate} - 0.5

global Component1 "Marg_Dispersion_${estimate} Marg_ObservedGr_${estimate} Marg_HomneousGr_${estimate}"

foreach i of varlist $Component1 {

replace Marg_Exchange_${estimate} = ///
		Marg_Exchange_${estimate} + `i' ///
		if Marg_Exchange_${estimate} >= 0 & `i' >= 0
		
replace Marg_Exchange_${estimate} = ///
		Marg_Exchange_${estimate} - `i' ///
		if Marg_Exchange_${estimate} < 0 & `i' < 0

}

global Component2 "Marg_ObservedGr_${estimate} Marg_HomneousGr_${estimate}"
	
foreach i of varlist $Component2 {

replace Marg_Dispersion_${estimate} = ///
		Marg_Dispersion_${estimate} + `i' ///
		if Marg_Dispersion_${estimate} >= 0 & `i' >= 0
		
replace Marg_Dispersion_${estimate} = ///
		Marg_Dispersion_${estimate} - `i' ///
		if Marg_Dispersion_${estimate} < 0 & `i' < 0

}

global Component3 "Marg_HomneousGr_${estimate}"

foreach i of varlist $Component3 {

replace Marg_ObservedGr_${estimate} = ///
		Marg_ObservedGr_${estimate} + `i' ///
		if Marg_ObservedGr_${estimate} >= 0 & `i' >= 0
		
replace Marg_ObservedGr_${estimate} = ///
		Marg_ObservedGr_${estimate} - `i' ///
		if Marg_ObservedGr_${estimate} < 0 & `i' < 0

}

global bw = 0.5

twoway 	///
		(bar Marg_Exchange_${estimate} BirthYearChild, ///
		fcolor(white) barwidth($bw)) ///
		(bar Marg_Dispersion_${estimate} BirthYearChild, ///
		fcolor(black) barwidth($bw)) ///
		(bar Marg_ObservedGr_${estimate} BirthYearChild, ///
		barwidth($bw)) ///
		(bar Marg_HomneousGr_${estimate} BirthYearChild, ///
		barwidth($bw)) ///
		(line AM_${estimate} BirthYearChild) ///
		, graphregion(fcolor(white) lcolor(white)) /// 	 
		plotregion(lcolor(black)) name(Men, replace) ///
		legend(cols(1) region(lcolor(white))) xlabel(1972(1)1983) ///
		scheme(s2mono) title("B.") xtitle(" ") ///
		ylabel(0.0 "50%" 0.1 "60%" 0.2 "70%" 0.3 "80%" 0.4 "90%")
	
cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
graph export "Figure A7 Decomposition Women Empirical Parent.png", as(png) replace
graph export "Figure A7 Decomposition Women Empirical Parent.pdf", as(pdf) replace
graph export "Figure A7 Decomposition Women Empirical Parent.tif", as(pdf) replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Figure A8 Household Decomposition.do"
