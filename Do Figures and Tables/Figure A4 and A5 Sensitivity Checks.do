
/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

* Generating Main Figure Graph:

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Absolute Mobility Merged", clear

keep BirthYearChild 
global ParentChildKind = 	1

foreach a in 30 32 34 38 { 
foreach b in 32 34 38 {
forvalues d = 0(1)1 {

global TopAge = 			`a'
global AgeatBirth = 		`b'
global ReportedIncome = 	`d'

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome}

merge 1:1 BirthYearChild using "Absolute Mobility TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

}
}
}


global B BirthYearChild 
global C connected   

twoway ///
($C AM_38_34_1_1 $B , mcolor(black) legend(label(1 "Age span 30-38, Age at childbirth<34, inc. zero incomes")) msymbol(O) lpattern(solid) lcolor(black)) ///
($C AM_38_38_1_1 $B , mcolor(black) legend(label(2 "Age span 30-38, Age at childbirth<38, inc. zero incomes"))  msymbol(O) lpattern(dash_dot) lcolor(black)) ///
($C AM_38_34_1_0 $B , mcolor(gs8) legend(label(3 "Age span 30-38, Age at childbirth<34, exl. zero incomes")) msymbol(O) lpattern(solid) lcolor(gs8)) ///
($C AM_38_38_1_0 $B , mcolor(gs8) legend(label(4 "Age span 30-38, Age at childbirth<38, exl. zero incomes")) msymbol(O) lpattern(dash_dot) lcolor(gs8)) ///
($C AM_34_34_1_1 $B , mcolor(black) legend(label(5 "Age span 30-34, Age at childbirth<34, inc. zero incomes")) msymbol(D) lpattern(solid) lcolor(black)) ///
($C AM_34_38_1_1 $B , mcolor(black) legend(label(6 "Age span 30-34, Age at childbirth<38, inc. zero incomes")) msymbol(D) lpattern(dash_dot) lcolor(black)) ///
($C AM_34_34_1_0 $B , legend(label(7 "Agespan 30-34, Age at childbirth<34, exl. zero incomes")) mcolor(gs8) msymbol(D) lpattern(solid) lcolor(gs8)) ///
($C AM_34_38_1_0 $B , mcolor(gs8) legend(label(8 "Age span 30-34, Age at childbirth<38, exl. zero incomes")) msymbol(D) lpattern(dash_dot) lcolor(gs8)) ///
($C AM_32_34_1_1 $B , mcolor(blue) legend(label(9 "Age span 30-32, Age at childbirth<34, inc. zero incomes")) msymbol(O) lpattern(solid) lcolor(black)) ///
($C AM_30_34_1_1 $B , mcolor(red) legend(label(10 "Age span 30-30, Age at childbirth<34, inc. zero incomes"))  msymbol(O) lpattern(dash_dot) lcolor(black)) ///
($C AM_30_32_1_1 $B , mcolor(red) legend(label(10 "Age span 30-30, Age at childbirth<34, inc. zero incomes"))  msymbol(O) lpattern(dash_dot) lcolor(black)) ///
($C AM_32_32_1_1 $B , mcolor(red) legend(label(10 "Age span 30-30, Age at childbirth<34, inc. zero incomes"))  msymbol(O) lpattern(dash_dot) lcolor(black)) ///
, graphregion(fcolor(white) lcolor(white)) plotregion(lcolor(black)) ///
 ytitle("") xtitle("") scheme(s2mono) yscale(titlegap(2)) legend(cols(1)) 
 
 
twoway ///
($C AM_38_34_1_1 $B , mcolor(black) legend(label(1 "Age span 30-38, Age at childbirth<34, inc. zero incomes")) msymbol(O) lpattern(solid) lcolor(black)) ///
($C AM_38_38_1_1 $B , mcolor(black) legend(label(2 "Age span 30-38, Age at childbirth<38, inc. zero incomes"))  msymbol(O) lpattern(dash_dot) lcolor(black)) ///
($C AM_38_34_1_0 $B , mcolor(gs8) legend(label(3 "Age span 30-38, Age at childbirth<34, exl. zero incomes")) msymbol(O) lpattern(solid) lcolor(gs8)) ///
($C AM_38_38_1_0 $B , mcolor(gs8) legend(label(4 "Age span 30-38, Age at childbirth<38, exl. zero incomes")) msymbol(O) lpattern(dash_dot) lcolor(gs8)) ///
($C AM_34_34_1_1 $B , mcolor(black) legend(label(5 "Age span 30-34, Age at childbirth<34, inc. zero incomes")) msymbol(D) lpattern(solid) lcolor(black)) ///
($C AM_34_38_1_1 $B , mcolor(black) legend(label(6 "Age span 30-34, Age at childbirth<38, inc. zero incomes")) msymbol(D) lpattern(dash_dot) lcolor(black)) ///
($C AM_34_34_1_0 $B , legend(label(7 "Agespan 30-34, Age at childbirth<34, exl. zero incomes")) mcolor(gs8) msymbol(D) lpattern(solid) lcolor(gs8)) ///
($C AM_34_38_1_0 $B , mcolor(gs8) legend(label(8 "Age span 30-34, Age at childbirth<38, exl. zero incomes")) msymbol(D) lpattern(dash_dot) lcolor(gs8)) ///
, graphregion(fcolor(white) lcolor(white)) plotregion(lcolor(black)) ///
 ytitle("") xtitle("") xlabel(1972(1)1983) scheme(s2mono) yscale(titlegap(2)) legend(cols(1)) ylabel(0.7 "70%" 0.75 "75%" 0.8 "80%" 0.85 "85%")

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
graph export "Robustness Check Men.png", as(png) replace
graph export "Robustness Check Men.pdf", as(pdf) replace

/***********************************************************/

* Generating Main Figure Graph:

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Absolute Mobility Merged", clear

keep BirthYearChild 
global ParentChildKind = 	2

forvalues a = 34(2)40 { 
forvalues b = 32(2)38 {
* forvalues c = 1(1)4 {
forvalues d = 0(1)1 {

global TopAge = 			`a'
global AgeatBirth = 		`b'
* global ParentChildKind = 	`c'
global ReportedIncome = 	`d'

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome}

merge 1:1 BirthYearChild using "Absolute Mobility TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

}
}
*}
}

drop if AM_34_34_2_0 ==. 

global B BirthYearChild 
global C connected                           

twoway ///
($C AM_38_34_2_1 $B , mcolor(black) legend(label(1 "Age span 30-38, Age at childbirth<34, inc. zero incomes")) msymbol(O) lpattern(solid) lcolor(black)) ///
($C AM_38_38_2_1 $B , mcolor(black) legend(label(2 "Age span 30-38, Age at childbirth<38, inc. zero incomes"))  msymbol(O) lpattern(dash_dot) lcolor(black)) ///
($C AM_38_34_2_0 $B , mcolor(gs8) legend(label(3 "Age span 30-38, Age at childbirth<34, exl. zero incomes")) msymbol(O) lpattern(solid) lcolor(gs8)) ///
($C AM_38_38_2_0 $B , mcolor(gs8) legend(label(4 "Age span 30-38, Age at childbirth<38, exl. zero incomes")) msymbol(O) lpattern(dash_dot) lcolor(gs8)) ///
($C AM_34_34_2_1 $B , mcolor(black) legend(label(5 "Age span 30-34, Age at childbirth<34, inc. zero incomes")) msymbol(D) lpattern(solid) lcolor(black)) ///
($C AM_34_38_2_1 $B , mcolor(black) legend(label(6 "Age span 30-34, Age at childbirth<38, inc. zero incomes")) msymbol(D) lpattern(dash_dot) lcolor(black)) ///
($C AM_34_34_2_0 $B , legend(label(7 "Agespan 30-34, Age at childbirth<34, exl. zero incomes")) mcolor(gs8) msymbol(D) lpattern(solid) lcolor(gs8)) ///
($C AM_34_38_2_0 $B , mcolor(gs8) legend(label(8 "Age span 30-34, Age at childbirth<38, exl. zero incomes")) msymbol(D) lpattern(dash_dot) lcolor(gs8)) ///
, graphregion(fcolor(white) lcolor(white)) plotregion(lcolor(black)) ///
 ytitle("") xtitle("") xlabel(1972(1)1983) scheme(s2mono) yscale(titlegap(2)) legend(cols(1)) ylabel(0.75 "75%" 0.8 "80%" 0.85 "85%" 0.9 "90%")

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
graph export "Robustness Check Women.png", as(png) replace
graph export "Robustness Check Women.pdf", as(pdf) replace
 
 
* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Figure A6 Payroll Taxes.do"

