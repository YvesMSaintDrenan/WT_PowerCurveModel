# library needed to use function polymul
# there also is a function conv,  which should do the same but for some reason doesn't
# library(pracma)



Eval_WTPwC <- function(WT_param) {
  # Define the 11 parameters for the Cp model based on values found in the literature
  # This assigns the values from Table A.2 of the paper for use in equation A.1
  #
  # Args:
  #   WT_param: [list] list of the following variables: 
  #                    Drotor: rotor diameter in metres 
  #                    Pnom: nominal power in kW 
  #             and optionally: 
  #                    Vws: ???
  #                    Vwin: ???
  #                    Vcutin: ???
  #                    Vcutoff: ???
  #                    rMin: ???
  #                    rMax: ???
  #                    TI: ???
  #                    iModel: ???
  #                    CpMAX: ???
  #                    rhoair: ???
  #
  # Returns:
  #   [??] ???
  #
  # Example:
  #   WT_param <- list()
  #   WT_param$rMin   <- 4
  #   WT_param$rMax   <- 13
  #   WT_param$Drotor <- 120
  #   WT_param$Pnom   <- 4000
  #   WTPwC <- Eval_WTPwC(WT_param)

  
  # Exit if required model parameters are not provided
  if (length(WT_param$Drotor)==0) {
    stop("Eval_WTPwC: Drotor [rotor diameter in metres] not supplied in your parameters, with no default available.\n")
  }
  if (length(WT_param$Pnom)==0) {
    stop("Eval_WTPwC: Pnom [generator power in kW] not supplied in your parameters, with no default available.\n")
  }


  # Assign default model parameters where needed
  if (length(WT_param$Vws)==0) {
    WT_param$Vws <- seq(0,30,0.01)
  }
  if (length(WT_param$Vcutin)==0) {
    WT_param$Vcutin <- 0
  }
  if (length(WT_param$Vcutoff)==0) {
    WT_param$Vcutoff <- 25
  }
  if (length(WT_param$rMin)==0) {
    WT_param$rMin <- 188.8 * WT_param$Drotor^(-0.7081)   # angular speed in rpm
    # source: http://publications.lib.chalmers.se/records/fulltext/179591/179591.pdf
  }
  if (length(WT_param$rMax)==0) {
    WT_param$rMax <- 793.7 * WT_param$Drotor^(-0.8504)
    # source: http://publications.lib.chalmers.se/records/fulltext/179591/179591.pdf
  }
  if (length(WT_param$TI)==0) {
    WT_param$TI <- 0.1
  }
  if (length(WT_param$iModel)==0) {
      WT_param$iModel <- 6
  }
  if (length(WT_param$CpMAX)==0) {
    WT_param$CpMAX <- NaN
  }
  if (length(WT_param$rhoair)==0) {
    WT_param$rhoair <- 1.225
  }


  #### Calculate the TSR (lambda) value to maximize Cp ####
  lambda <- seq(0, 12, 0.001)
  Cpfct <- function(lambda) {CpLambdaModels(WT_param$iModel, lambda)}
  lambdaOpt <- lambda[which(Cpfct(lambda)$Cp==max(Cpfct(lambda)$Cp))]

  #### Calculate the rotor rotational speed [rpm] corresponding to the maximum output ####
  RotorSpeed <- (lambdaOpt*WT_param$Vws)/(WT_param$Drotor/2)/(2*pi/60)
  RotorSpeed <- mapply(max, WT_param$rMin, mapply(min, WT_param$rMax, RotorSpeed))

  #### Calculate the tip speed ratio and Cp value from the rotor speed ####
  lambda <- (2*pi/60)*RotorSpeed*(WT_param$Drotor/2)/WT_param$Vws
  Cp <- Cpfct(lambda)$Cp
  
  if (is.na(WT_param$CpMAX)) {
    Cp <- Cp/max(Cp)*WT_param$CpMAX
  }


  #### Calculate the power output @ TI=0 ####
  Pin <- 0.5*WT_param$rhoair*(pi*(WT_param$Drotor/2)^2)*WT_param$Vws^3/1000
  Pout_ti0 <- mapply(min, WT_param$Pnom, Pin*Cp)



####IAIN: NINJA CODE START

  Pout <- Pout_ti0

  #### Consider the effect of the TI on the power ####
  if (WT_param$TI>0) {

    resWS <- min(diff(WT_param$Vws))
    iiWS <- which(WT_param$Vws > 0  &  WT_param$Vws < WT_param$Vcutoff)

    # run through all wind speeds between zero and our cutout speed
    for (i in iiWS) {

      xMid <- WT_param$Vws[i]             # this wind speed
      Kstd <- WT_param$TI * xMid          # the standard deivation based on the chosen TI
      xK <- round(3*Kstd/resWS) * resWS   # 3 standard deviations, rounded to our nearest wind speeds

      xK <- seq(-xK, xK, resWS)           # our window of wind speeds
      wK <- exp(-0.5 * (xK/Kstd)^2)       # our gaussian kernel

      # select the power outputs within our window
      yK <- Pout_ti0[ match(round((xK+xMid)/resWS), round(WT_param$Vws/resWS)) ]

      # calculate the smoothed power output at this wind speed
      Pout[i] <- weighted.mean(yK, wK, na.rm=TRUE)

    }
  }

####IAIN: NINJA CODE END



  #### Consider the effect of the cut-in & cut-off wind speed ####
  Pout[which(WT_param$Vws < WT_param$Vcutin)] <- 0
  Pout[which(WT_param$Vws > WT_param$Vcutoff)] <- 0

  #### output structure ####
  WTPwC <- WT_param
  CpModels <- c('Slootweg et al. 2003', 'Heier 2009', 'Thongam et al. 2009', 
                'De Kooning et al. 2010', 'Ochieng et Manyonge 2014', 
                'Dai et al. 2016')
  WTPwC$CpModel <- CpModels[WT_param$iModel]
  WTPwC$Pin <- Pin
  WTPwC$lambdaOpt <- lambdaOpt
  WTPwC$RotorSpeed <- RotorSpeed
  WTPwC$lambda <- lambda
  WTPwC$Cp <- Cp
  WTPwC$Pout_ti0 <- Pout_ti0
  WTPwC$Pout <- Pout
  
  
  return(WTPwC)
}





####IAIN: I have swapped size() for length() in the function arguments
####      so that we remove need for the pracma library
CpLambdaModels <-  function(iiMdl, TSR, Beta=array(0, dim=length(TSR))) {
  # Define the 11 parameters for the Cp model based on values found in the literature
  # This assigns the values from Table A.2 of the paper for use in equation A.1
  #
  # Args:
  #   iiMdl: [number] model number
  #   TSR: [number] tip speed ratio
  #   Beta: [array of numbers] ???
  #
  # Returns:
  #   [list] ???

  c1 <- c(0.73, 0.5, 0.5176, 0.77, 0.5, 0.22)
  c2 <- c(151, 116, 116, 151, 116, 120)
  c3 <- c(0.58, 0.4, 0.4, 0, 0, 0.4)
  c4 <- c(0, 0, 0, 0, 0.4, 0)
  c5 <- c(0.002, 0, 0, 0, 0, 0)
  x <- c(2.14, 0, 0, 0, 0, 0)
  c6 <- c(13.2, 5, 5, 13.65, 5, 5)
  c7 <- c(18.4, 21, 21, 18.4, 21, 12.5)
  c8 <- c(0, 0, 0.006795, 0, 0, 0)
  c9 <- c(-0.02, 0.089, 0.089, 0, 0.08, 0.08)
  c10 <- c(0.003, 0.035, 0.035, 0, 0.035, 0.035)
  
  CellSources <- c('Slootweg et al. 2003', 'Heier 2009', 'Thongam et al. 2009', 
                   'De Kooning et al. 2010', 'Ochieng et Manyonge 2014', 
                   'Dai et al. 2016')

  Li <- 1/(1/(TSR+c9[iiMdl]*Beta)-c10[iiMdl]/(Beta^3+1))
  Cp <- mapply(max, c1[iiMdl]*(c2[iiMdl]/Li-c3[iiMdl]*Beta-c4[iiMdl]*Li*Beta-c5[iiMdl]*Beta^x[iiMdl]-c6[iiMdl])*exp(-c7[iiMdl]/Li)+c8[iiMdl]*TSR, 0)
  ModelName <- CellSources[iiMdl]
  Cp[1] <- 0 # set first element 0, because it is NaN (caused by Inf*0) and this causes problems
  ret = list(Cp,ModelName)
  names(ret) <- c("Cp","ModelName")
  return(ret)
}



# # there is no conv function with the parameter 'same', so implement it here:
# conv_same <- function(u, v) {
#   # Description
#   #
#   # Args:
#   #   u: [??] ???
#   #   v: [??] ???
#   #
#   # Returns:
#   #   [??] ???

#   # because polymul cuts off 0s at the beginning, add them artifically
#   if (u[1]==0) {
#     u0 <- rle(u)$lengths[1]
#   } else {
#     u0 <- 0
#   }
#   if (v[1]==0) {
#     v0 <- rle(v)$lengths[1]
#   } else {
#     v0 <- 0
#   }
#   uv <- c(rep(0, u0+v0), polymul(u, v))

#   start <- length(v) / 2 + 1
#   end <- length(v) / 2 + length(u)
#   return(uv[start:end])
# }



