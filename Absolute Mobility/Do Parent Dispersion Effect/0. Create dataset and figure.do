/**************** Preamble: Set directories ****************/

// user specific paths
global user_main " " // Your working directory

/***********************************************************/
***************************************/


************************************************************************
****                Creating Dataset and Figure 					****
************************************************************************
	
cd "$user_main"
do "1. Log-Normal Sample.do"

cd "$user_main"
do "2. US Sample.do"

cd "$user_main"
do "3. Figure 4 Parent Dispersion Effect.do"
