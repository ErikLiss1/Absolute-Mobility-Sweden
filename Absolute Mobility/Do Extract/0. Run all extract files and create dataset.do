/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working Directory

************************************************************************
****     			 	 Creating Dataset 							****
************************************************************************	
cd "$user_main\Absolute Mobility\Do Extract"
do "1. Background &  Multigenerational data.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "2. Income & Tax 1968-1989.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "3. LISA 1990-2005.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "4. LISA 2006-2017.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "5. Merging Income & Child.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "6. Merging Income & Fathers.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "7. Merging Income & Mothers.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "8. Merging Children, Fathers and Mothers.do"

