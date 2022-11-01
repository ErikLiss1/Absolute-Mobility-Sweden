
/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working Directory
global connectionstring "" // Your connectionstring to SCL Server

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
	table("LISA`lisayyyy'_Individ")connectionstring("$connectionstring")
	
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
