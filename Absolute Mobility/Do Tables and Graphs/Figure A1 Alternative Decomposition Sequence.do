
/**************** Preamble: Set directories ****************/

// user specific paths
global user " "								// your MONA user name
global user_main " " // Your working 

/***********************************************************/

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Alternative Decomposition Sequence", clear

clear all

sum Gini1 if round(SDp,.01) == 0.5
global Gini = round(r(mean),.001)*100

replace Gini2 = Gini2 * 100

sum AMDispFirst
global max1 = r(max)

sum AMDispAndGrowth001
global max2 = r(max)

sum AMDispAndGrowth005
global max3 = r(max)
		
sum AMDispAndGrowth01
global max4 = r(max)

sum AMDispAndGrowth02
global max5 = r(max)
		
sum AMDispAndGrowth03
global max6 = r(max)

twoway	(line AMDispFirst Gini2, sort lcolor(red)) ///
		(line AMDispAndGrowth001 Gini2, sort lpattern(solid) lcolor(blue)) ///
		(line AMDispAndGrowth005 Gini2, sort lpattern(solid) lcolor(blue)) ///
		(line AMDispAndGrowth01 Gini2, sort lpattern(solid) lcolor(blue)) ///
		(line AMDispAndGrowth02 Gini2, sort lpattern(solid) lcolor(blue)) ///
		(line AMDispAndGrowth03 Gini2, sort lpattern(solid) lcolor(blue)) ///
		(line AMGrowthFirst001 Gini2, sort lpattern(dash) lcolor(black)) ///
		(line AMGrowthFirst005 Gini2, sort lpattern(dash) lcolor(black)) ///
		(line AMGrowthFirst01 Gini2, sort lpattern(dash) lcolor(black)) ///
		(line AMGrowthFirst02 Gini2, sort lpattern(dash) lcolor(black)) ///
		(line AMGrowthFirst03 Gini2, sort lpattern(dash) lcolor(black)), ///
		graphregion(fcolor(white) lcolor(white)) ///
		legend(order(1 "Child dispersion component first" ///
		2 "Growth Component and Child Dispersion Component" ///
		7 "Growth component first") col(1)) ///
		plotregion(lcolor(black)) xtitle(Child Generation Gini Coefficient) ///
		ytitle("Absolute Mobility (%)") name(name1, replace) ///
		title("Simulated Absolute Mobility Rates") ///
		text(0.96 35 "Yearly growth over 30 years:") ///
		text($max2 24 "0.1%") ///
		text($max3 24 "0.5%") ///
		text($max4 24 "1%") ///
		text($max5 24 "2%") ///
		text($max6 24 "3%") ///
		xlabel(20(10)100) ///
		 xline(${Gini}, lcolor(gs9) lpattern(dash)) ///
		text(0.1 42 "<- Parent Generation Gini")

		
sum MargDispFirst
global min1 = r(min)

foreach i in MargDispifGrowthFirst {

sum `i'001
global `i'001 = r(min)

sum `i'005
global `i'005 = r(min)
		
sum `i'01
global `i'01 = r(min)

sum `i'02
global `i'02 = r(min)
		
sum `i'03
global `i'03 = r(min)
		
}

foreach i in MargGrowthFirst MargGrowthifDispFirst {

sum `i'001
global `i'001 = r(max)

sum `i'005
global `i'005 = r(max)
		
sum `i'01
global `i'01 = r(max)

sum `i'02
global `i'02 = r(max)
		
sum `i'03
global `i'03 = r(max)
		
}

sum Gini1 if round(SDp,.01) == 0.5
global Gini = round(r(mean),.001)*100

twoway  (line MargDispFirst Gini2, sort lcolor(red)) ///
		(line MargDispifGrowthFirst001 Gini2, sort lpattern(solid) lcolor(black)) ///
		(line MargDispifGrowthFirst005 Gini2, sort lpattern(solid) lcolor(black)) ///
		(line MargDispifGrowthFirst01 Gini2, sort lpattern(solid) lcolor(black)) ///
		(line MargDispifGrowthFirst02 Gini2, sort lpattern(solid) lcolor(black)) ///
		(line MargDispifGrowthFirst03 Gini2, sort lpattern(solid) lcolor(black)) ///
		(line MargGrowthifDispFirst001 Gini2, sort lpattern(shortdash) lcolor(forest_green)) ///
		(line MargGrowthifDispFirst005 Gini2, sort lpattern(shortdash) lcolor(forest_green)) ///
		(line MargGrowthifDispFirst01 Gini2, sort lpattern(shortdash) lcolor(forest_green)) ///
		(line MargGrowthifDispFirst02 Gini2, sort lpattern(shortdash) lcolor(forest_green)) ///
		(line MargGrowthifDispFirst03 Gini2, sort lpattern(shortdash) lcolor(forest_green)) ///
		(line MargGrowthFirst001 Gini2, sort lpattern(dash) lcolor(black)) ///
		(line MargGrowthFirst005 Gini2, sort lpattern(dash) lcolor(black)) ///
		(line MargGrowthFirst01 Gini2, sort lpattern(dash) lcolor(black)) ///
		(line MargGrowthFirst02 Gini2, sort lpattern(dash) lcolor(black)) ///
		(line MargGrowthFirst03 Gini2, sort lpattern(dash) lcolor(black)), ///
		graphregion(fcolor(white) lcolor(white)) ///
		legend(order(1 "Child dispersion component first" ///
		2 "Child dispersion component if Growth Component is first" 7 ///
		"Growth if Dispersion First" 12 "Growth component first") cols(1)) ///
		plotregion(lcolor(black)) xtitle(Child Generation Gini Coefficient) ///
		ytitle("Margal Contribution to Absolute Mobility (%)") ///
		name(name2, replace) title("Marginal Contribution") ///
		text(0.48 35 "Yearly growth over 30 years:") ///
		text($MargDispifGrowthFirst001 102 "0.1%") ///
		text($MargDispifGrowthFirst005 102 "0.5%") ///
		text($MargDispifGrowthFirst01 102 "1%") ///
		text($MargDispifGrowthFirst02 102 "2%") ///
		text($MargDispifGrowthFirst03 102 "3%") ///
		text($MargGrowthifDispFirst001 24 "0.1%") ///
		text($MargGrowthifDispFirst005 24 "0.5%") ///
		text($MargGrowthifDispFirst01 24 "1%") ///
		text($MargGrowthifDispFirst02 24 "2%") ///
		text($MargGrowthifDispFirst03 24 "3%")  ///
		xlabel(20(10)105) xline(${Gini}, lcolor(gs9) lpattern(dash)) ///
		text(-0.82 81 "Yearly growth over 30 years:") ///
		text(-1 44 "<- Parent Generation Gini")
	
graph combine name1 name2, col(2) graphregion(fcolor(white)) xsize(8)

cd "$user_main"
graph export "Figure A1. Combined Alternative Decomposition Sequence.png", replace
graph export "Figure A1. Combined Alternative Decomposition Sequence.pdf", replace
graph export "Figure A1. Combined Alternative Decomposition Sequence.tif", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Figure A2 Single Years Decomposition Men.do"
