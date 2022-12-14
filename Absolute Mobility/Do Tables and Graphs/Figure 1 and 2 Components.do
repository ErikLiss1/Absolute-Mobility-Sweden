
/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working Directory Directory
global connectionstring "" // Your connectionstring to SCL Server

/***********************************************************/

cd "$user_main\Absolute Mobility\Output Absolute Mobility"

* Figure 1: Growth and Dispersion Component:

clear all

set obs 1000000

* Generating Parent income distribution:
gen Parent = 	rnormal(5,1)

* Growth component, increasing mean by 50%:
gen Growth = 	Parent + 2.5

*Dispersion component, increasing standard deviation:
gen Dispersion = 	rnormal(5,1.5)

* Removing zero incomes:

xtile PercentileParent = Parent, nq(1000)
xtile PercentileGrowth = Growth, nq(1000)
xtile PercentileDispersion = Dispersion, nq(1000)

drop if PercentileParent > 995
drop if PercentileGrowth > 995
drop if PercentileDispersion > 995

drop if PercentileParent < 5
drop if PercentileGrowth < 5
drop if PercentileDispersion < 5

* Growth Component

twoway histogram Parent, percent fc(gs10) lc(gs8) bin(100) || histogram Growth, percent bin(100) fc(none) lc(edkblue) xlabel(0(12)12, nolabels) graphregion(fcolor(white)) bgcolor(white) legend(off) title(Growth Component) name(growth, replace)

* Dispersion component

twoway histogram Parent, percent bin(100) fc(gs10) lc(gs8) || histogram Dispersion, percent bin(100) fc(none) lc(edkblue) graphregion(fcolor(white)) legend(order(1 "Parent Income Distribution" 2 "Child Income Distribution") cols(1)) xtitle(Income) xlabel(, nolabels) title(Dispersion Component)  name(Dispersion, replace)

*Combined Graph

graph combine growth Dispersion, col(1) graphregion(fcolor(white))

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
graph export "Figure 1 GrowthDispersion.png", replace
graph export "Figure 1 GrowthDispersion.tif", replace

* Figure 2: Effect of parent component

* Growth and Dispersion Component:

clear all

set obs 1000000

* Generating two random distributions, one with higher standrad deviation

gen Parent = 	rnormal(10,1.5)
gen Parent2 = 	rnormal(10,3)

*Removing zero incomes

drop if 	Parent < 0
drop if 	Parent2 < 0

* Increasing mean by 40%:

gen Growth = 	Parent + 4
gen Growth2 = 	Parent2 + 4

* Removing extreme values to ease interpretation

xtile PercentileParent1 = Parent, nq(1000)
xtile PercentileParent2 = Parent2, nq(1000)

drop if PercentileParent1 > 995
drop if PercentileParent2 > 995

drop if PercentileParent1 < 5
drop if PercentileParent2 < 5

xtile PercentileParent3 = Parent, nq(1000)
xtile PercentileParent4 = Parent2, nq(1000)

drop if PercentileParent3 > 995
drop if PercentileParent4 > 995

drop if PercentileParent3 < 5
drop if PercentileParent4 < 5

* Draw gigures and combine into one graph

twoway histogram Parent, percent fc(gs10) lc(gs8) bin(100) || histogram Growth, percent bin(100) fc(none) lc(edkblue) xlabel(0(25)25, nolabels) ylabel(0(1)2) graphregion(fcolor(white)) bgcolor(white) legend(off) name(growth, replace)

twoway histogram Parent2, percent fc(gs10) lc(gs8) bin(100) || histogram Growth2, percent bin(100) fc(none) lc(edkblue) xlabel(0(25)25, nolabels) ylabel(0(1)2)  graphregion(fcolor(white)) bgcolor(white) xtitle(Income) name(growth2, replace) legend(order(1 "Parent Income Distribution" 2 "Child Income Distribution"))  

graph combine growth growth2, col(1) graphregion(fcolor(white))

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
graph export "Figure 2 Parent Distribution Overlap.png", replace
graph export "Figure 2 Parent Distribution Overlap.tif", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Figure 3 Absolute mobility.do"
