# TriPhaseFunction
An R function for determining when a plant decreases leaf elongation rate in response soil water potential

TriPhase R function

Description:

	Function to calculate parameters of the Tri-phase function

Usage:

	TriPhase(NUMBER, INDATA,BASE=24,UPPER=0.9,LOWER=0.2)

Arguments:

	DATA: dataframe which must have the following columns:

	$Hour; sequential time series (int)
	$LER; leaf elongation rate per unit time, in mm per hour (num)
	$Uid; Unique identifier for each plant (int)
	$Genotype; Unique identifier for each genotype (int)
	$Temp; Temperature per unit time, in degrees Celcius (num)
	$Soil_moisture; soil moisture in hPa (num)

	NUMBER: the Uid, which unique plant to operate on

	BASE: the number of hours to calculate a from, default=24

	LOWER: lower filter setting, default=0.2

	UPPER: higher filter setting, default=0.9

Value:

	returns a data frame containing:

	'Gid'=	Genotype identifier
	'Uid' = Unique identifier
	'a' =	thermal growth rate (mm per hour per degree)
	'S' =	upper sigma, the soil moisture at which the plant limits growth (hPa)
	's' =	lower sigma, the soil moisture at which the plant limits stops growing (hPa)
	'c' =	the rate at which the plant limits growth after upper sigma (mm per hPa)

Details:

	The function expects ready formatted data where temperature, leaf elongation rate and soil moisture have been summarised hourly. It also requires that the corresponding hourly intervals be included, as integers. For the input data it requires a unique identifier and a common identifier (which is reported for convenience). The unique identifier must be specified, to tell the function which unique sample to operate on. Though a whole data set can be operated on with the simple 'for' loop

	> RESULTS <- NULL
	> for (x in 1:length(unique(data$Uid))) {RESULTS <- rbind(RESULTS,TriPhase(x,data))}

Author:

	Steven Yates, ETH Zurich, 2015
	contact: steven.yates@usys.ethz.ch

Reference:

	xxxxx

Examples:

	## call this message
	TriPhase()

	## use default
	TriPhase(1,data)

	## specifiy usage
	TriPhase(NUMBER=1,INDATA=data)

	## Loop through a dataframe
	RESULTS <- NULL
	for (x in 1:length(unique(data$Uid))) {RESULTS <- rbind(RESULTS,TriPhase(x,data))}



