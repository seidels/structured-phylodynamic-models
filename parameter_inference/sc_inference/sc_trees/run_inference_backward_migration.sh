#!/bin/bash

echo "This script runs the parameter inference of the simulated trees in the input dir under the specified inference xml and stores the inference log in the outputdir"
echo "Required packages: java, BEAST"

if [ -z "$1" ]; then
echo "specify case_x!: case_1, case_2, ..."
exit
fi

# directories used in the script
## code dirs
code_dir="$PWD"
scripts_4all_inf="$code_dir/../../scripts_4all_inferences"

## data dirs
data_dir="../../../data"
output_dir="$data_dir/inference_logs/sc_inf/SC/backwardMigration/$1"
tip_info_dir="$output_dir/../../$1/tip_info"
tree_dir="$data_dir/simulated_trees/SC/$1"


# Check
if [ ! -d "$output_dir" ];then
mkdir $output_dir
mkdir $tip_info_dir
fi

# load necessary libraries
module load java
module load phylo 

# list all tree files in input dir, assume there are always two files with the same base name, i.e. there always exists basename.newick and basename.nexus
for file in $tree_dir/*; do
    
    if grep -q "nexus" <<< $file; then
	
	# get file name characteristics
	#echo "$file" 
	basename=`grep -oP "(?<=$1/)\S*(?=.nex)" <<< $file`
	# extract basename 
	seed=`grep -oP "(?<=s:)[0-9]*" <<< $basename`
	#echo $seed

#------------------------------------------------------------------------------#
	# file operations to prepare inference - uncopy before starting inference for the first time!
      
	# cp inference xml to output dir
	#cp $code_dir/sc_backward_inference.xml $output_dir/${basename}_scInf.xml
	
	# insert tip & starting tree info in inference xml
	#$code_dir/update_inference.sh $tip_info_dir $output_dir/${basename}_scInf.xml locations.txt ${basename}_times.txt $tree_dir/${basename}.newick

#------------------------------------------------------------------------------#
	# running seedwise option

	if [ -z "$2" ]; then
	    echo "Running inference on complete directory"

	elif [ "$seed" -eq "$2" ]; then
	    echo "Running inference for seed $2 only"

	    # do inference
	    sbatch --time=180:00:00 --job-name="${1}_sc_${seed}" --mem-per-cpu=4000 --wrap="java -Xmx2048m -jar ~/beast2.6.jar -seed 1 -overwrite -working $output_dir/${basename}_scInf.xml > $output_dir/${basename}_scInf.out " 

	else
	    continue
	fi
	
	#sbatch --time=180:00:00 --job-name="${1}_sc_${seed}" --mem-per-cpu=4000 --wrap="java -Xmx2048m -jar ~/beast2.6.jar -seed 1 -overwrite -working $output_dir/${basename}_scInf.xml > $output_dir/${basename}_scInf.out " 

#------------------------------------------------------------------------------#	
       
    else
	continue
	#echo "Jumping over newick file"
    fi
done
