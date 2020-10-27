#!/bin/bash

display_usage(){
echo "this script takes as the parameter case. Thereupon it sources the relevant simulation parameters and generates 100 structured coalescent trees with tip times sampled uniformly at random."
echo "run as:"
echo "./run_simulations.sh case_x"
echo "Necessary packages: java, python and a BEAST jar file, e.g. http://www.beast2.org/"
}


#load libraries 
module load java
module load python/3.6.0


# check input arguments
if [ -z "$1" ];
then
    echo "Argument missing! Specify case_x for x in {1, 2, ...}"
    exit
fi

## define and create directories
outputDirTrees="../../simstudy/data/simulated_trees/SC/$1"
outputDirSamplingTimes="../../simstudy/data/inference_logs/sc_inf/SC/$1/tip_info"
code_dir="$PWD"

if [ ! -d "$outputDirTrees" ]; then
mkdir -p "$outputDirTrees/"
fi
if [ ! -d "$outputDirSamplingTimes" ]; then
mkdir -p "$outputDirSamplingTimes/"
fi

# source parameter values from BD tree simulation
case=$1
source $code_dir/../simulation_parameters.sh
source $code_dir/func.sh

for seed in `seq 1 100`; do

    # draw sampling times uniformly at random 
    python generate_tip_times.py $seed

    # mv tip dates file to inference folder
    mv randomTipTimes.txt $outputDirSamplingTimes/cr0:${coalescence_rate_0}_cr1:${coalescence_rate_1}_q01:${backmigration_rate_01}_q10:${backmigration_rate_10}_s:${seed}_times.txt
    cp TipTypes.txt $outputDirSamplingTimes/locations.txt

    # put sampling times into xml
   # read files and store parametrisation in string, which will then be used by MASTER
    params_for_xml=""
    ## this rather complicated setup is needed to work with plates in the xml
    ## first, all node numbers are either put into location list 0 or 1
    ## sec, the nodes' dates are put into time list 0 or 1 depending on their loc
    ## third, each time list will be put into a plate in the xml
    locAr0=()
    locAr1=()
    timeList0=""
    timeList1=""

    ## add in tip locations
    while read a b;
    do
	# if node in location 1, add to 
	if [ "$b" = "1" ]; then
	        locAr1+=("$a")
		else
	        locAr0+=("$a")
		fi

    done < TipTypes.txt

    ## add in tip times
    while read a b;
    do
	
	# convert forward times to backward times
	params_for_xml="${params_for_xml},t${a}=${b}"

	# if node is in location 0
	if containsElement "$a" "${locAr1[@]}"; then
	        timeList1="${timeList1},${b}"
		else
	        timeList0="${timeList0},${b}"
		fi

    done < $outputDirSamplingTimes/cr0:${coalescence_rate_0}_cr1:${coalescence_rate_1}_q01:${backmigration_rate_01}_q10:${backmigration_rate_10}_s:${seed}_times.txt

    ############################################################################
    # insert time lists into xml
    cp $code_dir/sc_endemic.xml $code_dir/tmp.xml
    sed -i "s/REPLACE_T0_LIST/${timeList0:1}/g" $code_dir/tmp.xml
    sed -i "s/REPLACE_T1_LIST/${timeList1:1}/g" $code_dir/tmp.xml
     
    # add all params together
    params_for_xml="migration_rate_01=${backmigration_rate_01},migration_rate_10=${backmigration_rate_10},coal_rate_0=${coalescence_rate_0},coal_rate_1=${coalescence_rate_1},identifier=$outputDirTrees/cr0:${coalescence_rate_0}_cr1:${coalescence_rate_1}_q01:${backmigration_rate_01}_q10:${backmigration_rate_10}_s:${seed}${params_for_xml}"

    # simulate
    java -Xmx3072m -Xss10m -jar beast.jar -seed $seed -D $params_for_xml -overwrite $code_dir/tmp.xml
    rm $code_dir/tmp.xml
   
    
done
