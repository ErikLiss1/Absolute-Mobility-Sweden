
* Generating Figure 4:

/**************** Preamble: Set directories ****************/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

* We first load the complete data set:

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Absolute Mobility Merged", clear

/*

* We first load all estimates to get the birth cohorts that we then merge the 
results into.

*/

keep BirthYearChild

* Merge to get men's and women's absolute mobility 

global TopAge = 			34
global AgeatBirth = 		34
global ReportedIncome = 	1
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

forvalues c = 1(1)3 { 

global ParentChildKind = 	`c'

merge 1:1 BirthYearChild using "Absolute Mobility TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

}

rename AM_${TopAge}_${AgeatBirth}_1_${ReportedIncome}  AMFatherSon
rename AM_${TopAge}_${AgeatBirth}_2_${ReportedIncome} AMMotherDts
rename AM_${TopAge}_${AgeatBirth}_3_${ReportedIncome} AMFatherDts

* Merge to get absolute mobility but disposable income:

forvalues c = 1(1)2 { 

global ParentChildKind = 	`c'

merge 1:1 BirthYearChild using "Absolute Mobility DispIncome TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

}

rename AM_${TopAge}_${AgeatBirth}_1_${ReportedIncome} AMDispSon
rename AM_${TopAge}_${AgeatBirth}_2_${ReportedIncome} AMDispDts

* Merge to get houeshold estimate:

global TopAge = 			34
global AgeatBirth = 		34
global ParentChildKind = 	1
global ReportedIncome = 	1

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
merge 1:1 BirthYearChild using "Absolute Mobility Household TopAge 2 $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome"

rename AM_${TopAge}_${AgeatBirth}_1_${ReportedIncome} AMHousehold

* Removing birthcohorts with no absolute mobility estimates:

keep if AMFatherSon !=.

* Plotting graphs:
	
twoway 	(connected AMMotherDts BirthYearChild, ///
	legend(label (1 "Swedish women (compared to mother's earnings)"))) ///
	(connected AMFatherSon BirthYearChild, ///
	legend(label (2 "Swedish men (compared to father's earnings)"))) ///
	(connected AMHousehold BirthYearChild, ///
	legend(label (3 "Household earnings"))) ///
	(line AMDispSon BirthYearChild, ///
	legend(label (4 "Swedish men (compared to father's disposable income)"))) ///
	(line AMDispDts BirthYearChild, ///
	legend(label (5 "Swedish women (compared to mother's disposable income)"))) ///
	, graphregion(fcolor(white) lcolor(white)) plotregion(lcolor(black)) ///
	legend(cols(1)) ytitle("") xtitle("") xlabel(1972(1)1983) ///
	scheme(s2mono) yscale(titlegap(2)) ///
	ylabel(0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 0.9 "90%" 1.0 "100%")

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
graph export "Figure 3.png", as(png) replace
graph export "Figure 3.pdf", as(pdf) replace
graph export "Figure 3.tif", as(pdf) replace

save "Table For Main Figure", replace

export excel "Table For Main Figure", firstrow(variables) replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Figure 4 Parent Distribution effect.do"
