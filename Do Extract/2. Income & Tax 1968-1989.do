
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
	table("Ink19`InCyy'")connectionstring("DRIVER={SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")
	
	rename SamForvInk`InCyy' SamForvInk
	gen Ar = `InCyy' + 1900
	
	tempfile l`InCyy'
	save `l`InCyy''
	
}

*Append years to one dataset

clear
forvalues InCyy = $Income_tax_a {

 append using `l`InCyy''
 
}

tempfile data1
save `data1', replace

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
	table("Ink19`InCyy'")connectionstring("DRIVER={SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")
	
	rename SamForvInk`InCyy' SamForvInk
	rename DispInk`InCyy' DispInk
	gen Ar = `InCyy' + 1900
	
	tempfile l`InCyy'
	save `l`InCyy''
	
}

*Append years to one dataset

clear
forvalues InCyy = $Income_tax_b {

 append using `l`InCyy''
 
}

append using `data1'

**** Edit Variables ****

bysort Ar PersonLopNr: keep if _n == 1
rename SamForvInk ForvInk

compress

cd "$user_main/Absolute Mobility/Extract"
save "Income Tax 1968-1989.dta", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Extract"
doedit "3. LISA 1990-2005.do"

