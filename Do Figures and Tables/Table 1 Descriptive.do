
/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

* Generating Descriptive Table:

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Absolute Mobility Merged", clear

keep BirthYearChild

global TopAge = 			34
global AgeatBirth = 		34
global ReportedIncome = 	1

forvalues c = 1(1)2 { 

global ParentChildKind = 	`c'

merge 1:1 BirthYearChild using "Desc TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", nogenerate

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

replace bRM_${estimate} = round(bRM_${estimate}, 0.001)
replace seRM_${estimate} = round(seRM_${estimate}, 0.001)
replace ChildEarningGini_${estimate} = round(ChildEarningGini_${estimate}, 0.001)
replace ParentEarningGini_${estimate} = round(ParentEarningGini_${estimate}, 0.001)
replace meanEarningRatio_${estimate} = round(meanEarningRatio_${estimate}, 0.001)

replace meanChildEarning_${estimate} = meanChildEarning_${estimate}/10
replace meanParentEarning_${estimate} = meanParentEarning_${estimate}/10

replace meanChildEarning_${estimate} = round(meanChildEarning_${estimate}, 0.1)
replace meanParentEarning_${estimate} = round(meanParentEarning_${estimate}, 0.1)

replace b_Elasticity_${estimate} = round(b_Elasticity_${estimate}, 0.001)
replace se_Elasticity_${estimate} = round(se_Elasticity_${estimate}, 0.001)

}

keep if Obs_${estimate} !=  . 

global ParentChildKind = 1
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

rename BirthYearChild BirthYearChild_${estimate}
gen BirthYearChild2 = BirthYearChild

label variable BirthYearChild_${estimate} "Child Birth Cohort"
label variable Obs_${estimate}	"Number of Observations"
label variable bRM_${estimate} 	"Sons' relative mobility"
label variable seRM_${estimate} "Sons' relative mobility SE"
label variable ChildEarningGini_${estimate} "Sons' Gini coefficient"
label variable ParentEarningGini_${estimate} "Fathers' Gini coefficient"
label variable meanEarningRatio_${estimate} "Mean Son-Father earning ratio"
label variable meanChildEarning_${estimate} "Son's mean earning"
label variable meanParentEarning_${estimate} "Fathers' mean earning"
label variable b_Elasticity_${estimate} "Sons' relative mobility (Elasticity)"
label variable se_Elasticity_${estimate} "Sons' relative mobility SE (Elasticity)"

drop b_Elasticity_${estimate} 
drop se_Elasticity_${estimate}
drop seRM_${estimate}

global ParentChildKind = 2
global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

rename BirthYearChild2 BirthYearChild_${estimate}

label variable BirthYearChild_${estimate} "Child Birth Cohort"
label variable Obs_${estimate}	"Number of Observations"
label variable bRM_${estimate} 	"Daughters' relative mobility"
label variable seRM_${estimate} "Daughters' relative mobility SE"
label variable ChildEarningGini_${estimate} "Daughters' Gini coefficient"
label variable ParentEarningGini_${estimate} "Mothers' Gini coefficient"
label variable meanEarningRatio_${estimate} "Mean Daughter-Mother earning ratio"
label variable meanChildEarning_${estimate} "Daughters' mean earning"
label variable meanParentEarning_${estimate} "Mother' mean earning"
label variable b_Elasticity_${estimate} "Daughters' relative mobility (Elasticity)"
label variable se_Elasticity_${estimate} "Daughters' relative mobility SE (Elasticity)"

drop b_Elasticity_${estimate} 
drop se_Elasticity_${estimate}
drop seRM_${estimate}

order 	BirthYearChild_34_34_1_1 ///
		Obs_34_34_1_1 ///
		meanChildEarning_34_34_1_1 ///
		meanParentEarning_34_34_1_1 ///
		meanEarningRatio_34_34_1_1 ///
		ChildEarningGini_34_34_1_1 ///
		ParentEarningGini_34_34_1_1 ///
		bRM_34_34_1_1 ///
		BirthYearChild_34_34_2_1 ///
		Obs_34_34_2_1 ///
		meanChildEarning_34_34_2_1 ///
		meanParentEarning_34_34_2_1 ///
		meanEarningRatio_34_34_2_1 ///
		ChildEarningGini_34_34_2_1 ///
		ParentEarningGini_34_34_2_1 ///
		bRM_34_34_2_1

global obs = _N+1
set obs $obs

replace BirthYearChild_34_34_1_1 = 1 if ///
 		BirthYearChild_34_34_1_1 ==. 

sort BirthYearChild_34_34_1_1
		
replace BirthYearChild_34_34_1_1 = . if ///
 		BirthYearChild_34_34_1_1 == 1

* tostring _all, replace force

tostring BirthYearChild*, replace
tostring Obs*, replace
tostring meanChildEarning*, replace format(%5.1fc) force
tostring meanParentEarning*, replace format(%5.1fc) force
tostring meanEarningRatio*, replace format(%4.2fc) force
tostring ChildEarningGini*, replace format(%4.2fc) force
tostring ParentEarningGini*, replace format(%4.2fc) force
tostring bRM*, replace format(%4.2fc) force
		
global varlist "BirthYearChild_34_34_1_1 Obs_34_34_1_1 meanChildEarning_34_34_1_1 meanParentEarning_34_34_1_1 meanEarningRatio_34_34_1_1 ChildEarningGini_34_34_1_1 ParentEarningGini_34_34_1_1 bRM_34_34_1_1 BirthYearChild_34_34_2_1 Obs_34_34_2_1 meanChildEarning_34_34_2_1 meanParentEarning_34_34_2_1 meanEarningRatio_34_34_2_1 ChildEarningGini_34_34_2_1 ParentEarningGini_34_34_2_1 bRM_34_34_2_1"

global Numb = 1

foreach i of varlist $varlist { 

replace `i' = "($Numb)" if `i' == "."

global Numb = $Numb + 1

}

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
save "Descriptive Table", replace

export excel "Descriptive Table", firstrow(varlabels) replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
doedit "Table A1-A4 Descriptive Labor force.do"

