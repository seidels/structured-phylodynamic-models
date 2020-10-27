#!/bin/bash

echo "This script runs the parameter inference of the simulated trees in the input dir under the specified inference xml and stores the inference log in the outputdir"
echo "Necessary packages: java, BEAST 2 jar"

if [ -z "$1" ]; then
echo "Argument missing! Provide case_x"
exit
fi

# define function for simple calculations
calc(){ awk "BEGIN { print "$*" }"; }

# directories used in the script
## code dirs
scripts_4all_inf="../../scripts_4all_inferences"
bd_inf="$PWD"


data_dir="../../../simstudy/data"


output_dir="$data_dir/inference_logs/bdpsi/BD_rhoSamp/$1"
tip_info_dir="$output_dir/tip_info"
tree_dir="$data_dir/simulated_trees/BD_rhoSamp/$1/sampled_trees"


if [ ! -d "$output_dir" ] || [ ! -d "$tip_info_dir" ]; then
    mkdir -p $tip_info_dir
fi


# On euler change to working dir & load necessary libraries
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    module load java
    module load phylo 
fi


# list all tree files in input dir, assume there are always two files with the same base name, i.e. there always exists basename.newick and basename.nexus
for file in $tree_dir/*; do
        
    if grep -q "nexus" <<< $file; then
	
	# extract parts of the file name, that will be used to find other files + make lsf job name unique
	basename=`grep -oP "(?<=sampled_trees/)\S*(?=.nex)" <<< $file`  
	echo "this is the basename: $basename"
	seed=`grep -oP "(?<=s:)[0-9]*" <<< $basename`
	echo "$seed"             
	casenr=`grep -oP "[0-9]*" <<< $1`
	
	#---------------------------------------------------------------------#
	# run on all trees of on one particular seed

	if [ -z "$3" ];then
	    echo "Run inference on complete directory"
	elif [ "$seed" == "$3" ];then
	    echo "Run for seed $3 only!"
	else
	    continue
	fi
#---------------------------------------------------------------------#
	#file operations to prepare inference
	
	### extract tip locations and times from nexus tree
	$scripts_4all_inf/locs_times_from_nexus_tree.sh $file $tip_info_dir/${basename}_locations.txt $tip_info_dir/${basename}_times.txt BD_rhoSamp
       

	# put all pieces of information (tree, tip locs & times) in xml	
	# cp inference xml to output dir
	cp $bd_inf/bduc_inference.xml $output_dir/${basename}_bducInf.xml
	#insert tip & starting tree info in inference xml
	$bd_inf/update_bduc_inference.sh $tip_info_dir $output_dir/${basename}_bducInf.xml ${basename}_locations.txt ${basename}_times.txt $tree_dir/${basename}.newick
	
#---------------------------------------------------------------------#
	# Run inference
	if [ "$2" = "r" ]; then
	    echo "Resuming inference"
	    java -Xmx2048m  -jar beast.jar -overwrite -resume -working -D "tree_file=$tree_dir/${basename}.newick" $output_dir/${basename}_bducInf.xml > $output_dir/inf_${casenr}_$seed.txt 

	else

	    echo "not resuming" 
	    	    

	    java -Xmx2048m -jar beast.jar -overwrite -working -seed 1 -D "tree_file=$tree_dir/${basename}.newick" $output_dir/${basename}_bducInf.xml
	    

	fi
    else
	echo "Jumping over newick file"
    fi

done
