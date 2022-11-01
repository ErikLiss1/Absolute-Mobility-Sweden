
/*

This DO-file generates the estimates for Figure A1. We do this for different 
levels of inequality. The Estimates are used in Figure 1.

*/

/**************** Preamble: Set directories ****************/

// user specific paths
global user ""								// your MONA user name
global user_main "" // Your working 
global connectionstring "" // Your connectionstring to SCL Server

/***********************************************************/

forvalues k = 1(0.05)400 {
foreach i in 001 005 01 02 03 {

clear

global Growth = 1.`i'^30

global MeanP = log(2)
global MeanC = log(2)

global SD = `k'

global SDp = log(sqrt(exp(1)))
global SDc = log(sqrt(exp(1)*`k'))

global Growth = 1.`i'^30

global Rho 0

global Gini1 = 2*normal(((${SDp})/2)*sqrt(2))-1
global Gini2 = 2*normal(((${SDc})/2)*sqrt(2))-1

********** Only STD change ********

set obs 1

local AbsoluteMobility = normal(((${SDp}^2-${SDc}^2)/2)/sqrt(${SDp}^2+${SDc}^2))

global AMDispFirst = `AbsoluteMobility'
global MargDispFirst = `AbsoluteMobility' - 0.5

********** Mean and STD Change ********

global mean1 = exp(${MeanP} + (${SDp}^2/2))
gen mean1 = ${mean1}

global MeanC = (ln(${mean1}) + ln(${Growth})) - ((${SDc}^2)/2)	

global mean21 = exp(${MeanP} + (${SDp}^2/2))
gen mean21 = ${mean21}

local AbsoluteMobility = normal( ///
		((${MeanC}-${MeanP})/sqrt(${SDp}^2-2*${Rho}*${SDp}*${SDc}+${SDc}^2)))
di `AbsoluteMobility'
global AMDispAndGrowth = `AbsoluteMobility'

gen GrowthRate = 0.`i'*1000
gen LogGrowth = ${MeanC} - ${MeanP}
gen SDc = ${SDc}

********** Only Mean Change ********

global SDc log(sqrt(exp(1)))
global MeanC = (ln(${mean1}) + ln(${Growth})) - ((${SDc}^2)/2)

global mean22 = exp(${MeanP} + (${SDp}^2/2))
gen mean22 = ${mean22}
	
local AbsoluteMobility = normal( ///
		((${MeanC}-${MeanP})/sqrt(${SDp}^2-2*${Rho}*${SDp}*${SDc}+${SDc}^2)))
global AMGrowthFirst = `AbsoluteMobility'
global MargGrowthFirst =  `AbsoluteMobility' - 0.5
global MargDispifGrowthFirst = ${AMDispAndGrowth} - ${AMGrowthFirst}
global MargGrowthifDispFirst = ${AMDispAndGrowth} - ${AMDispFirst}

gen Gini1 = ${Gini1}
gen Gini2 = ${Gini2}
gen SDp = ${SDp}
gen MargGrowthFirst`i' = ${MargGrowthFirst}
gen AMDispFirst = ${AMDispFirst}
gen MargDispFirst = ${MargDispFirst}
gen AMDispAndGrowth`i' = ${AMDispAndGrowth}
gen AMGrowthFirst`i' = ${AMGrowthFirst}
gen MargDispifGrowthFirst`i' = ${MargDispifGrowthFirst}
gen MargGrowthifDispFirst`i' = ${MargGrowthifDispFirst}
gen Benchmark = 0.5

tempfile l`i'
save `l`i''
	
}

use "`l001'", clear

foreach i in 005 01 02 03 {
	
append using `l`i''

}

global SD = round(${SD}*100,1)

tempfile l${SD}
save `l${SD}', replace

}

use "`l100'", clear

forvalues k = 1.1(0.1)400 {
	
global SD `k'
global SD = round(${SD}*100,1)
	
append using "`l${SD}'"

}

cd "$user_main\Absolute Mobility\Estimates"
save "Alternative Decomposition Sequence", replace
