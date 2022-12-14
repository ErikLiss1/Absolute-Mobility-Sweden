
/**************** Preamble: Set directories ****************/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

* Generating Main Figure Graph:

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Absolute Mobility Merged", clear

keep BirthYearChild

global TopAge = 			34
global AgeatBirth = 		34
global ReportedIncome = 	1
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

forvalues c = 1(1)2 { 

global ParentChildKind = 	`c'

merge 1:1 BirthYearChild using "Pay Roll Absolute Mobility TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

}

rename AM_${TopAge}_${AgeatBirth}_1_${ReportedIncome} AMFatherSonPayroll
rename AM_${TopAge}_${AgeatBirth}_2_${ReportedIncome} AMMotherDtsPayroll


forvalues c = 1(1)2 { 

global ParentChildKind = 	`c'

merge 1:1 BirthYearChild using "Absolute Mobility TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

}

rename AM_${TopAge}_${AgeatBirth}_1_${ReportedIncome} AMFatherSon
rename AM_${TopAge}_${AgeatBirth}_2_${ReportedIncome} AMMotherDts

keep if BirthYearChild >= 1974
drop if AMFatherSonPayroll==.
	
twoway 	(line AMFatherSon BirthYearChild, ///
	legend(label (1 "Swedish men (compared to father's earnings)"))) ///
	(connected AMMotherDts BirthYearChild, ///
	legend(label (2 "Swedish women (compared to mother's earnings)"))) ///
	(line AMFatherSonPayroll BirthYearChild, ///
	legend(label (3 "Swedish men incl. payroll tax (compared to father's earnings)"))) ///
	(connected AMMotherDtsPayroll BirthYearChild, ///
	legend(label (4 "Swedish women incl. payroll tax (compared to mother's earnings)"))) ///
	, graphregion(fcolor(white) lcolor(white)) plotregion(lcolor(black)) ///
	legend(cols(1)) ytitle("") xtitle("") xlabel(1974(1)1983) ///
	scheme(s2mono) yscale(titlegap(2)) ///
	ylabel(0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 0.9 "90%" 1.0 "100%")

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
graph export "Figure A6 Payroll Taxes.png", as(png) replace
graph export "Figure A6 Payroll Taxes.pdf", as(pdf) replace
graph export "Figure A6 Payroll Taxes.tif", as(pdf) replace

*export excel "Payroll Taxes Figure", firstrow(variables) replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Figure A7 Different Reference Point Distribution.do"
