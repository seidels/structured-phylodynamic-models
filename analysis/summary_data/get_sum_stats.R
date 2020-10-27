rm(list = ls())
statFunctions = "~/Projects/Comparison_BD_SC/Master_project/analysis/summary_data/inference_performance.R"
source(statFunctions)

#compute summary statistics for:
simModel = "BDrhoSamp"
infModel = "SC"


if (simModel == "SC"){
  ## endemic scenario
  cases = 51:53

  if (infModel == "SC"){
    ### sc inference
    sumDatPath = "/Volumes/Stadler/cEvoProjects/2018-Sophie-CompBDSC/simstudy_3/data/summary_data/sc_inf/SC/"
    param_names_hpd = c("N0", "N1", "mr01", "mr10")
    param_names_recov = c("mr01", "mr10")
    
    
  }else if (infModel == "BD"){ 
    
    ### bd inference
    sumDatPath = "/Volumes/Stadler/cEvoProjects/2018-Sophie-CompBDSC/simstudy_3/data/summary_data/bdpsi/SC/NodeRetype_allRateSwappers_samplingChangeTime/"
    param_names_hpd = c("br0", "br1", "mr01", "mr10", "sp0", "sp1", "root0")
    param_names_recov = c("br0", "br1", "mr01", "mr10")
  }else{
    stop("Model combination not covered!")
    }
  } else if (simModel == "BDrhoSamp"){
  cases = 45:50
  
  if (infModel == "BD"){ 
    
    ### bd inference
    sumDatPath = "/Volumes/Stadler/cEvoProjects/2018-Sophie-CompBDSC/simstudy_3/data/summary_data/bdpsi/BD_rhoSamp/"
    param_names_hpd = c("br0", "br1", "mr01", "mr10", "sp0", "sp1", "root0")
    param_names_recov = c("br0", "br1", "mr01", "mr10")
    
  }else if (infModel == "SC"){
    sumDatPath = "/Volumes/Stadler/cEvoProjects/2018-Sophie-CompBDSC/simstudy_3/data/summary_data/sc_inf/BD_rhoSamp/"
    param_names_hpd = c("N0_notInBD", "N1_notInBD", "mr01", "mr10")
    
    param_names_recov = c("mr01", "mr10")
  }else{
    stop("Model combination not covered!")
  }
}

for ( casenr in cases ){
  set.seed(casenr)
  sumdatName = load(paste0(sumDatPath, "all_params_", casenr, ".Rdat"))
  sumdat = get(sumdatName)
  
  # compute bootstrapped coverage
  bootedCoverage =get_coverage_from_sumdat(sumdat = sumdat, simModel = simModel, infModel = infModel, booted = TRUE)

  meanCoverage = apply(bootedCoverage$t,MARGIN = 2,FUN =  mean)
  sdCoverage = apply(bootedCoverage$t,MARGIN = 2,FUN =  sd)

  estimates = data.frame(meanCoverage=meanCoverage, sdCoverage=sdCoverage,
                         row.names = param_names_recov)
  estimates = round(estimates * 100)
  write.csv(x = estimates, file = paste0(sumDatPath, "recovTable_", casenr,".csv" ))

  #compute bootstrapped hpd size
  bootedHPD =get_hpd_size_from_sumdat(sumdat = sumdat, simModel = simModel, infModel = infModel, booted = TRUE)

  meanHPD = apply(bootedHPD$t,MARGIN = 2,FUN =  mean)
  sdHPD = apply(bootedHPD$t,MARGIN = 2,FUN =  sd)

  HPDestimates = data.frame(meanHPD=meanHPD, sdHPD=sdHPD,
                         row.names = param_names_hpd)
  HPDestimates = round(HPDestimates, digits = 2)
  write.csv(x = HPDestimates, file = paste0(sumDatPath, "hpdTable_median_", casenr,".csv" ))
  
  #compute bootstrapped rmse
  bootedRMSE =get_rmse_from_sumdat(sumdat = sumdat, simModel = simModel, infModel = infModel, booted = TRUE)
  
  meanRMSE = apply(bootedRMSE$t,MARGIN = 2,FUN =  mean)
  sdRMSE = apply(bootedRMSE$t,MARGIN = 2,FUN =  sd)
  
  RMSEestimates = data.frame(meanRMSE=meanRMSE, sdRMSE=sdRMSE, 
                            row.names = param_names_recov)
  RMSEestimates = round(RMSEestimates, digits = 2)
  write.csv(x = RMSEestimates, file = paste0(sumDatPath, "rmseTable_", casenr,".csv" ))
}
  