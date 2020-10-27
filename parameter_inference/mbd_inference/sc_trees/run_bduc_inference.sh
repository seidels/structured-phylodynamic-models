#!/bin/bash

echo "This script runs the parameter inference of the simulated trees in the input dir under the specified inference xml and stores the inference log in the outputdir. "
echo "Necessary packages: java, bdmm jar file or BEAST 2 jar file with a bdmm installation."

if [ -z "$1" ]; then
echo "Argument missing! Provide case_x"
exit
fi

# define function for simple calculations
calc(){ awk "BEGIN { print "$*" }"; }

# directories used in the script
## code dirs
scripts_4all_inf="../../../scripts_4all_inferences"
bd_inf="$PWD"

## output directory for euler and mac

data_dir="../../../simstudy/data"
    
output_dir="$data_dir/inference_logs/bdpsi/SC/$1"
tip_info_dir="$data_dir/inference_logs/sc_inf/SC/$1/tip_info"
tree_dir="$data_dir/simulated_trees/SC/$1"


if [ ! -d "$output_dir" ]; then
    mkdir -p $output_dir
fi


# list all tree files in input dir, assume there are always two files with the same base name, i.e. there always exists basename.newick and basename.nexus
for file in $tree_dir/*; do
        
    if grep -q "nexus" <<< $file; then
	
	# extract parts of the file name, that will be used to find other files + make lsf job name unique
	basename=`grep -oP "(?<=$1/)\S*(?=.nex)" <<< $file`  
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

	# put all pieces of information (tree, tip locs & times) in xml	
	# cp inference xml to output dir
	cp $bd_inf/bduc_inference.xml $output_dir/${basename}_bducInf.xml
	#insert tip & starting tree info in inference xml
	$bd_inf/update_bduc_inference.sh $tip_info_dir $output_dir/${basename}_bducInf.xml locations.txt ${basename}_times.txt $tree_dir/${basename}.newick

      
	# change sampling proportion change time to height a bit larger than first sample
	
#---------------------------------------------------------------------#
	# Run inference
	if [ "$2" = "r" ]; then
	    echo "Resuming inference"

	    java -Xmx2048m -jar /cluster/home/seidels/beast_and_friend/bdmm.jar -overwrite -resume -working -seed 1 -D "tree_file=$tree_dir/${basename}.newick" $output_dir/${basename}_bducInf.xml > $output_dir/inf_${casenr}_${seed}.txt


	else

	    echo "not resuming" 
	    
	    java -Xmx2048m -jar /cluster/home/seidels/beast_and_friend/bdmm.jar -overwrite -working -seed 1 -D "tree_file=$tree_dir/${basename}.newick" $output_dir/${basename}_bducInf.xml
	    #exit

	fi
    else
	echo "Jumping over newick file"
    fi

done
