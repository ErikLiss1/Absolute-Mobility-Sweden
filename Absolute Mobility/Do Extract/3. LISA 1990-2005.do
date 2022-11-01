
/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working Directory
global connectionstring "" // Your connectionstring to SCL Server

/***********************************************************/

cd "$user_main/Absolute Mobility"

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
		DispInkPersF ///
		Kommun ///
		, ///
	table("LISA`lisayyyy'_Individ")connectionstring("$connectionstring")
	
	rename DispInkPersF DispInk
	
	tempfile l`lisayyyy'
	save `l`lisayyyy''
	
}

*Append years to one dataset
clear
forvalues lisayyyy = $LISA1 {

 append using `l`lisayyyy''
 
}

**** Edit Variables ****

destring Ar, replace
bysort Ar PersonLopNr: keep if _n == 1

compress

save "LISA 1990-2005.dta", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Extract"
doedit "4. LISA 2006-2017.do"

