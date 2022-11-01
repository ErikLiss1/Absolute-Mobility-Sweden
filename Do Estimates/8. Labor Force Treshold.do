
/*
In this do-file we calculate the cut-off for labor force participation.
We extract yearly incomes between 1968 and 2017 to get the income 
corresponding to 50% of yearly median income at age 45.
*/


/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

cd "$user_main/Absolute Mobility"

global Income_tax_a	68(1)77
global Income_tax_b	78(1)89

************************************************************************
****          		 Extract data from SQL 							****
************************************************************************
	
*Extract and load income variables, per year
cd "$user_main/Absolute Mobility/Extract"
forvalues InCyy = $Income_tax_a {
	display "`InCyy'"
	clear
	odbc load ///
		PersonLopNr ///
		SamForvInk`InCyy' ///
		, ///
	table("Ink19`InCyy'")connectionstring("DRIVER={ODBC Driver 17 for SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")
	
	rename SamForvInk`InCyy' SamForvInk
	gen Ar = `InCyy' + 1900
	rename Ar Year

* Removing duplicates:
	
bysort PersonLopNr: keep if _n == 1

tempfile data1
save `data1', replace

clear
odbc load ///
		PersonLopNr ///
		FodelseAr ///
		, ///
	table("Bakgrundsdata")connectionstring("DRIVER={ODBC Driver 17 for SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")

bysort PersonLopNr: keep if _n == 1
destring FodelseAr, replace
	
merge 1:1 PersonLopNr using `data1'
	
keep if Year - FodelseAr == 45
	
	sum SamForvInk, d
	gen PovertyLineMean = 0.5 * r(mean)
	gen PovertylineMedian = 0.5 * r(p50)
	
	sum SamForvInk if SamForvInk!=0, d
	gen PovertyLineMean2 = 0.5 * r(mean)
	gen PovertylineMedian2 = 0.5 * r(p50)
	
	collapse PovertyLineMean PovertylineMedian PovertyLineMean2 PovertylineMedian2, by(Year)
	
	tempfile l`InCyy'
	save `l`InCyy''

}

*Append years to one dataset

clear
forvalues InCyy = $Income_tax_a {

 append using `l`InCyy''
 
}

tempfile Badge1
save `Badge1', replace

*cd "$user_main/Absolute Mobility/Extract"
*save "Badge1", replace

*Extract and load income variables, per year
cd "$user_main/Absolute Mobility/Extract"
forvalues InCyy = $Income_tax_b {
	display "`InCyy'"
	clear
	odbc load ///
		PersonLopNr ///
		SamForvInk`InCyy' ///
		DispInk`InCyy' ///
		, ///
	table("Ink19`InCyy'")connectionstring("DRIVER={ODBC Driver 17 for SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")
	
	rename SamForvInk`InCyy' SamForvInk
	rename DispInk`InCyy' DispInk
	gen Ar = `InCyy' + 1900
	rename Ar Year
	
bysort PersonLopNr: keep if _n == 1

tempfile data1
save `data1', replace

clear
odbc load ///
		PersonLopNr ///
		FodelseAr ///
		, ///
	table("Bakgrundsdata")connectionstring("DRIVER={ODBC Driver 17 for SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")

bysort PersonLopNr: keep if _n == 1
destring FodelseAr, replace
	
merge 1:1 PersonLopNr using `data1'
	
destring Year, replace
destring SamForvInk, replace
	
keep if Year - FodelseAr == 45
	
	sum SamForvInk, d
	gen PovertyLineMean = 0.5 * r(mean)
	gen PovertylineMedian = 0.5 * r(p50)
	
	sum SamForvInk if SamForvInk!=0, d
	gen PovertyLineMean2 = 0.5 * r(mean)
	gen PovertylineMedian2 = 0.5 * r(p50)
	
	collapse PovertyLineMean PovertylineMedian PovertyLineMean2 PovertylineMedian2, by(Year)
	
	tempfile l`InCyy'
	save `l`InCyy''
	
}

*Append years to one dataset

clear
forvalues InCyy = $Income_tax_b {

 append using `l`InCyy''
 
}

tempfile Badge2
save `Badge2'

*cd "$user_main/Absolute Mobility/Extract"
*save "Badge2", replace

global LISA1 1990(1)2004

************************************************************************
****          		 Extract data from SQL 							****
************************************************************************	
*Extract and load income variables, per year
cd "$user_main/Absolute Mobility/Extract"
forvalues lisayyyy = $LISA1 {
	display "`lisayyyy'"
	clear
	odbc load ///
		PersonLopNr ///
		Ar ///
		ForvInk ///
		, ///
	table("LISA`lisayyyy'_Individ")connectionstring("DRIVER={ODBC Driver 17 for SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")
	
destring ForvInk, replace
bysort PersonLopNr: keep if _n == 1

rename Ar Year

tempfile data1
save `data1', replace

clear
odbc load ///
		PersonLopNr ///
		FodelseAr ///
		, ///
	table("Bakgrundsdata")connectionstring("DRIVER={ODBC Driver 17 for SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")

bysort PersonLopNr: keep if _n == 1
destring FodelseAr, replace
	
merge 1:1 PersonLopNr using `data1'
	
destring Year, replace
destring ForvInk, replace
	
keep if Year - FodelseAr == 45
	
	sum ForvInk, d
	gen PovertyLineMean = 0.5 * r(mean)
	gen PovertylineMedian = 0.5 * r(p50)
	
	sum ForvInk if ForvInk!=0, d
	gen PovertyLineMean2 = 0.5 * r(mean)
	gen PovertylineMedian2 = 0.5 * r(p50)
	
	collapse PovertyLineMean PovertylineMedian PovertyLineMean2 PovertylineMedian2, by(Year)
	
	tempfile l`lisayyyy'
	save `l`lisayyyy''
	
}

*Append years to one dataset
clear
forvalues lisayyyy = $LISA1 {

 append using `l`lisayyyy''
 
}

tempfile Badge3
save `Badge3'

cd "$user_main/Absolute Mobility/Extract"
save "Badge3", replace

global LISA2 2005(1)2017

****************************************************
****   		 Extract data from SQL 				****
****************************************************	

*Extract and load income variables, per year
cd "$user_main/Absolute Mobility/Extract"
forvalues lisayyyy = $LISA2 {
	display "`lisayyyy'"
	clear
	odbc load ///
		PersonLopNr ///
		Ar ///
		ForvInk ///
		, ///
	table("LISA`lisayyyy'_Individ")connectionstring("DRIVER={ODBC Driver 17 for SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")
	
destring ForvInk, replace
bysort PersonLopNr: keep if _n == 1

rename Ar Year

tempfile data1
save `data1', replace

clear
odbc load ///
		PersonLopNr ///
		FodelseAr ///
		, ///
	table("Bakgrundsdata")connectionstring("DRIVER={ODBC Driver 17 for SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")

bysort PersonLopNr: keep if _n == 1
destring FodelseAr, replace
	
merge 1:1 PersonLopNr using `data1'
	
destring Year, replace
destring ForvInk, replace
	
keep if Year - FodelseAr == 45
	
	sum ForvInk, d
	gen PovertyLineMean = 0.5 * r(mean)
	gen PovertylineMedian = 0.5 * r(p50)
	
	sum ForvInk if ForvInk!=0, d
	gen PovertyLineMean2 = 0.5 * r(mean)
	gen PovertylineMedian2 = 0.5 * r(p50)
	
	collapse PovertyLineMean PovertylineMedian PovertyLineMean2 PovertylineMedian2, by(Year)
	
	tempfile l`lisayyyy'
	save `l`lisayyyy''

}

*Append years to one dataset
clear
forvalues lisayyyy = $LISA2 {

 append using `l`lisayyyy'', force
 
}


append using `Badge3'
append using `Badge2'
append using `Badge1'
 
rename PovertylineMedian LaborThreshold

keep Year LaborThreshold

compress

cd "$user_main/Absolute Mobility/Extract"
save "Labor Force Threshold.dta", replace

* Open next DO file:

cd "$user_main\Absolute Mobility\Do Estimates"
doedit "9. Women Labour Force Table.do"
