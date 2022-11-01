
/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

cd "$user_main\Absolute Mobility\Estimates"
use "Female Labor Participation Counterfactuals"

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
merge 1:1 BirthYearChild using "Absolute Mobility TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", keepusing(AM_${estimate}) nogenerate
		
twoway 	 (connected ObservedGr_2 BirthYearChild, ///
		legend(label(1 "Participation and Parent Distribution Fixed"))) ///
		(connected ObservedGr_1 BirthYearChild, ///
		legend(label(2 "Parent Distribution Fixed"))) ///
		(connected ObservedGr_3 BirthYearChild, ///
		lstyle(solid) legend(label(3 "Varying Parent Participation and Distribution"))) ///
		(line AM_${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} ///
		BirthYearChild, lstyle(dashed) legend(label(4 "Baseline Absolute Mobility"))), ///
		graphregion(fcolor(white)) ylabel(0.5 "50%" 0.6 "60%" 0.7 "70%" 0.8 "80%" 0.9 "90%") ///
		scheme(s2mono) legend(cols(1)) xlabel(1973(2)1982)

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
graph export "Labour Force Participation Rate Counterfactual 4.pdf", as(pdf) replace
graph export "Labour Force Participation Rate Counterfactual 4.png", as(png) replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "A1 Alternative Decompositions Sequence.do"
