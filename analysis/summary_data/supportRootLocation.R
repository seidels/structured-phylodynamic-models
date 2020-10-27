meanfun <- function(dat, i){
  dat_subset = dat[i]
  m = mean(dat_subset)
  return(m)
}

# compute root assignment, given that a minimum posterior probability is required
prob_to_assignment <- function(prob, margin=0.2){
  if (prob > (0.5+margin)){
    return(0)
  }else if (prob <= (0.5 - margin)){
    return(1)
  }else{
    return(NA)
  }
}
get_colnumber <- function(truth_assignment_col){
  if (truth_assignment_col == "true_5050"){
    colnumber = 7
  }else if (truth_assignment_col == "true_6040"){
    colnumber = 8
  }else if(truth_assignment_col == "true_9010"){
    colnumber = 9
  }else{
    exit("No such assignment")
  }
  return(colnumber)
}

bootstrapped_mean <- function(infResults_combined, model, truth_assignment_col){
  
  # choose column in dataset for bootstrapped sampling
  colnumber = get_colnumber(truth_assignment_col)
  bootdat = infResults_combined[which(infResults_combined$model == model & !is.na(infResults_combined[,colnumber])), truth_assignment_col]
  
  #if no data points present with required posterior probability, then return NA
  if (length(bootdat) == 0){
    return(NA)
  }
  #else compute bootstrapped mean
  b = boot(data = bootdat , statistic = meanfun, R = 1000)
  return(b$t0)
}
bootstrapped_sd <- function(infResults_combined, model, truth_assignment_col){
  
  # choose column in dataset for bootstrapped sampling
  colnumber = get_colnumber(truth_assignment_col)
  bootdat = infResults_combined[which(infResults_combined$model == model & !is.na(infResults_combined[,colnumber])), truth_assignment_col]
  
  #if no data points present with required posterior probability, then return NA
  if (length(bootdat) == 0){
    return(NA)
  }
  #else compute bootstrapped sd around mean
  b = boot(data = bootdat, statistic = meanfun, R = 1000)
  return(sd(b$t))
}

# get the number of trees for which a root state can be determined given the minimum posterior requirement
get_n_assignments <- function(infResults_combined, model, truth_assignment_col){
  
  n_assignments = sum(!is.na(infResults_combined[which(infResults_combined$model == model), truth_assignment_col]))
  return(n_assignments)
}
