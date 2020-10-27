library(tracerer)
library(HDInterval)

split_params_from_filename <- function(filename){
  print(filename)
  # check if tree is either bd tree of SCconBD
  if (startsWith(filename, "br") | startsWith(filename, "gr")) {
    
    if(grepl("cr0", filename)){
      # split the file name to retrieve parameter names and values
      pars_1=strsplit(x = as.character(filename), split = "_")[[1]][1:14] # split on "_"
      pars_2=as.data.frame(sapply(pars_1, function(x) strsplit(x, ":")), stringsAsFactors = FALSE)
      # add proper column and row names
      colnames(pars_2) = sapply(pars_2[1,], function(x) as.character(x))
      pars_2 <- pars_2[-c(1),]
      rownames(pars_2) <- 1
      
      return(pars_2)
      # if this is a bd simulated tree file
    }else{
      # split the file name to retrieve parameter names and values
      pars_1=strsplit(x = as.character(filename), split = "_")[[1]][0:9] # split on "_"
      pars_2=as.data.frame(sapply(pars_1, function(x) strsplit(x, ":")), stringsAsFactors = FALSE) # split on ":"
      # add proper column and row names
      colnames(pars_2) = sapply(pars_2[1,], function(x) as.character(x))
      pars_2 <- pars_2[-c(1),]
      rownames(pars_2) <- 1
      # remove additional pieces, which are not simulation parameters
      ending_index = which(names(pars_2) == "s")
      pars_2 = pars_2[1:ending_index]
      
      return(pars_2)
    }
  }
  else if (startsWith(filename, "cr")){
    # split the file name to retrieve parameter names and valuesn
    pars_1=strsplit(x = as.character(filename), split = "_")[[1]][0:5] # split on "_"
    pars_2=as.data.frame(sapply(pars_1, function(x) strsplit(x, ":")), stringsAsFactors=FALSE) # split on ":"
    # add bdmm ess entry
    colnames(pars_2) = sapply(pars_2[1,], function(x) as.character(x))
    pars_2 <- pars_2[-c(1),]
    rownames(pars_2) <- 1
    
    return(pars_2)
  }
}

get_all_params <- function(param_dir, sim_model="SC",inf_model="SC", record_only_root_type=FALSE,
                           simtreedir="", samplingProportionsFile="", casenr=0){
  # bundle simulation parameters and inference results into one data structure 
  
  # fetch file list
  files=list.files(path = param_dir, pattern = "[0-9A-Za-z_:]*.log")
  #assertthat::are_equal(length(files), 100)
  print(files)
  
  # get table with simulation parameters
  simParamsTable = get_simParams_table(files = files, sim_model = sim_model)
  
  # get table with inference results
  infParamsTable = get_infResults_table(files = files, inf_model = inf_model, param_dir = param_dir)
  
  return(list(simParamsTable, infParamsTable))
}

get_conParams_table_from_case <- function(case){
  if (case == 1){
    br0=1.05; br1=1.05;mr01=1.0;mr10=1.0
  }else if (case == 2){
    br0=1.05; br1=1.05;mr01=0.1;mr10=0.1
  }else if(case == 3){
    br0=1.05; br1=1.05;mr01=0.01;mr10=0.01
  }else if (case == 13){
    br0=1.05; br1=1.05;mr01=1.0;mr10=1.0
  }else if (case == 14){
    br0=1.05; br1=1.05;mr01=0.1;mr10=0.1
  }else if(case == 15){
    br0=1.05; br1=1.05;mr01=0.01;mr10=0.01
  }else if (case == 4){
    br0=2.0; br1=2.0;mr01=1.0;mr10=1.0
  }else if (case == 5){
    br0=2.0; br1=2.0;mr01=0.1;mr10=0.1
  }else if(case == 6){
    br0=2.0; br1=2.0;mr01=0.01;mr10=0.01
  }else if (case == 16){
    br0=2.0; br1=2.0;mr01=1.0;mr10=1.0
  }else if (case == 17){
    br0=2.0; br1=2.0;mr01=0.1;mr10=0.1
  }else if(case == 18){
    br0=2.0; br1=2.0;mr01=0.01;mr10=0.01
  }else{
    stop(paste0("Case ", case, "is not implemented yet!"))
  }
  conParamsTable = data.frame(br0=br0,br1=br1,mr01=mr01, mr10=mr10, row.names = 1)
  return(conParamsTable)
}

get_simParams_BDrho <- function(files){
  # get simulation parameters given the model used was the BD model with sampling
  # through time
  
  # define output format
  simParamsTable = data.frame(br0=-1, br1=-1, 
                              mr01=-1, mr10=-1)
  
  # fill in invariant parameters in simulation
  trueSimParams <- split_params_from_filename(files[1])
  simParamsTable[1, ] = trueSimParams[1,c(1:2,5:6)]
  
  return(simParamsTable)
}

get_simParams_SC <-function(files){
  
  # define output format
  simParamsTable = data.frame(cr0=-1, cr1=-1, q01=-1, q10=-1)
  # fill
  trueSimParams <- split_params_from_filename(files[1])
  simParamsTable[1,] <- trueSimParams[1:4]
  simParamsTable[1,1:2] <- as.numeric(trueSimParams[1:2])*2
  
  return(simParamsTable)
}

get_simParams_ScconBD <- function(files){
  # get simulation parameters given the model used for simulation was the SC model 
  # with leaves conditioned on BD sampling times
  
  #define output format
  simParamsTable = data.frame(cr0=rep(0, 100), cr1=rep(0, 100), q01=rep(0,100), q10=rep(0,100),
                              sp0=rep(0,100),sp1=rep(0,100), seed=rep(0,100))
  
  i = 1
  for (file in files){
    
    true_sim_params <- split_params_from_filename(file)
    
    # fill params in simParamsTable
    simParamsTable[i, 1] =  as.numeric(true_sim_params["cr0"])
    simParamsTable[i, 2] =  as.numeric(true_sim_params["cr1"])
    simParamsTable[i, 3] =  as.numeric(true_sim_params["mrb01"])
    simParamsTable[i, 4] =  as.numeric(true_sim_params["mrb10"])
    simParamsTable[i, 5] = as.numeric(true_sim_params["sr0"])
    simParamsTable[i, 6] = as.numeric(true_sim_params["sr1"])
    simParamsTable[i, 7] = as.numeric(true_sim_params["s"])

  }
  
  return(simParamsTable)
}

get_simParams_SCdetermSamp <- function(files){
  #get simulation parameters given the model used for simulation was a SC with 
  # leaves at deterministic sampling times
  
  # define output format
  simParamsTable = data.frame(cr0=rep(0, 100), cr1=rep(0, 100), q01=rep(0,100), q10=rep(0,100),
                              seed=rep(0,100))
  i = 1
  for (file in files){
    # fill params in simParamsTable
    simParamsTable[i, 1] =  as.numeric(true_sim_params["cr0"])
    simParamsTable[i, 2] =  as.numeric(true_sim_params["cr1"])
    simParamsTable[i, 3] =  as.numeric(true_sim_params["qr01"])
    simParamsTable[i, 4] =  as.numeric(true_sim_params["qr10"])
    simParamsTable[i, 5] =  seed
  }
  return(simParamsTable)
}

get_simParams_SCexpdetermSamp <- function(files){
  # get simulation parameters given the module used for simulation was a SC with 
  # exponential growth and deterministic sampling times
  
  # define output format
  simParamsTable = data.frame(gr0=rep(0, 100), gr1=rep(0, 100), q01=rep(0,100), q10=rep(0,100),
                              seed=rep(0,100))
  i = 1
  for (file in files){
    simParamsTable[i, 1] =  as.numeric(true_sim_params["gr0"])
    simParamsTable[i, 2] =  as.numeric(true_sim_params["gr1"])
    simParamsTable[i, 3] =  as.numeric(true_sim_params["q01"])
    simParamsTable[i, 4] =  as.numeric(true_sim_params["q10"])
    simParamsTable[i, 5] =  seed
  }
  return(simParamsTable)
}
get_simParams_SCexpconBD <- function(files){
  # get simulation parameters given the module used for simulation was a SC with 
  # exponential growth and deterministic sampling times
  
  # define output format
  simParamsTable = data.frame(gr0=rep(0,100), gr1=rep(0,100), q01=rep(0,100), q10=rep(0,100),
                              sp0=rep(0,100), sp1=rep(0,100), seed=rep(0,100))
  
  i = 1
  for (file in files){
    simParamsTable[i, 1] =  as.numeric(true_sim_params["gr0"])
    simParamsTable[i, 2] =  as.numeric(true_sim_params["gr1"])
    simParamsTable[i, 3] =  as.numeric(true_sim_params["q01"])
    simParamsTable[i, 4] =  as.numeric(true_sim_params["q10"])
    simParamsTable[i, 5] = -1 #as.numeric(samplingProportions[which(samplingProportions$V1 == seed), 2])[1]
    simParamsTable[i, 6] = -1 #as.numeric(samplingProportions[which(samplingProportions$V1 == seed), 3])[1]
    simParamsTable[i, 7] =  seed
  }
  return(simParamsTable)
}

get_simParams_table <- function(files, sim_model="SCconBD"){
  # combine all functions extracting simulation parameters
  # for a particular model
  
    if (sim_model == "BDrhoSamp") { 
      simParamsTable = get_simParams_BDrho(files)
      
    }else if(sim_model == "SC"){
      
      simParamsTable = get_simParams_SC(files)
      
    }else if( sim_model == "SCconBD"){
      simParamsTable = get_simParams_ScconBD(files)
      
    } else if (sim_model == "SCdetermSamp"){
      simParamsTable = get_simParams_SCdetermSamp(files)
    
    } else if (sim_model == "SCexpconBD"){
      simParamsTable = get_simParams_ScexpconBD(files)
      
    }  else if (sim_model == "SCexpdetermSamp"){
      simParamsTable = get_simParams_SCexpdetermSamp(files)

      }else{
        stop(paste0("No method implemented for simulation model: ", sim_model))
    }
    return(simParamsTable)
}


get_infResultsTable_sc <- function(files, param_dir){
  # get results given inference model was structured coalescenct
  
  # coalescent rate: cr; backwards in time migration rate 0-> 1: q01; change count from 0->1 :ch01;
  # number of nodes of type 0: n0; root type : root;
  infParamsTable = data.frame(N0=rep(0,100), N0_lower=rep(0,100), N0_upper=rep(0,100),
                              N1=rep(0,100), N1_lower=rep(0,100), N1_upper=rep(0,100),
                              q01=rep(0,100),q01_lower=rep(0,100), q01_upper=rep(0,100),
                              q10=rep(0,100),q10_lower=rep(0,100), q10_upper=rep(0,100),
                          
                              ch01=rep(0,100), ch01_lower=rep(0,100), ch01_upper=rep(0,100),
                              ch10=rep(0,100), ch10_lower=rep(0,100), ch10_upper=rep(0,100),
                              n0=rep(0,100), n0_lower=rep(0,100), n0_upper=rep(0,100),
                              n1=rep(0,100), n1_lower=rep(0,100), n1_upper=rep(0,100),
                              root=rep(0,100), root_lower=rep(0,100), root_upper=rep(0,100),
                              mr01=rep(0,100),mr01_lower=rep(0,100), mr01_upper=rep(0,100),
                              mr10=rep(0,100),mr10_lower=rep(0,100), mr10_upper=rep(0,100),
                              seed=rep(0,100))
  rowcounter = 1
  for (file in files){
    # get seed from file
    true_sim_params <- split_params_from_filename(file)
    seed = as.numeric(true_sim_params["s"])
    print(file)
    print(seed)
    
    #fill  params in infParamsTable
    ## read in inference log
    estimates <- parse_beast_log(paste(param_dir, file, sep = "/"))
    estimates <- remove_burn_ins(estimates, burn_in_fraction = 0.1)
    
    
    ## use median + HPD upper & lower to fill table
    infParamsTable[rowcounter, 1] = median(estimates$migModel_.popSize_0, na.rm = TRUE)
    infParamsTable[rowcounter, 2] = hdi(as.numeric(estimates$migModel_.popSize_0),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 3] = hdi(as.numeric(estimates$migModel_.popSize_0),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 4] = median(estimates$migModel_.popSize_1, na.rm = TRUE)
    infParamsTable[rowcounter, 5] = hdi(as.numeric(estimates$migModel_.popSize_1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 6] = hdi(as.numeric(estimates$migModel_.popSize_1),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 7] = median(estimates$migModel_.rateMatrix_0_1, na.rm = TRUE)
    infParamsTable[rowcounter, 8] = hdi(as.numeric(estimates$migModel_.rateMatrix_0_1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 9] = hdi(as.numeric(estimates$migModel_.rateMatrix_0_1),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 10] = median(estimates$migModel_.rateMatrix_1_0, na.rm = TRUE)
    infParamsTable[rowcounter, 11] = hdi(as.numeric(estimates$migModel_.rateMatrix_1_0),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 12] = hdi(as.numeric(estimates$migModel_.rateMatrix_1_0),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 13] = median(estimates$inputTree.count_0_to_1, na.rm = TRUE)
    infParamsTable[rowcounter, 14] = hdi(as.numeric(estimates$inputTree.count_0_to_1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 15] = hdi(as.numeric(estimates$inputTree.count_0_to_1),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 16] = median(estimates$inputTree.count_1_to_0, na.rm = TRUE)
    infParamsTable[rowcounter, 17] = hdi(as.numeric(estimates$inputTree.count_1_to_0),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 18] = hdi(as.numeric(estimates$inputTree.count_1_to_0),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 19] = median(estimates$inputTree.count_0,na.rm = TRUE)
    infParamsTable[rowcounter, 20] = hdi(as.numeric(estimates$inputTree.count_0),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 21] = hdi(as.numeric(estimates$inputTree.count_0),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 22] = median(estimates$inputTree.count_1, na.rm = TRUE)
    infParamsTable[rowcounter, 23] = hdi(as.numeric(estimates$inputTree.count_1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 24] = hdi(as.numeric(estimates$inputTree.count_1),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 25] = mean(estimates$rootTypeLogger.t.h3n2_2deme, na.rm = TRUE)
    infParamsTable[rowcounter, 26] = hdi(as.numeric(estimates$rootTypeLogger.t.h3n2_2deme),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 27] = hdi(as.numeric(estimates$rootTypeLogger.t.h3n2_2deme),credMass = 0.95)[[2]]
    
    mr01_estimates = as.numeric(estimates$migModel_.rateMatrix_1_0) * as.numeric(estimates$migModel_.popSize_1) /as.numeric(estimates$migModel_.popSize_0)
    mr10_estimates = as.numeric(estimates$migModel_.rateMatrix_0_1) * as.numeric(estimates$migModel_.popSize_0) /as.numeric(estimates$migModel_.popSize_1)
    
    infParamsTable[rowcounter, 28] = median(mr01_estimates, na.rm = TRUE)
    infParamsTable[rowcounter, 29] = hdi(as.numeric(mr01_estimates),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 30] = hdi(as.numeric(mr01_estimates),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 31] = median(mr10_estimates, na.rm = TRUE)
    infParamsTable[rowcounter, 32] = hdi(as.numeric(mr10_estimates),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 33] = hdi(as.numeric(mr10_estimates),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 34] = true_sim_params["s"]
    
    rowcounter = rowcounter + 1
    print(paste("rowcounter: ", rowcounter))
  }
  
  infParamsTable = infParamsTable[which(infParamsTable[,1] != 0), ]
  return(infParamsTable)
}

replace_type = function(coln, deme_missing){
  # replaces 
  ctr = 1
  for (c in coln){
    if (grepl("type", c)){
      
      # split off type
      parts = strsplit(x = c, split = "type_[01]", fixed = FALSE)
      # join name together with missing deme
      if (length(parts[[1]]) > 1){
        coln[ctr] = paste0(parts[[1]][1], deme_missing, parts[[1]][2])
      }else{
        coln[ctr] = paste0(parts[[1]][1], deme_missing)
      }
    }
    ctr = ctr + 1
  }
  return(coln)
}

get_infResultsTable_bd <- function(files, param_dir){
  # get inference results for the model bd
  infParamsTable = data.frame(br0=rep(0,100), br0_lower=rep(0,100), br0_upper=rep(0,100),
                              br1=rep(0,100), br1_lower=rep(0,100), br1_upper=rep(0,100),
                              mr01=rep(0,100),mr01_lower=rep(0,100), mr01_upper=rep(0,100),
                              mr10=rep(0,100),mr10_lower=rep(0,100), mr10_upper=rep(0,100),
                              sp0=rep(0,100), sp0_lower=rep(0,100), sp0_upper=rep(0,100),
                              sp1=rep(0,100), sp1_lower=rep(0,100), sp1_upper=rep(0,100),
                              count_01=rep(0,100), count_01_lower=rep(0,100),count_01_upper=rep(0,100),
                              count_10=rep(0,100), count_10_lower=rep(0,100),count_10_upper=rep(0,100),
                              origin = rep(0,100), origin_lower= rep(0,100), origin_upper=rep(0,100),
                              seed=rep(0,100))
  rowcounter = 1

  
}


get_infResultsTable_bd <- function(files, param_dir){
# get inference results for the model bd
  infParamsTable = data.frame(br0=rep(0,100), br0_lower=rep(0,100), br0_upper=rep(0,100),
                              br1=rep(0,100), br1_lower=rep(0,100), br1_upper=rep(0,100),
                              mr01=rep(0,100),mr01_lower=rep(0,100), mr01_upper=rep(0,100),
                              mr10=rep(0,100),mr10_lower=rep(0,100), mr10_upper=rep(0,100),
                              sp0=rep(0,100), sp0_lower=rep(0,100), sp0_upper=rep(0,100),
                              sp1=rep(0,100), sp1_lower=rep(0,100), sp1_upper=rep(0,100),
                              N0=rep(0,100), N0_lower=rep(0,100), N0_upper=rep(0,100),
                              N1=rep(0,100), N1_lower=rep(0,100), N1_upper=rep(0,100),
                              origin=rep(0,100), origin_lower=rep(0,100), origin_upper = rep(0,100),
                              seed=rep(0,100))
  rowcounter = 1
  prime = FALSE
  
  # if inference was done using bdmm prime
  if(grepl(files[1], pattern = "prime")){
    prime = TRUE
    infParamsTable
  }else{
    infParamsTable$root_upper =  infParamsTable$root_lower = infParamsTable$root  = rep(0, 100)
  }
    
  
  for (file in files){
    # get seed from file
    true_sim_params <- split_params_from_filename(file)
    seed = as.numeric(true_sim_params["s"])
    print(file)
    print(seed)
    
    #fill  params in infParamsTable
    ## read in inference log
    estimates <- parse_beast_log(paste(param_dir, file, sep = "/"))
    estimates <- remove_burn_ins(estimates, burn_in_fraction = 0.1)
    
    if (prime){
      colnames(estimates)[c(6:7,11:12, 24, 20:21)] = c("birthRate_1", "birthRate_2", "rateMatrix_1", "rateMatrix_2", "origin", "sp1_no_sampling", "sp2_no_sampling")
    }
    
    ## use median + HPD upper & lower to fill table
    infParamsTable[rowcounter, 1] = median(estimates$birthRate_1, na.rm = TRUE)
    infParamsTable[rowcounter, 2] = hdi(as.numeric(estimates$birthRate_1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 3] = hdi(as.numeric(estimates$birthRate_1),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 4] = median(estimates$birthRate_2, na.rm = TRUE)
    infParamsTable[rowcounter, 5] = hdi(as.numeric(estimates$birthRate_2),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 6] = hdi(as.numeric(estimates$birthRate_2),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 7] = median(estimates$rateMatrix_1, na.rm = TRUE)
    infParamsTable[rowcounter, 8] = hdi(as.numeric(estimates$rateMatrix_1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 9] = hdi(as.numeric(estimates$rateMatrix_1),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 10] = median(estimates$rateMatrix_2, na.rm = TRUE)
    infParamsTable[rowcounter, 11] = hdi(as.numeric(estimates$rateMatrix_2),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 12] = hdi(as.numeric(estimates$rateMatrix_2),credMass = 0.95)[[2]]
    
    if ("samplingProportion__4" %in% colnames(estimates)){
      infParamsTable[rowcounter, 13] = median(estimates$samplingProportion__2)
      infParamsTable[rowcounter, 14] = hdi(as.numeric(estimates$samplingProportion__2),credMass = 0.95)[[1]]
      infParamsTable[rowcounter, 15] = hdi(as.numeric(estimates$samplingProportion__2),credMass = 0.95)[[2]]
      
      infParamsTable[rowcounter, 16] = median(estimates$samplingProportion__4)
      infParamsTable[rowcounter, 17] = hdi(as.numeric(estimates$samplingProportion__4),credMass = 0.95)[[1]]
      infParamsTable[rowcounter, 18] = hdi(as.numeric(estimates$samplingProportion__4),credMass = 0.95)[[2]]
      
      # get estimates of N from sampling proportion and #samples
      N0_estimates = 50 / estimates$samplingProportion__2
      N1_estimates = 50 / estimates$samplingProportion__4
      
      infParamsTable[rowcounter, 19] = median(N0_estimates)
      infParamsTable[rowcounter, 20] = hdi(as.numeric(N0_estimates),credMass = 0.95)[[1]]
      infParamsTable[rowcounter, 21] = hdi(as.numeric(N0_estimates),credMass = 0.95)[[2]]
      
      infParamsTable[rowcounter, 22] = median(N1_estimates)
      infParamsTable[rowcounter, 23] = hdi(as.numeric(N1_estimates),credMass = 0.95)[[1]]
      infParamsTable[rowcounter, 24] = hdi(as.numeric(N1_estimates),credMass = 0.95)[[2]]
      
    }else{
      
      infParamsTable[rowcounter, 13] = median(estimates$samplingProportion__1)
      infParamsTable[rowcounter, 14] = hdi(as.numeric(estimates$samplingProportion__1),credMass = 0.95)[[1]]
      infParamsTable[rowcounter, 15] = hdi(as.numeric(estimates$samplingProportion__1),credMass = 0.95)[[2]]
      
      infParamsTable[rowcounter, 16] = median(estimates$samplingProportion__2)
      infParamsTable[rowcounter, 17] = hdi(as.numeric(estimates$samplingProportion__2),credMass = 0.95)[[1]]
      infParamsTable[rowcounter, 18] = hdi(as.numeric(estimates$samplingProportion__2),credMass = 0.95)[[2]]
      
      # get estimates of N from sampling proportion and #samples
      N0_estimates = 50 / estimates$samplingProportion__1
      N1_estimates = 50 / estimates$samplingProportion__2
      
      infParamsTable[rowcounter, 19] = median(N0_estimates)
      infParamsTable[rowcounter, 20] = hdi(as.numeric(N0_estimates),credMass = 0.95)[[1]]
      infParamsTable[rowcounter, 21] = hdi(as.numeric(N0_estimates),credMass = 0.95)[[2]]
      
      infParamsTable[rowcounter, 22] = median(N1_estimates)
      infParamsTable[rowcounter, 23] = hdi(as.numeric(N1_estimates),credMass = 0.95)[[1]]
      infParamsTable[rowcounter, 24] = hdi(as.numeric(N1_estimates),credMass = 0.95)[[2]]
    }
    infParamsTable[rowcounter, "origin"] = median(estimates$origin, na.rm = TRUE)
    infParamsTable[rowcounter, "origin_lower"] = hdi(as.numeric(estimates$origin),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, "origin_upper"] = hdi(as.numeric(estimates$origin),credMass = 0.95)[[2]]
    
   
  if (prime){
    infParamsTable[rowcounter, "count01"] = median(estimates$typeMappedTree.count_0_to_1, na.rm = TRUE)
    infParamsTable[rowcounter, "count01_lower"] = hdi(as.numeric(estimates$typeMappedTree.count_0_to_1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, "count01_upper"] = hdi(as.numeric(estimates$typeMappedTree.count_0_to_1),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, "count10"] = median(estimates$typeMappedTree.count_1_to_0, na.rm = TRUE)
    infParamsTable[rowcounter, "count10_lower"] = hdi(as.numeric(estimates$typeMappedTree.count_1_to_0),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, "count10_upper"] = hdi(as.numeric(estimates$typeMappedTree.count_1_to_0),credMass = 0.95)[[2]]
  
  }else{
    infParamsTable[rowcounter, "root"] = median(estimates$birthDeathMigration.t.alignment.probForRootType0, na.rm = TRUE)
    infParamsTable[rowcounter, "root_lower"] = hdi(as.numeric(estimates$birthDeathMigration.t.alignment.probForRootType0),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, "root_upper"] = hdi(as.numeric(estimates$birthDeathMigration.t.alignment.probForRootType0),credMass = 0.95)[[2]]
  }
    
    infParamsTable[rowcounter, "seed"] = seed
    
    rowcounter = rowcounter + 1
  }
  
  return(infParamsTable)
}

get_infResultsTable_bdsky <- function(files, param_dir){
  # get inference results for trees inferred under the bdsky model
  
  infParamsTable = data.frame(br0=rep(0,100), br0_lower=rep(0,100), br0_upper=rep(0,100),
                              br1=rep(0,100), br1_lower=rep(0,100), br1_upper=rep(0,100),
                              mr01=rep(0,100),mr01_lower=rep(0,100), mr01_upper=rep(0,100),
                              mr10=rep(0,100),mr10_lower=rep(0,100), mr10_upper=rep(0,100),
                              freq0=rep(0,100), freq0_lower=rep(0,100), freq0_upper=rep(0,100),
                              freq1=rep(0,100), freq1_lower=rep(0,100), freq1_upper=rep(0,100),
                              sp01=rep(0,100), sp01_lower=rep(0,100), sp01_upper=rep(0,100),
                              sp02=rep(0,100), sp02_lower=rep(0,100), sp02_upper=rep(0,100),
                              sp03=rep(0,100), sp03_lower=rep(0,100), sp03_upper=rep(0,100),
                              sp04=rep(0,100), sp04_lower=rep(0,100), sp04_upper=rep(0,100),
                              sp05=rep(0,100), sp05_lower=rep(0,100), sp05_upper=rep(0,100),
                              sp11=rep(0,100), sp11_lower=rep(0,100), sp11_upper=rep(0,100),
                              sp12=rep(0,100), sp12_lower=rep(0,100), sp12_upper=rep(0,100),
                              sp13=rep(0,100), sp13_lower=rep(0,100), sp13_upper=rep(0,100),
                              sp14=rep(0,100), sp14_lower=rep(0,100), sp14_upper=rep(0,100),
                              sp15=rep(0,100), sp15_lower=rep(0,100), sp15_upper=rep(0,100),
                              root0=rep(0,100), root0_lower=rep(0,100), root0_upper=rep(0,100),
                              root1=rep(0,100), root1_lower=rep(0,100), root1_upper=rep(0,100),
                              seed=rep(0,100))
  rowcounter = 1
  
  for (file in files){
    # get seed from file
    true_sim_params <- split_params_from_filename(file)
    seed = as.numeric(true_sim_params["s"])
    print(file)
    print(seed)
    
    #fill  params in infParamsTable
    ## read in inference log
    estimates <- parse_beast_log(paste(param_dir, file, sep = "/"))
    estimates <- remove_burn_ins(estimates, burn_in_fraction = 0.1)
    
    ## use median + HPD upper & lower to fill table
    infParamsTable[rowcounter, 1] = median(estimates$birthRate_1)
    infParamsTable[rowcounter, 2] = hdi(as.numeric(estimates$birthRate_1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 3] = hdi(as.numeric(estimates$birthRate_1),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 4] = median(estimates$birthRate_2)
    infParamsTable[rowcounter, 5] = hdi(as.numeric(estimates$birthRate_2),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 6] = hdi(as.numeric(estimates$birthRate_2),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 7] = median(estimates$rateMatrix_1)
    infParamsTable[rowcounter, 8] = hdi(as.numeric(estimates$rateMatrix_1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 9] = hdi(as.numeric(estimates$rateMatrix_1),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 10] = median(estimates$rateMatrix_2)
    infParamsTable[rowcounter, 11] = hdi(as.numeric(estimates$rateMatrix_2),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 12] = hdi(as.numeric(estimates$rateMatrix_2),credMass = 0.95)[[2]]
  
    infParamsTable[rowcounter, 13] = median(estimates$type.frequencies_1)
    infParamsTable[rowcounter, 14] = hdi(as.numeric(estimates$type.frequencies_1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 15] = hdi(as.numeric(estimates$type.frequencies_1),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 16] = median(estimates$type.frequencies_2)
    infParamsTable[rowcounter, 17] = hdi(as.numeric(estimates$type.frequencies_2),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 18] = hdi(as.numeric(estimates$type.frequencies_2),credMass = 0.95)[[2]]
  
    
    infParamsTable[rowcounter, 19] = median(estimates$samplingProportion__2)
    infParamsTable[rowcounter, 20] = hdi(as.numeric(estimates$samplingProportion__2),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 21] = hdi(as.numeric(estimates$samplingProportion__2),credMass = 0.95)[[2]]
  
    
    infParamsTable[rowcounter, 22] = median(estimates$samplingProportion__4)
    infParamsTable[rowcounter, 23] = hdi(as.numeric(estimates$samplingProportion__4),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 24] = hdi(as.numeric(estimates$samplingProportion__4),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 25] = median(estimates$samplingProportion__6)
    infParamsTable[rowcounter, 26] = hdi(as.numeric(estimates$samplingProportion__6),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 27] = hdi(as.numeric(estimates$samplingProportion__6),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 28] = median(estimates$samplingProportion__8)
    infParamsTable[rowcounter, 29] = hdi(as.numeric(estimates$samplingProportion__8),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 30] = hdi(as.numeric(estimates$samplingProportion__8),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 31] = median(estimates$samplingProportion__10)
    infParamsTable[rowcounter, 32] = hdi(as.numeric(estimates$samplingProportion__10),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 33] = hdi(as.numeric(estimates$samplingProportion__10),credMass = 0.95)[[2]]
    #
    infParamsTable[rowcounter, 34] = median(estimates$samplingProportion__12)
    infParamsTable[rowcounter, 35] = hdi(as.numeric(estimates$samplingProportion__12),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 36] = hdi(as.numeric(estimates$samplingProportion__12),credMass = 0.95)[[2]]
    
    
    infParamsTable[rowcounter, 37] = median(estimates$samplingProportion__14)
    infParamsTable[rowcounter, 38] = hdi(as.numeric(estimates$samplingProportion__14),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 39] = hdi(as.numeric(estimates$samplingProportion__14),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 40] = median(estimates$samplingProportion__16)
    infParamsTable[rowcounter, 41] = hdi(as.numeric(estimates$samplingProportion__16),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 42] = hdi(as.numeric(estimates$samplingProportion__16),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 43] = median(estimates$samplingProportion__18)
    infParamsTable[rowcounter, 44] = hdi(as.numeric(estimates$samplingProportion__18),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 45] = hdi(as.numeric(estimates$samplingProportion__18),credMass = 0.95)[[2]]
    
    infParamsTable[rowcounter, 46] = median(estimates$samplingProportion__20)
    infParamsTable[rowcounter, 47] = hdi(as.numeric(estimates$samplingProportion__20),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 48] = hdi(as.numeric(estimates$samplingProportion__20),credMass = 0.95)[[2]]
    #
    
    infParamsTable[rowcounter, 49] = median(estimates$birthDeathMigration.t.alignment.probForRootType0, na.rm = TRUE)
    infParamsTable[rowcounter, 50] = hdi(as.numeric(estimates$birthDeathMigration.t.alignment.probForRootType0),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 51] = hdi(as.numeric(estimates$birthDeathMigration.t.alignment.probForRootType0),credMass = 0.95)[[2]]
    
    
    infParamsTable[rowcounter, 52] = median(estimates$birthDeathMigration.t.alignment.probForRootType1, na.rm = TRUE)
    infParamsTable[rowcounter, 53] = hdi(as.numeric(estimates$birthDeathMigration.t.alignment.probForRootType1),credMass = 0.95)[[1]]
    infParamsTable[rowcounter, 54] = hdi(as.numeric(estimates$birthDeathMigration.t.alignment.probForRootType1),credMass = 0.95)[[2]]
    
    
    infParamsTable[rowcounter, 55] = seed
    
    rowcounter = rowcounter + 1
  }
  
  return(infParamsTable)
}


get_infResults_table <- function(files, inf_model, param_dir){
  # bundle together result functions for different inference models
  
  if (inf_model == "bd"){
    infResultsTable = get_infResultsTable_bd(files = files, param_dir = param_dir)

  }else if (inf_model == "bdsky"){
    infResultsTable = get_infResultsTable_bdsky(files = files, param_dir = param_dir)
  
  }else if (inf_model == "sc"){
    infResultsTable = get_infResultsTable_sc(files = files, param_dir = param_dir)
  
  } else{
    
    stop(paste0("Inference model ", inf_model, " not yet specified!"))
  } 
  
  return(infResultsTable)
}

final_popSize_BDdetermSamptree <- function(simtreedir, basename, deme ){
  if (deme != 0 && deme != 1){
    stop("deme has to be either 0 or 1!")
  }
  command=paste("grep -oP 'location=\"",deme,"\",is_sampled=\"[a-zA-Z]*\",time_forward=\"25.0\"' ",
                simtreedir, basename, ".nexus | wc -l", sep = "")
  popsize_deme <- system(command, intern = TRUE)
  return(popsize_deme)
}

