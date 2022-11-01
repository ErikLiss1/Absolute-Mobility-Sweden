
/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working Directory
global connectionstring "" // Your connectionstring to SCL Server

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

rename AM_${estimate} AM_${estimate}_MultiYear

merge 1:1 BirthYearChild using "Absolute Mobility TopAge Single Year $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

rename AM_${estimate} AM_${estimate}_SingleYear

merge 1:1 BirthYearChild using "Decomposition TopAge Single Year $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

drop if Marg_HomneousGr_${estimate} ==.

drop HomneousGr_${estimate} ObservedGr_${estimate} Dispersion_${estimate} Exchange_${estimate}

replace AM_${estimate}_MultiYear = round(AM_${estimate}_MultiYear, 0.01)
replace AM_${estimate}_SingleYear = round(AM_${estimate}_SingleYear, 0.01)
replace Marg_HomneousGr_${estimate} = round(Marg_HomneousGr_${estimate}, 0.001)
replace Marg_ObservedGr_${estimate} = round(Marg_ObservedGr_${estimate}, 0.001)
replace Marg_Dispersion_${estimate} = round(Marg_Dispersion_${estimate}, 0.001)
replace Marg_Exchange_${estimate} = round(Marg_Exchange_${estimate}, 0.001)

label variable BirthYearChild ///
"Birth Cohort"

label variable AM_${estimate}_MultiYear ///
"Absolute Mobility (Incomes at age 30-34)"

label variable AM_${estimate}_SingleYear ///
"Absolute Mobility Single Income Year"

label variable  Marg_HomneousGr_${estimate} ///
"{it: {&Delta}G} Growth component"

label variable  Marg_ObservedGr_${estimate}	///
"{it: {&Delta}D{superscript: p}} Parent dispersion component"

label variable  Marg_Dispersion_${estimate} ///
"{it: {&Delta}D{superscript: c}} Child dispersion component"

label variable  Marg_Exchange_${estimate} ///
"{it: {&Delta}E} Exchange component"

*save "Decomposition Table Men Single Year", replace
*export excel "Decomposition Table Men", firstrow(varlabels) replace

* Adjusting values for graphs:

replace AM_${estimate}_MultiYear = AM_${estimate}_MultiYear - 0.5
replace AM_${estimate}_SingleYear = AM_${estimate}_SingleYear - 0.5

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
		(connected AM_${estimate}_SingleYear BirthYearChild) ///
		(line AM_${estimate}_MultiYear BirthYearChild) ///
		, graphregion(fcolor(white) lcolor(white)) /// 	 
		plotregion(lcolor(black)) ///
		legend(cols(1) region(lcolor(white))) xlabel(1972(2)1983) ///
		scheme(s2mono) title("Incomes at age 34") xtitle(" ") name(SingleYear, replace) ///
		ylabel(-0.1 "40%" 0.0 "50%" 0.1 "60%" 0.2 "70%" 0.3 "80%" 0.4 "90%")

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Absolute Mobility Merged", clear

global TopAge = 			34
global AgeatBirth = 		34
global ReportedIncome = 	1
global ParentChildKind = 	1

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

keep BirthYearChild AM_${estimate}

rename AM_${estimate} AM_${estimate}_MultiYear

merge 1:1 BirthYearChild using "Absolute Mobility TopAge Single Year $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

rename AM_${estimate} AM_${estimate}_SingleYear

merge 1:1 BirthYearChild using "Decomposition TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

drop if Marg_HomneousGr_${estimate} ==.

drop HomneousGr_${estimate} ObservedGr_${estimate} Dispersion_${estimate} Exchange_${estimate}

replace AM_${estimate}_MultiYear = round(AM_${estimate}_MultiYear, 0.01)
replace AM_${estimate}_SingleYear = round(AM_${estimate}_SingleYear, 0.01)
replace Marg_HomneousGr_${estimate} = round(Marg_HomneousGr_${estimate}, 0.001)
replace Marg_ObservedGr_${estimate} = round(Marg_ObservedGr_${estimate}, 0.001)
replace Marg_Dispersion_${estimate} = round(Marg_Dispersion_${estimate}, 0.001)
replace Marg_Exchange_${estimate} = round(Marg_Exchange_${estimate}, 0.001)

label variable BirthYearChild ///
"Birth Cohort"

label variable AM_${estimate}_MultiYear ///
"Absolute Mobility (Incomes at age 30-34)"

label variable AM_${estimate}_SingleYear ///
"Absolute Mobility Single Income Year"

label variable  Marg_HomneousGr_${estimate} ///
"{it: {&Delta}G} Growth component"

label variable  Marg_ObservedGr_${estimate}	///
"{it: {&Delta}D{superscript: p}} Parent dispersion component"

label variable  Marg_Dispersion_${estimate} ///
"{it: {&Delta}D{superscript: c}} Child dispersion component"

label variable  Marg_Exchange_${estimate} ///
"{it: {&Delta}E} Exchange component"

save "Decomposition Table Men", replace
export excel "Decomposition Table Women", firstrow(varlabels) replace

* Adjusting values for graphs:

replace AM_${estimate}_MultiYear = AM_${estimate}_MultiYear - 0.5
replace AM_${estimate}_SingleYear = AM_${estimate}_SingleYear - 0.5

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
		(connected AM_${estimate}_SingleYear BirthYearChild) ///
		(line AM_${estimate}_MultiYear BirthYearChild) ///
		, graphregion(fcolor(white) lcolor(white)) /// 	 
		plotregion(lcolor(black)) ///
		legend(cols(1) region(lcolor(white))) xlabel(1972(2)1983) ///
		scheme(s2mono) title("Incomes between age 30-34") xtitle(" ") name(MultiYear, replace) ///
		ylabel(-0.1 "40%" 0.0 "50%" 0.1 "60%" 0.2 "70%" 0.3 "80%" 0.4 "90%")

graph combine SingleYear MultiYear, graphregion(fcolor(white))

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
graph export "Single Year Decompositions Men.png", replace
graph export "Single Year Decompositions Men.pdf", replace


* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Figure A3 Single Years Decomposition Women.do"

