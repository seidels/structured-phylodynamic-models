# this script runs over all finished inference logs (generated from inference scripts within parameter_inference/sc_inference/sc_trees) and returns a summary data table for each simulation parameter set.

# set paths and libraries
setwd("~/Projects/structured-phylodynamic-models/analysis/logfile")
cases = 51 #52:53
source("summary_data_from_BEAST_log.R")
source("create_param_ess_table.R")
source("../summary_data/inference_performance.R")
logfile_path = "../../data/inference_logs/sc_inf/SC/"
results_path = "../../data/summary_data/"
library(boot)

#get results into summary table
for (casenr in cases){
  result_name = paste("result_", casenr, sep = "")
  results = get_all_params(param_dir = paste(logfile_path,"case_",casenr, "/", sep = ""),
                           sim_model = "SC", inf_model = "sc",
                           record_only_root_type = TRUE, casenr = casenr
  )

  assign(result_name, results)

  save(list = paste0("result_", casenr),
       file=paste0(results_path,"all_params_",casenr,".Rdat"))

}
