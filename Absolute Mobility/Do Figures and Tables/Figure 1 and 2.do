
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

* Growth component:
gen Growth = 	Parent*1.5

*Dispersion component:
gen Dispersion = 	rnormal(5,1.5)

* Removing zero incomes:
drop if 	Parent < 0
drop if 	Growth < 0
drop if 	Dispersion<  0

* Removing expreme values to ease interpretation

foreach i in Parent Dispersion {

sort `i'
gen rank = _n
drop if rank < 200
drop if rank > (_N-200)
drop rank
}

* Growth Component

twoway histogram Parent, percent fc(gs10) lc(gs8) bin(100) xscale(log)|| histogram Growth, percent bin(100) fc(none) lc(edkblue) xscale(log) graphregion(fcolor(white)) bgcolor(white) legend(off) xtitle(Log of Income) title(Growth Component) name(growth, replace)

* Dispersion component

twoway histogram Parent, percent bin(100) fc(gs10) lc(gs8) || histogram Dispersion, percent bin(100) fc(none) lc(edkblue) graphregion(fcolor(white)) legend(order(1 "Parent Income Distribution" 2 "Child Income Distribution") cols(1)) xtitle(Income) title(Dispersion Component)  name(Dispersion, replace)

*Combined Graph

graph combine growth Dispersion, col(1) graphregion(fcolor(white))

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
graph export "GrowthDispersion.png", replace

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

* Applying 40 percent cross generational growth

gen Growth = 	Bench * 1.4
gen Growth2 = 	Bench2 * 1.4

* Removing expreme values to ease interpretation

xtile PercentileParent1 = Parent, nq(1000)
xtile PercentileParent2 = Parent2, nq(1000)

drop if PercentileParent1 > 995
drop if PercentileParent2 > 995

drop if PercentileParent1 < 5
drop if PercentileParent2 < 5

* Draw gigures and combine into one graph

twoway histogram Parent, percent fc(gs10) lc(gs8) bin(100) || histogram Growth, percent bin(100) fc(none) lc(edkblue) xlabel(0(25)25) ylabel(0(1)2) graphregion(fcolor(white)) bgcolor(white) legend(off) name(growth, replace)

twoway histogram Parent2, percent fc(gs10) lc(gs8) bin(100) || histogram Growth2, percent bin(100) fc(none) lc(edkblue) xlabel(0(25)25) ylabel(0(1)2)  graphregion(fcolor(white)) bgcolor(white) xtitle(Income) name(growth2, replace) legend(order(1 "Parent Income Distribution" 2 "Child Income Distribution"))

graph combine growth growth2, col(1) graphregion(fcolor(white))

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
graph export "Parent Distribution Overlap.png", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Figure 3 Absolute mobility.do"
