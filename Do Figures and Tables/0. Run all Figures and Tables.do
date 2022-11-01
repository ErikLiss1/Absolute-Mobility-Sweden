/**************** Preamble: Set directories ****************/

// user specific paths
global user "Erik"								// your MONA user name
global user_main "//micro.intra/projekt/P0515$/P0515_Gem/Erik" // Your working 

************************************************************************
****     			 	 Creating Dataset 							****
************************************************************************	
cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure 1 and 2.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure 3 Absolute mobility.do"

* For Figure 4, see separate folder "Do Parent Dispersion Effect".

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure 5 Decomposition.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure 6 Female labor force.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure A1. Different Component Sequence.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure A2 Single Years Decomposition Men.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure A3 Single Years Decomposition Women.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure A4 and A5 Sensitivity Checks.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure A6 Payroll Taxes.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure A7 Different Reference Point Distribution.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure A8 Household Decomposition.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Figure A9 Comparisons.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Table 1 Descriptive.do"

cd "$user_main\Absolute Mobility\Do Tables and Graphs"
do "Table A1-A4 Descriptive Labor force.do"

