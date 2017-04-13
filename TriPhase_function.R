TriPhase <- function(NUMBER,INDATA,BASE=24,UPPER=0.9,LOWER=0.2)
{
text <- "TriPhase R function\n\nDescription:\n\n\tFunction to calculate parameters of the Tri-phase model as described by xxxxx.\n\nUsage:\n\n\tTriPhase(NUMBER, INDATA,BASE=24,UPPER=0.9,LOWER=0.2)\n\nArguments:\n\n\tDATA: dataframe which must have the following columns:\n\n\t$Hour; sequential time series (int)\n\t$LER; leaf elongation rate per unit time, in mm per hour (num)\n\t$Uid; Unique identifier for each plant (int)\n\t$Genotype; Unique identifier for each genotype (int)\n\t$Temp; Temperature per unit time, in degrees Celcius (num)\n\t$Soil_moisture; soil moisture in hPa (num)\n\n\tNUMBER: the Uid, which unique plant to operate on\n\n\tBASE: the number of hours to calculate a from, default=24\n\n\tLOWER: lower filter setting, default=0.2\n\n\tUPPER: higher filter setting, default=0.9\n\nValue:\n\n\treturns a data frame containing:\n\n\t\'Gid\'=\tGenotype identifier\n\t\'Uid\' = Unique identifier\n\t\'a\' =\tthermal growth rate (mm per hour per degree)\n\t\'S\' =\tupper sigma, the soil moisture at which the plant limits growth (hPa)\n\t\'s\' =\tlower sigma, the soil moisture at which the plant limits stops growing (hPa)\n\t\'c\' =\tthe rate at which the plant limits growth after upper sigma (mm per hPa)\n\nDetails:\n\n\tThe function expects ready formatted data where temperature, leaf elongation rate and soil moisture have been summarised hourly. It also requires that the corresponding hourly intervals be included, as integers. For the input data it requires a unique identifier and a common identifier (which is reported for convenience). The unique identifier must be specified, to tell the function which unique sample to operate on. Though a whole data set can be operated on with the simple 'for' loop\n\n\t> RESULTS <- NULL\n\t> for (x in 1:length(unique(data$Uid))) {RESULTS <- rbind(RESULTS,TriPhase(x,data))}\n\nAuthor:\n\n\tSteven Yates, ETH Zurich, 2015\n\tcontact: steven.yates@usys.ethz.ch\n\nReference:\n\n\txxxxx\n\nExamples:\n\n\t## call this message\n\tTriPhase()\n\n\t## use default\n\tTriPhase(1,data)\n\n\t## specifiy usage\n\tTriPhase(NUMBER=1,INDATA=data)\n\n\t## Loop through a dataframe\n\tRESULTS <- NULL\n\tfor (x in 1:length(unique(data$Uid))) {RESULTS <- rbind(RESULTS,TriPhase(x,data))}\n\n"

if (missing(NUMBER)) stop(writeLines(text))
if (missing(INDATA)) stop(writeLines(text))

# get a list of unique ids
PO <- unique(INDATA$Uid)
# get one of the unique plants
INdata <- INDATA[INDATA$Uid == PO[NUMBER],]
# extract the first 24 hours
Tdata <- INdata[INdata$Hour <= BASE ,]
# fit a linear model against LER and temp fitted through 0 to get a
INdata$rate <- lm(LER ~ 0+Temp , data=Tdata)$coeff[1]
# Store this data for later
GOIA <-        lm(LER ~ 0+Temp , data=Tdata)$coeff[1]
# now calculate the expected rate of growth Temp x a
INdata$MTe <- INdata$rate * INdata$Temp
# divided expected growth rate by observed -> LER/aT
INdata$TT <- INdata$LER /INdata$MTe

# find the largest soil moisture in log10(hPa)
LIMUP <- max(INdata$Soil_moisture[!is.na(INdata$Soil_moisture)])
# get this in four divisions + 1
INTERS <- round(LIMUP*4)+1
# create a blank data frame
MEANDTT <- matrix(ncol=3,nrow=INTERS)

##########################################################
# get the mean LER per quarterly hPa
GOI <- INdata
for (int in 1:INTERS)
{
MS1 <- GOI[GOI$Soil_moisture > int*0.25 & GOI$Soil_moisture <= ((int+1)*0.25) ,c('Genotype','TT')]
MEANDTT[int,1] <- int*0.25
MEANDTT[int,2] <- (int+1)*0.25
MEANDTT[int,3] <- mean(MS1[!is.na(MS1$TT),'TT'])
}

# 3 make sure there is data in the results
if(length(na.omit(MEANDTT[,3])) == 0) next

# now get the point at which LER/aT drops below 0.9 when it starts to drop
GOIDROP <- max(MEANDTT[MEANDTT[,3] > UPPER & !is.na(MEANDTT[,3]),1]) 

# now get the point at which LER/aT drops below 0.1 when it stops
GOISTOP <- min(MEANDTT[MEANDTT[,3] < LOWER & !is.na(MEANDTT[,3]),1])

#now calculate when they slow and stop growing

# filter the data when the soil moisture is > GOIDROP & < GOISTOP

MSI <- GOI[GOI$Soil_moisture > GOIDROP & GOI$Soil_moisture < GOISTOP,]

# now fit a linear model to estimate c
TTmodelL <- lm(TT~Soil_moisture,data=MSI)

# get the point at which growth slows
GOIstart <- (TTmodelL$coeff[1]-1)/-TTmodelL$coeff[2]

# get the point at which growth stops
GOIstop <- (TTmodelL$coeff[1])/-TTmodelL$coeff[2]

# get the genotype the genotype
GID <- unique(INdata$Genotype)

# get Uid
UID <- unique(INdata$Uid)
# put all relevant data into a vector
out <- c(GID,UID,GOIA,GOIstart,GOIstop,TTmodelL$coeff[2])
#colnames(out) <- c('Genotype','Track','a','S','s','c')
out <- data.frame(Gid=GID,Uid=UID,a=GOIA,S=GOIstart,s=GOIstop,c=TTmodelL$coeff[2])
return(out)
}

