ess_for_params <- function(mess_file, generating_process){
  # Show ess values for parameter combintation

  #read in mess output file 
  mess_out = read.delim(file = mess_file, header = FALSE, sep = "")
  
  if(generating_process == "BD"){
    #construct results table
      results_table=data.frame(matrix(ncol = 11))
      colnames(results_table) = c("br0", "br1", "dr0", "dr1", "sr0", "sr1", "mr01", "mr10", "seed", "ess_bdmm", "ess_mtt")

      # fill results table
      for (i_row in 1:nrow(mess_out)){

          # if we have bdmm inference file then create bdmm entry in results table
          if (strsplit(as.character(mess_out[i_row,1]), "_")[[1]][10] == "bdmm"){
              
              pars_2 = split_params_from_filename(as.character(mess_out[i_row,1]))
              pars_2 = cbind(pars_2, as.numeric(mess_out[i_row, "V3"]), 0)
              colnames(pars_2) <- colnames(results_table)
              
              #pars_2 <- as.numeric(pars_2)
              results_table = rbind(results_table, pars_2)

          }
          else { # else if we have mtt file, add mtt ess to results table
              results_table[nrow(results_table), "ess_mtt"] <- mess_out[i_row, "V3"]
          }
      }
        # clean up table
      results_table = results_table[-c(1),]
      rownames(results_table) <- 1:nrow(results_table)
      results_table= transform(results_table, br0 = as.numeric(br0), br1 = as.numeric(br1),
                             dr0 = as.numeric(dr0), dr1 = as.numeric(dr1), sr0 = as.numeric(sr0), sr1 = as.numeric(sr1),
                             mr01 = as.numeric(mr01), mr10 = as.numeric(mr10))
      return(results_table)
      
  
  }else if(generating_process == "SC"){
  
      #construct results table
      results_table=data.frame(matrix(ncol = 7))
      colnames(results_table) = c("cr0", "cr1", "mr01", "mr10", "seed", "ess_bdmm", "ess_mtt")
      for (i_row in 1:nrow(mess_out)){

          # if we have bdmm inference file then create bdmm entry in results table
          if (strsplit(as.character(mess_out[i_row,1]), "_")[[1]][6] == "bdmm"){
              
              # split the file name to retrieve parameter names and values
              pars_2=split_params_from_filename(filename = as.character(mess_out[i_row, 1]))
              # add bdmm ess entry
              pars_2 = cbind(pars_2, as.numeric(mess_out[i_row, "V3"]), 0)
              colnames(pars_2) <- colnames(results_table)
              results_table = rbind(results_table, pars_2)
              
          }
          # else if we have mtt file, add mtt ess to results table
          else {
              results_table[nrow(results_table), "ess_mtt"] <- mess_out[i_row, "V3"]
          }
          
      }
      # clean up table
      results_table = results_table[-c(1),]
      rownames(results_table) <- 1:nrow(results_table)
      results_table= transform(results_table, cr0 = as.numeric(cr0), cr1 = as.numeric(cr1),
                               mr01 = as.numeric(mr01), mr10 = as.numeric(mr10))
      return(results_table)
  
  }
  else{
      stop('Generating process must be either BD or SC!')
  }
}

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
