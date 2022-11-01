/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working 
global connectionstring "" // Your connectionstring to SCL Server

************************************************************************
****     			 Generating estimates 							****
************************************************************************
	
cd "$user_main\Absolute Mobility\Do Extract"
do "1. Estimate Benchmark Absolute mobility.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "2. Estimates Absolute Mobility Disposable Income.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "3. Estimates Desc Statistics.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "4. Estimates Decomposition"

cd "$user_main\Absolute Mobility\Do Extract"
do "6. Payroll tax Absolute Mobility"

cd "$user_main\Absolute Mobility\Do Extract"
do "7. Household Estimates.do"

cd "$user_main\Absolute Mobility\Do Extract"
do "8. Labor Force Treshold"

cd "$user_main\Absolute Mobility\Do Extract"
do "9. Women Labour Force Table"

cd "$user_main\Absolute Mobility\Do Extract"
do "10. Women Labour Force Counterfactual"

cd "$user_main\Absolute Mobility\Do Extract"
do "11. Decomposition Empirical Reference Point"

cd "$user_main\Absolute Mobility\Do Extract"
do "12. Decomposition Single Year"

cd "$user_main\Absolute Mobility\Do Extract"
do "13. Household Decomposition"

cd "$user_main\Absolute Mobility\Do Extract"
do "14. Estimates for Figure A9"

cd "$user_main\Absolute Mobility\Output Main Tables And Figure"
do "15. Estimates Different Decomposition Sequence"
