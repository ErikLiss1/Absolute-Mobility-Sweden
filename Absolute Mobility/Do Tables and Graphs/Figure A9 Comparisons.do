
/**************** Preamble: Set directories ****************/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

cd "$user_main\Absolute Mobility/Output Absolute Mobility"
use "Estimates for Figure A9", clear

keep if AMHousehold_30 !=.

global TopAge = 			30
global AgeatBirth = 		34
global ParentChildKind = 	1
global ReportedIncome = 	1

global B BirthYearChild 
global C connected      

twoway ($C AMHousehold_34 $B , mcolor(black) ///
		legend(label(1 "Household Income Age 30-34"))) ///
		(connected AM_32 $B, ///
		legend(label(2 "Household Income Age 32"))) ///
		($C AM_${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} $B , mcolor(black) ///
		legend(label(3 "Household Income Age 30")) ///
		msymbol(D) lpattern(solid) lcolor(black)) ///
		(line Manduca $B , lcolor(gs8) legend(label(4 "Manduca et al (2020)")) ///
		msymbol(O) lpattern(solid)) ///
		(line Berman $B , lcolor(black) legend(label(5 "Berman (2022)")) ///
		msymbol(O) lpattern(solid)) ///
		, graphregion(fcolor(white) lcolor(white)) ///
		plotregion(lcolor(black)) ///
		ytitle("") xtitle("") scheme(s2mono) yscale(titlegap(2)) ///
		legend(cols(1)) xlabel(1972(2)1983) ///
ylabel(0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%" 0.9 "90%" 1.0 "100%")

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
graph export "Figure 9 Manduca et al.png", as(png) replace
graph export "Figure 9 Manduca et al.pdf", as(pdf) replace
graph export "Figure 9 Manduca et al.tif", as(pdf) replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Table 1 Descriptive.do"
