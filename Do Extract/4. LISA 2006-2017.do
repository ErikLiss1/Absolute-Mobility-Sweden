
/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

cd "$user_main/Absolute Mobility"

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
		DispInkPersF04 ///
		Kommun ///
		, ///
	table("LISA`lisayyyy'_Individ")connectionstring("DRIVER={SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")
	
	destring ForvInk, replace
	destring DispInkPersF04, replace
	rename DispInkPersF04 DispInk
	
	tempfile l`lisayyyy'
	save `l`lisayyyy''
	
}

*Append years to one dataset
clear
forvalues lisayyyy = $LISA2 {

 append using `l`lisayyyy'', force
 
}

**** Edit Variables ****

destring Ar, replace
bysort Ar PersonLopNr: keep if _n == 1

compress

save "LISA 2006-2017.dta", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Extract"
doedit "5. Merging Income & Child.do"
