library(boot)

get_sim_params_from_sumdat <- function(sumdat, simModel){

  if (simModel == "BDrhoSamp"){
    simParams = sumdat[[1]]
    simParams[] = lapply(simParams, as.numeric)
    return(simParams)

  }else if (simModel == "SC"){


    N0 = 1/as.numeric(sumdat[[1]][1,1]) # convert coalescent rate from true parameters into population size -> 1/x
    N1 = 1/as.numeric(sumdat[[1]][1,2])
    q01 = as.numeric(sumdat[[1]]["q01"])
    q10 = as.numeric(sumdat[[1]]["q10"])
    mr01 = q10 * N1/N0                    # convert migration rates to respective forward migration rates
    mr10 = q01 * N0/N1

    simParams = data.frame(N0=N0, N1=N1, q01=q01, q10 = q10, mr01=mr01, mr10 = mr10)
    simParams[] = lapply(simParams, as.numeric)

    return(simParams)
  }
}

compute_coverage <- function(data, indices=-1, simParams, simModel, infModel){

  if (any(indices != -1)){
    data = data[indices, ]
  }

  if (simModel == "BDrhoSamp" & infModel == "BD"){
    recovFreqTable = data.frame(br0=-1, br1=-1, mr01=-1, mr10=-1)

  }else if(simModel == "SC" & infModel == "SC"){
    recovFreqTable = data.frame(N0 = -1, N1 =-1, mr01=-1, mr10=-1)
    recovFreqTable[, "N0"] = sum( as.numeric(simParams["1","N0"]) <= data[, "N0_upper"] &
                                      as.numeric(simParams["1","N0"]) >= data[, "N0_lower"])/nrow(data)
    recovFreqTable[, "N1"] = sum( as.numeric(simParams["1","N1"]) <= data[, "N1_upper"] &
                                    as.numeric(simParams["1","N1"]) >= data[, "N1_lower"])/nrow(data)

    recovFreqTable[, "mr01"] = sum( as.numeric(simParams["1","mr01"]) <= data[, "mr01_upper"] &
                                      as.numeric(simParams["1","mr01"]) >= data[, "mr01_lower"])/nrow(data)

    recovFreqTable[, "mr10"] = sum( as.numeric(simParams["1","mr10"]) <= data[, "mr10_upper"] &
                                      as.numeric(simParams["1","mr10"]) >= data[, "mr10_lower"])/nrow(data)

    return(as.numeric(recovFreqTable))

  }else if(simModel == "SC" & infModel == "BD"){
        recovFreqTable = data.frame(br0=-1, br1=-1, mr01=-1, mr10=-1)
        # set simParams parameters to BD equivalents
        if (simParams[1,1] != simParams[1,2]){
          stop("Adapt coverage calculation for differing population sizes")
        }
        ##  as SC simulations are under constant population size -> br0 = br1 =1.0
        simParams[1, 1:2] <- 1.0

  }else if(simModel == "BDrhoSamp" & infModel == "SC"){
    recovFreqTable = data.frame( mr01=-1, mr10=-1)

    recovFreqTable[, "mr01"] = sum( as.numeric(simParams["1","mr01"]) <= data[, "mr01_upper"] &
                             as.numeric(simParams["1","mr01"]) >= data[, "mr01_lower"])/nrow(data)

    recovFreqTable[, "mr10"] = sum( as.numeric(simParams["1","mr10"]) <= data[, "mr10_upper"] &
                               as.numeric(simParams["1","mr10"]) >= data[, "mr10_lower"])/nrow(data)

    return(as.numeric(recovFreqTable))

  }else{
    stop("Model combination not specified yet!")
  }

  for (i in 0:3){
    # for birth rate round to .1 for migration rate to 0.01
    recovFreqTable[i + 1] = sum(as.numeric(simParams[(i +1)]) <=data[, (i * 3+ 3)] &
                                  as.numeric(simParams[(i +1)]) >=data[,(i *3 + 2)])/ nrow(data)
  }

  return(as.numeric(recovFreqTable))

}

get_inf_results_from_sumdat <- function(sumdat){

  infResults = sumdat[[2]][which(sumdat[[2]][,1] != 0), ]

    return(infResults)
}

get_coverage_from_sumdat <- function(sumdat, simModel="BDrhoSamp", infModel="BD", booted=FALSE, R=10000){
  # this takes a sumdat as input
  # consists of : simulation parameters & inferred parameters


  # get simulation parameters (taken here as 'truth')
  simParams = get_sim_params_from_sumdat(sumdat = sumdat, simModel = simModel)

  #get inference results
  infResults = get_inf_results_from_sumdat(sumdat = sumdat)

  # get coverage
  if (booted){
    coverage = boot(data = infResults, statistic = compute_coverage, R=R,
                    simParams = simParams,
                    simModel = simModel, infModel = infModel)
  }else{
  coverage = compute_coverage(simParams = simParams, data = infResults,
                              simModel = simModel, infModel = infModel, indices = -1)
  }

  return(coverage)
}

compute_hpd_size <- function(simParams, dat, simModel, infModel, indices=-1){

  if (any(indices != -1)){
    dat = dat[indices, ]
  }

  if (simModel == "BDrhoSamp" & infModel == "BD"){
    hpdSizeTable <- data.frame(br0=0, br1=0, mr01=0, mr10=0, sp0=0, sp1=0, root0=0)

  }else if ( infModel == "SC"){
    hpdSizeTable <- data.frame(N0=0, N1=0, mr01=0, mr10=0)


      hpdSizeTable[,"N0"] =  median( dat[,"N0_upper"] - dat[ ,"N0_lower"])
      hpdSizeTable[,"N1"] =  median( dat[,"N1_upper"] - dat[ ,"N1_lower"])
      hpdSizeTable[,"mr10"] =  (median( dat[,"mr10_upper"] - dat[ ,"mr10_lower"])) /as.numeric(simParams[, "mr01"])
      hpdSizeTable[,"mr01"] =  median( dat[,"mr01_upper"] - dat[ ,"mr01_lower"]) / simParams[, "mr10"]

      return(as.numeric(hpdSizeTable))


  }else if (simModel == "SC" & infModel == "BD"){
    if(simParams[1,1] != simParams[1,2]){
      stop("Not implemented for differing population sizes in simulation")
    }
    simParams[1,1:2] = 1.0
    hpdSizeTable <- data.frame(br0=0, br1=0, mr01=0, mr10=0) #, sp0=0, sp1=0, root0=0)


  }else{
    stop("Model combination not implemented")
  }

  # calculate hpd width for each parameter
  for (param_number in 0:(ncol(hpdSizeTable)-1)){
    hpdSizeTable[param_number+1] =  median( dat[,param_number * 3 +3] - dat[ ,param_number*3+2])
  }
  # normalize hpd width for the parameters, for which we know the truth
  for (param_number in (0:3)){
    hpdSizeTable[param_number+1] =  as.numeric(hpdSizeTable[param_number+1] / as.numeric(simParams[, param_number+1]))
  }
  return(as.numeric(hpdSizeTable))
}

get_hpd_size_from_sumdat <- function(sumdat, indices = -1, simModel = "BDrhoSamp", infModel = "BD", booted=FALSE, R=10000){

  # get simulation parameters (taken here as 'truth')
  simParams = get_sim_params_from_sumdat(sumdat = sumdat, simModel = simModel)

  #get inference results
  infResults = get_inf_results_from_sumdat(sumdat = sumdat)

  if (booted){
    hpdSize = boot(dat = infResults, statistic = compute_hpd_size, R=R,
                    simParams = simParams,
                    simModel = simModel, infModel = infModel)
  }else{

    hpdSize = compute_hpd_size(simParams = simParams, dat = infResults,
                               simModel = simModel, infModel = infModel)
    }


  return(hpdSize)
}

compute_rmse <- function(simParams, dat, simModel, infModel, indices=-1){

  if (any(indices != -1)){
    dat = dat[indices, ]
  }

  if (simModel == "BDrhoSamp" & infModel == "BD"){
    rmseTable <- data.frame(br0=0, br1=0, mr01=0, mr10=0)

  }else if( infModel == "SC"){
    rmseTable <- data.frame( mr01=0, mr10=0)
    rmseTable[1, "mr01"] = RMSE(m = dat[, "mr01"], o = simParams[1, "mr01"]) / simParams[1, "mr01"]
    rmseTable[1, "mr10"] = RMSE(m = dat[, "mr10"], o = simParams[1, "mr10"]) / simParams[1, "mr10"]

    return(as.numeric(rmseTable))

  }else if(simModel == "SC" & infModel == "BD"){
    rmseTable <- data.frame(br0=0, br1=0, mr01=0, mr10=0)
    if (simParams[1,1] != simParams[1,2]){
      stop("Not implemented for distinct population sizes")
    }
    # the true birth rate would be 1.0 for non-growing population
    simParams[1,1:2] <- 1.0
  }
  for (param_number in 0:(ncol(rmseTable)-1)){
    rmseTable[param_number+1] = RMSE(dat[,param_number * 3 +1],  as.numeric(simParams[,param_number + 1])) / mean(as.numeric(simParams[,param_number + 1]))
  }

  return(as.numeric(rmseTable))
}

get_rmse_from_sumdat <- function(sumdat, indices = -1, simModel = "BDrhoSamp", infModel = "BD", booted=FALSE, R=10000){

  # get simulation parameters (taken here as 'truth')
  simParams = get_sim_params_from_sumdat(sumdat = sumdat, simModel = simModel)

  #get inference results
  infResults = get_inf_results_from_sumdat(sumdat = sumdat)

  if(booted){
    rmse = boot(dat = infResults, statistic = compute_rmse, R=R,
                   simParams = simParams,
                   simModel = simModel, infModel = infModel)
  }else{
    rmse = compute_rmse(simParams = simParams, dat = infResults,
                        simModel = simModel, infModel = infModel)
  }

  return(rmse)
}


RMSE = function(m, o){
  sqrt(mean((m - o)^2, na.rm = TRUE))
}

