#!/bin/bash

display_usage(){
echo "this script takes as the parameter case. Thereupon it sources the relevant simulation parameters and generates 100 multitype birth death trees. Additionally, it computes the final population sizes and the sampling proportions for each tree and deme."
echo "run as:"
echo "./run_simulation.sh case_x"
echo "Necessary packages: java, python and a BEAST executable file, e.g. from http://www.beast2.org/"
}

if [ -z "$1" ];
then
    echo "Argument missing! Specify case_x for x in {1, 2, ...}"
    exit
fi 

# source simulation parameters
source ../simulation_parameters.sh
nSeeds=100
test_mode=0

#specify output directory 
output_dir_sampled="../../simstudy/data/simulated_trees/BD_rhoSamp/$1/sampled_trees"
output_dir_full="../../simstudy/data/simulated_trees/BD_rhoSamp/$1/full_trees"
output_dir_values="../../simstudy/data/simulated_trees/BD_rhoSamp/$1/values"



# create output dirs, if not already present
if [ ! -d "$output_dir_sampled" ]; then
mkdir -p "$output_dir_sampled"
fi

if [ ! -d "$output_dir_full" ]; then
mkdir -p "$output_dir_full"
fi

if [ ! -d "$output_dir_values" ]; then
mkdir -p "$output_dir_values"
fi

# create file, where final population sizes and sampling proportions
# will be saved
touch $output_dir_values/populationSizes.csv
echo "seed;popSize_0;popSize_1" > $output_dir_values/populationSizes.csv

touch $output_dir_values/samplingProportions.csv
echo "seed;samplingProportion_0;samplingProportion_1" > $output_dir_values/samplingProportions.csv


#when on euler, load java module
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    module load java
fi

if [[ "$1" == "case_100" ]]; then

    echo "Testing started"
    nSeeds=1
    testmode=1

    # remove test files, if present from previous run
    if test -f "compSampProp.corr"; then
	rm "compSampProp.corr"
    fi
    if test -f "compPopSize.corr"; then
	rm "compPopSize.corr"
    fi
    
fi
    
# simulate 100 sampled trees
## set seed
RANDOM=69
touch seedLoc.txt

for seed in `seq 1 $nSeeds`
do
    
    echo "Simulating $nSeeds trees"
    # generate random starting location
    loc=$(( $RANDOM % 2 ))
    
    echo "$seed;$loc" >> seedLoc.txt
 
    # simulate sampled tree
    /cluster/home/seidels/beast/bin/beast -seed $seed -overwrite -D "location=${loc},nLineages=${nLineages},output_dir=${output_dir_sampled},birth_rate_0=${birth_rate_0},birth_rate_1=${birth_rate_1},death_rate_0=${death_rate_0},death_rate_1=${death_rate_1},migration_rate_01=${migration_rate_01},migration_rate_10=${migration_rate_10}" sampled_tree.xml

    # simulate full tree
    /cluster/home/seidels/beast/bin/beast -seed $seed -overwrite -D "location=${loc},nLineages=${nLineages},output_dir=${output_dir_full},birth_rate_0=${birth_rate_0},birth_rate_1=${birth_rate_1},death_rate_0=${death_rate_0},death_rate_1=${death_rate_1},migration_rate_01=${migration_rate_01},migration_rate_10=${migration_rate_10}" full_tree.xml

    # add final population sized to file
    ./compute_population_sizes.sh $output_dir_sampled/br0:${birth_rate_0}_br1:${birth_rate_1}_dr0:${death_rate_0}_dr1:${death_rate_1}_mr01:${migration_rate_01}_mr10:${migration_rate_10}_s:${seed}_popSize.json $testmode >> $output_dir_values/populationSizes.csv

    
    # add sampling proportion to file
    ./compute_sampling_proportions.sh $output_dir_full/br0:${birth_rate_0}_br1:${birth_rate_1}_dr0:${death_rate_0}_dr1:${death_rate_1}_mr01:${migration_rate_01}_mr10:${migration_rate_10}_s:${seed}_BDtree.nexus $testmode >> $output_dir_values/samplingProportions.csv
    
done

if [[ "$1" == "case_100" ]]; then

    # if tests were succesful
    if test -f "compSampProp.corr"; then
	echo "Sampling proportion calculation correct"
    else
	echo "Sampling proportion calculation incorrect. Check compSampProp.err for error codes!"
    fi
    if test -f "compPopSize.corr"; then
	echo "Population size calculation correct"
    else
	echo "Population size calculation incorrect. Check compPopSize.err for error codes!"
	echo "Note: If both sampling proportions and population sizes are incorrect, this might be caused by an erroneous tree simulation as well!"
    fi
fi
