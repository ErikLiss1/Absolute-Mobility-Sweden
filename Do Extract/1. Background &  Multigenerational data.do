
/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

/***********************************************************/

/* Extracting data from SQL for the following variables: 

personal id number, 
sex,
birth year

*/

clear
odbc load ///
		PersonLopNr ///
		Kon ///
		FodelseAr ///
		, ///
	table("Bakgrundsdata")connectionstring("DRIVER={SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")

* Removing duplicates:
	
bysort PersonLopNr: keep if _n == 1

tempfile data1
save `data1', replace

/*

Extracting data from SQL for the following variables: 
Personal id number, 
Mother's personal id number,  
Birth year of mother,
Father's personal id number
Birth year of father

*/

clear
odbc load ///
		PersonLopNr ///
		LopNrMor ///
		FodelseArMor ///
		LopNrFar ///
		FodelseArFar ///
		, ///
	table("Flergen")connectionstring("DRIVER={SQL Server};SERVER={mq02\b};DATABASE={P0515_IFFS_Segregeringens_dynamik};Trusted_Connection={Yes}")

* Removing duplicates:
	
bysort PersonLopNr: keep if _n == 1

* Merging together both datasets:

merge 1:1 PersonLopNr using `data1'

destring 	PersonLopNr LopNrMor FodelseArMor ///
			LopNrFar FodelseArFar Kon FodelseAr, replace

* Saving data:

cd "$user_main\Absolute Mobility\Extract"
save "Merged_Bakgrund_Flergen.dta", replace

* Open next do-file:

cd "$user_main\Absolute Mobility\Do Extract"
doedit "2. Income & Tax 1968-1989.do"

