


library(treeio)

sc_tree_dir =  "/Volumes/stadler/cEvoUnpublished/2018-Sophie-CompBDSC/simstudy_3/data/simulated_trees/SC/"

# get true tree locations for coalescent trees
for (case_nr in 1:3){

  case = c(51:53)[case_nr]
  migration = c("1.0", "0.1", "0.01")[case_nr]

  output_file = paste0(sc_tree_dir, "case_", case, "/root_locations.csv")

  # remove existing output file as code below will append.
  if (file.exists(output_file)){
    file.remove(output_file)
  }

  for (simulation_seed in 1:100){

    print(paste("==== Getting root location for tree number ", simulation_seed, " ======"))

    tree_file = paste0(sc_tree_dir, "case_", case, "/cr0:0.01333333333333333333_cr1:0.01333333333333333333_q01:",
                       migration, "_q10:", migration, "_s:", simulation_seed, ".nexus")

    tree = treeio::read.beast(tree_file)

    root_location = get_root_location_from_tree(tree)
    write.table(file = output_file, sep = ",", x = data.frame(seed = simulation_seed, root_location = root_location),
      , append = T, col.names = !file.exists(output_file), row.names = F)

  }
}


get_root_location_from_tree = function(tree){

  node_annotations = as.data.frame(tree@data)

  #root node it the oldest node in the tree, go fetch it!
  node_annotations$time = as.numeric(node_annotations$time)
  node_annotations= node_annotations[order(node_annotations$time, decreasing = T), ]

  # make a small test that this is at least a coalescent event
  assertthat::are_equal(x = node_annotations[1, "reaction"], "Coalescence")

  #Then extract the root location
  root_location = node_annotations[1, "location"]

  return(root_location)
}
