
/**************** Preamble: Set directories ****************/

// user specific paths
global user_main " " // Your working directory

/***********************************************************/


use "${user_main}/Do Parent Dispersion Effect/Samples/par Estimates from US Samples", clear

append using "${user_main}/Do Parent Dispersion Effect/Samples/Reference Point Sample"
append using "${user_main}/Do Parent Dispersion Effect/Samples/Parent Dispersion Swedish.dta"

replace Gini = Gini * 100
replace AbsoluteMobility = AbsoluteMobility * 100
replace GrowthRate=round(GrowthRate,.1)

label variable BirthYearChild "Birth Cohort"
label variable Gini "Gini Coefficient"
label variable GrowthRate "Yearly Growth Rate"
label variable AbsoluteMobility "Absolute Mobility"

drop if Gini > 42
drop if Gini < 2

sum Gini if round(LogSD,.01) == 0.5
global ref = round(r(mean),.001)/100
di $ref

replace Gini = Gini/100

twoway  (scatter AbsoluteMobility Gini if GrowthRate==1 & Sample == 1, ///
		mcolor(blue) msymbol(circle) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==5 & Sample == 1, ///
		mcolor(black) msymbol(circle) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==10 & Sample == 1, ///
		mcolor(red) msymbol(circle) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==20 & Sample == 1, ///
		mcolor(green) msymbol(circle) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==30 & Sample == 1, ///
		mcolor(dkorange) msymbol(circle) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==1 & Sample == 2, ///
		mcolor(blue) msymbol(square) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==5 & Sample == 2, ///
		mcolor(black) msymbol(square) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==10 & Sample == 2, ///
		mcolor(red) msymbol(square) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==20 & Sample == 2, ///
		mcolor(green) msymbol(square) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==30 & Sample == 2, ///
		mcolor(dkorange) msymbol(square) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==1 & Sample == 3, ///
		mcolor(blue) msymbol(diamond) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==5 & Sample == 3, ///
		mcolor(black) msymbol(diamond) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==10 & Sample == 3, ///
		mcolor(red) msymbol(diamond) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==20 & Sample == 3, ///
		mcolor(green) msymbol(diamond) mlcolor(black)) ///
		(scatter AbsoluteMobility Gini if GrowthRate==30 & Sample == 3, ///
		mcolor(dkorange) msymbol(diamond) mlcolor(black)) ///
		(line AbsoluteMobility Gini if GrowthRate==1 & Sample == 4, ///
		lpattern(solid) lcolor(blue)) ///
		(line AbsoluteMobility Gini if GrowthRate==5 & Sample == 4, ///
		lpattern(dash) lcolor(black)) ///
		(line AbsoluteMobility Gini if GrowthRate==10 & Sample == 4, ///
		lpattern(dot) lcolor(red)) ///
		(line AbsoluteMobility Gini if GrowthRate==20 & Sample == 4, ///
		lpattern(dash_dot) lcolor(green)) ///
		(line AbsoluteMobility Gini if GrowthRate==30 & Sample == 4, ///
		lpattern(longdash) lcolor(dkorange)) ///
		, xlabel(0(0.05)0.5) scheme(s2mono) graphregion(fcolor(white) ///
		lcolor(white)) plotregion(lcolor(white)) xtitle(Gini Coefficient) ///
		ytitle("Absolute Mobility (%)") ///
		legend(region(lwidth(none)) cols(3) order(1 "Swedish Fathers (0.1% Yearly Growth)" 2 "Swedish Fathers (0.5% Yearly Growth)" 3 "Swedish Fathers (1% Yearly Growth)" 4 "Swedish Fathers (2% Yearly Growth)" 5 "Swedish Fathers (3% Yearly Growth)"  6 "Swedish Mothers (0.1% Yearly Growth)" 7 "Swedish Mothers (0.5% Yearly Growth)" 8 "Swedish Mothers (1% Yearly Growth)" 9 "Swedish Mothers (2% Yearly Growth)" 10 "Swedish Mothers (3% Yearly Growth)" 11 "US Parents (0.1% Yearly Growth)" 12 "US Parents (0.5% Yearly Growth)" 13 "US Parents (1% Yearly Growth)" 14 "US Parents (2% Yearly Growth)" 15 "US Parents (3% Yearly Growth)" 16 "Log-normal (0.1% Yearly Growth)" 17 "Log-normal (0.5% Yearly Growth)" 18 "Log-normal (1% Yearly Growth)" 19 "Log-normal (2% Yearly Growth)" 20 "Log-normal 3% Yearly Growth") size(vsmall)) xline(${ref}, lpattern(dash)) xsize(7) ///
		text(102 0.17  "{bf:Swedish Fathers' Distributions:}", size(small) width(85)) ///
		text(97 0.28  "{bf:Swedish Mothers' Distributions:}", size(small) width(85)) ///
		text(91 0.37  "{bf:US Parent Distributions}", size(small) width(85)) ///
		text(87 0.37 "{bf:(from Chetty et al. 2017):}", size(small) width(85)) ///
		text(51 0.46 "0.1% Yearly Growth", size(small) width(85)) ///
		text(55 0.46 "0.5% Yearly Growth", size(small) width(85)) ///
		text(60 0.46 "1.0% Yearly Growth", size(small) width(85)) ///
		text(70 0.46 "2.0% Yearly Growth", size(small) width(85)) ///
		text(80 0.46 "3.0% Yearly Growth", size(small) width(85)) ///
		text(86 0.46 "{bf:Log-normal}", size(small) width(120)) ///
		text(83 0.46 "{bf:distributions:}", size(small) width(120)) ///
		xline($ref , lcolor(gs9) lpattern(dash) ) ///
		text(102 0.345 "{bf:<- Reference Point Inequality}", size(small) width(120))
		
cd "${user_main}"		
graph export "Figure 4 Parent distribution effect.png", replace
graph export "Figure 4 Parent distribution effect.png", replace
graph export "Figure 4 Parent distribution effect.tif", replace


