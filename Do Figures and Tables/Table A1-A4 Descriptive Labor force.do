
/*****

This Do-file generates descriptive tables for labor force participation.

*****/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

global TopAge = 			34
global AgeatBirth = 		34
global ParentChildKind = 	1
global ReportedIncome = 	1

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Desc Labour Force Participation TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", clear

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

global List AM_34_34_${ParentChildKind}_1 WithinGiniParent BetweenGiniParent WithinGiniChild BetweenGiniChild WithinGiniParentWork0 WithinGiniParentWork1 WithinGiniChildWork0 WithinGiniChildWork1 GroupMeanChild0 GroupMeanParent0 WorkerParent0_Count WorkerChild0_Count WorkerChild0_Perc WorkerParent0_Perc GroupMeanChild1 GroupMeanParent1 WorkerParent1_Count WorkerChild1_Count WorkerChild1_Perc WorkerParent1_Perc

foreach k of global List {

replace `k' = round(`k', 0.001)

}

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

label variable BirthYearChild 		"Child Birth Cohort"
label variable AM_34_34_${ParentChildKind}_1 		"Absolute Mobility"
label variable WithinGiniParent 	"Fathers' within group Gini coefficient"
label variable BetweenGiniParent 	"Fathers' between group Gini coefficient"
label variable WithinGiniChild 		"Sons' within Gini coefficient"
label variable BetweenGiniChild 	"Sons' between Gini coefficient"
label variable GroupMeanChild0 		"Mean income of sons not employed"
label variable GroupMeanParent0 	"Mean income of fathers not employed"
label variable WorkerParent0_Count 	"Number of fathers not employed"
label variable WorkerChild0_Count 	"Number of sons not employed"
label variable WorkerChild0_Perc 	"Percent of sons not employed"
label variable WorkerParent0_Perc 	"Percent of fathers not employed"
label variable GroupMeanChild1 		"Mean income of sons employed"
label variable GroupMeanParent1 	"Mean income of fathers employed"
label variable WorkerParent1_Count 	"Number of fathers employed"
label variable WorkerChild1_Count 	"Number of sons employed"
label variable WorkerChild1_Perc 	"Percent of sons employed"
label variable WorkerParent1_Perc 	"Percent of fathers employed"
label variable totalGiniChild 	"Sons' Gini coefficinet'"
label variable totalGiniParent	"Daughters' Gini coefficinet'"

global obs = _N+1
set obs $obs

replace BirthYearChild = 1 if ///
 		BirthYearChild ==. 

sort BirthYearChild
		
replace BirthYearChild = . if ///
 		BirthYearChild == 1

foreach i in GroupMeanChild0 GroupMeanParent0 GroupMeanChild1 GroupMeanParent1 {
	
replace `i' = `i' / 10
tostring `i', replace format(%5.1fc) force

}

foreach i in BirthYearChild WorkerParent0_Count WorkerChild0_Count WorkerParent1_Count WorkerChild1_Count {
	
tostring `i', replace

}

foreach i in WithinGiniParent BetweenGiniParent WithinGiniChild BetweenGiniChild WithinGiniParentWork0 WithinGiniParentWork1 WithinGiniChildWork0 WithinGiniChildWork1 WorkerChild1_Perc WorkerParent1_Perc WorkerParent0_Perc WorkerChild0_Perc totalGiniChild totalGiniParent {
	
tostring `i', replace format(%5.2fc) force

}

global varlist "BirthYearChild WorkerParent1_Perc WorkerChild1_Perc GroupMeanParent1 GroupMeanChild1   GroupMeanParent0 GroupMeanChild0  WithinGiniParent BetweenGiniParent totalGiniParent WithinGiniChild BetweenGiniChild totalGiniChild"

keep $varlist
order $varlist

global Numb = 1

foreach i of varlist $varlist { 

replace `i' = "($Numb)" if `i' == "."

global Numb = $Numb + 1

}

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
save "Descriptive Table Labour Force ParentChildKind $ParentChildKind", replace

export excel "Descriptive Table Labour Force ParentChildKind $ParentChildKind", firstrow(varlabels) replace





global TopAge = 			34
global AgeatBirth = 		34
global ParentChildKind = 	2
global ReportedIncome = 	1

cd "$user_main\Absolute Mobility\Output Absolute Mobility"
use "Desc Labour Force Participation TopAge $TopAge AgeatBirth $AgeatBirth ParentChildKind $ParentChildKind ReportedIncome $ReportedIncome", clear

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

global List AM_34_34_${ParentChildKind}_1 WithinGiniParent BetweenGiniParent WithinGiniChild BetweenGiniChild WithinGiniParentWork0 WithinGiniParentWork1 WithinGiniChildWork0 WithinGiniChildWork1 GroupMeanChild0 GroupMeanParent0 WorkerParent0_Count WorkerChild0_Count WorkerChild0_Perc WorkerParent0_Perc GroupMeanChild1 GroupMeanParent1 WorkerParent1_Count WorkerChild1_Count WorkerChild1_Perc WorkerParent1_Perc

foreach k of global List {

replace `k' = round(`k', 0.001)

}

global estimate ${TopAge}_${AgeatBirth}_${ParentChildKind}_${ReportedIncome} 

label variable BirthYearChild 		"Child Birth Cohort"
label variable AM_34_34_${ParentChildKind}_1 		"Absolute Mobility"
label variable WithinGiniParent 	"Mothers' within group Gini coefficient"
label variable BetweenGiniParent 	"Mothers' between group Gini coefficient"
label variable WithinGiniChild 		"Daughters' within Gini coefficient"
label variable BetweenGiniChild 	"Daughters' between Gini coefficient"
label variable GroupMeanChild0 		"Mean income of daughters not employed"
label variable GroupMeanParent0 	"Mean income of mothers not employed"
label variable WorkerParent0_Count 	"Number of mothers not employed"
label variable WorkerChild0_Count 	"Number of daughters not employed"
label variable WorkerChild0_Perc 	"Percent of daughters not employed"
label variable WorkerParent0_Perc 	"Percent of mothers not employed"
label variable GroupMeanChild1 		"Mean income of daughters employed"
label variable GroupMeanParent1 	"Mean income of mothers employed"
label variable WorkerParent1_Count 	"Number of mothers employed"
label variable WorkerChild1_Count 	"Number of daughters employed"
label variable WorkerChild1_Perc 	"Percent of daughters employed"
label variable WorkerParent1_Perc 	"Percent of mothers employed"
label variable totalGiniChild 	"Daughters' Gini coefficinet'"
label variable totalGiniParent	"Mothers' Gini coefficinet'"

global obs = _N+1
set obs $obs

replace BirthYearChild = 1 if ///
 		BirthYearChild ==. 

sort BirthYearChild
		
replace BirthYearChild = . if ///
 		BirthYearChild == 1

foreach i in GroupMeanChild0 GroupMeanParent0 GroupMeanChild1 GroupMeanParent1 {
	
replace `i' = `i' / 10
tostring `i', replace format(%5.1fc) force

}

foreach i in BirthYearChild WorkerParent0_Count WorkerChild0_Count WorkerParent1_Count WorkerChild1_Count {
	
tostring `i', replace

}

foreach i in WithinGiniParent BetweenGiniParent WithinGiniChild BetweenGiniChild WithinGiniParentWork0 WithinGiniParentWork1 WithinGiniChildWork0 WithinGiniChildWork1 WorkerChild1_Perc WorkerParent1_Perc WorkerParent0_Perc WorkerChild0_Perc totalGiniChild totalGiniParent {
	
tostring `i', replace format(%5.2fc) force

}

global varlist "BirthYearChild WorkerParent1_Perc WorkerChild1_Perc GroupMeanParent1 GroupMeanChild1 GroupMeanParent0 GroupMeanChild0  WithinGiniParent BetweenGiniParent totalGiniParent WithinGiniChild BetweenGiniChild totalGiniChild"

keep $varlist
order $varlist

global Numb = 1

foreach i of varlist $varlist { 

replace `i' = "($Numb)" if `i' == "."

global Numb = $Numb + 1

}

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
save "Descriptive Table Labour Force ParentChildKind $ParentChildKind", replace

export excel "Descriptive Table Labour Force ParentChildKind $ParentChildKind", firstrow(varlabels) replace
