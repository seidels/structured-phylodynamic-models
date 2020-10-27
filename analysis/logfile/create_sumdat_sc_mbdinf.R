# this script runs over all finished inference logs (generated from inference scripts within parameter_inference/mbd_inference/sc_trees) and returns a summary data table for each simulation parameter set.

# set paths and libraries
setwd("/Users/seidels/euler/Master_project/analysis/logfile")
cases = 51:53
source("summary_data_from_BEAST_log.R")
source("create_param_ess_table.R")
source("../summary_data/inference_performance.R")
logfile_path = "/Path/to/logfiles/"
results_path = "/Path/to/output/dir/"

source("/Users/seidels/euler/Master_project/analysis/summary_data/inference_performance.R")
library(boot)

#get results into summary table
for (casenr in cases){
  result_name = paste("result_", casenr, sep = "")
  param_dir = paste(logfile_path,"case_",casenr,"/finished/", sep = "")
  results = get_all_params(param_dir = param_dir,
                           sim_model = "SC", inf_model = "bd",
                           record_only_root_type = TRUE, casenr = casenr
  )
  
  assign(result_name, results)
  
  save(list = paste0("result_", casenr),
       file=paste0(results_path,"all_params_",casenr,".Rdat"))
  
}

