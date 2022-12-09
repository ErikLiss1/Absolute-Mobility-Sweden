
/**************** Preamble: Set directories ****************/

// user specific paths
global user_main "" // Your working directory

/***********************************************************/

clear all

forvalues k = 0.99(0.01)12 {
foreach i in 001 005 01 02 03 {

clear

* Growth is compouned over 30 years

global Growth = 1.`i'^30
di ${Growth}

/* 
We plug in the parameters in the closed form formula. Since we take the 
log of incomes and standard deviation, we should preferably choose values 
greater than one
*/

global MeanC log(${Growth}*2)
global MeanP log(2)
global SD `k'
global LogSqrtSD log(${SD})

* We set SDp=SDc=log(${SD})
global SDp ${LogSqrtSD}
global SDc ${LogSqrtSD}

* We set the intergenerational correlation Rho to 0
global Rho 0

set obs 1

* Calculating Gini coefficient
gen Gini = 2*normal(log(${SD})/2*sqrt(2))-1

* Create variable for  Growth Rate for plots
gen GrowthRate = 0.`i'*1000
gen LogGrowth = ${MeanC} - ${MeanP}

* Create variable for standard deviation for plots
gen SD = `k'
gen LogSD = log(`k')

* Create identification variables
gen Entity = "LogNormal"
gen Sample = 4

* Calculating Absolute Mobility
gen AbsoluteMobility = normal( ///
	((${MeanC}-${MeanP})/sqrt(${SDc}^2-2*${Rho}*${SDp}*${SDc}+${SDc}^2)))

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

*use "`l100'", clear
use "`l99'", clear

forvalues k = 1.0(0.01)12 {
	
global SD `k'
global SD = round(${SD}*100,1)
	
append using "`l${SD}'"

}

*drop if SD <= 1

save "${user_main}/Do Parent Dispersion Effect/Samples/Reference Point Sample", replace
