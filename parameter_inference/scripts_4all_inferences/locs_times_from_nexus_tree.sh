#!/bin/bash

# arguments:
## $1 input nexus tree file
## $2 location output file
## $3 times output file
## $4 tree simulation scheme, e.g. (SC_determSamp, SC_conBDTree,  ...)

display_usage() {
    echo "This script takes an example_tree.nexus file as input, extracts the tips' locations and outputs two tables with columns: taxa, location;
taxa, time"
    echo '  ' 
    echo "Usage: "
    echo "locations_from_nexus.sh input_tree.nexus outputpath/location_file.txt outputpath/time_file.txt BD" 
}

# check, whether too few arguments are being provided
if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

#check whether user looks for help option
if [[ ( $# == "--help" ) || ( $# == "-h" ) ]]
then
    display_usage
    exit 0
fi

# distinguish between SC and BD trees
## note: these tip dates and times exist for BDdetermSamp trees already!
#if [ $4 = SCexp_determSamp ] ; then 
    
    # extract locations from tree file 
#    locs=$( for seed in `seq 1 100`; do
#	grep -oP "(?<=[,\(]$seed\[&type=\")[0-1]" $1
#	done )
    # create taxa, locations for SCexp tree
#    paste <( seq 1 100 ) <( echo $locs ) > $2

if [ $4 = SC_determSamp ]; then    

    # create taxa, locations for SC tree 
    paste <(grep -oP '[0-9]*(?=\[)' $1 )  <(grep -oP '(?<=\d\[\&type="L",location=\")[0-9]' $1 )  > $2 

    # create taxa, times
    paste <(grep -oP '[0-9]*(?=\[)' $1 ) <( grep -oP '(?<=\d\[\&type="L",location=\"[0-9]\",time=)[0-9]*.[0-9]*' $1 ) > $3

elif [ $4 = BD_determSamp ]; then
    
    # create taxa, locations for BD_determSamp tree 
   paste <(grep -oP '[0-9]*(?=\[)' $1 )  <(grep -oP '(?<=\d\[\&location=\")[0-9]' $1 )  > $2 

    # create taxa, times
    paste <(grep -oP '[0-9]*(?=\[)' $1 ) <( grep -oP '(?<=time_forward=\")[0-9]*.[0-9]*(?=\",reaction=\"[sd])' $1 ) > $3

elif [ $4 = BD_rhoSamp ]; then
    
    # create taxa, locations 
    paste <(grep -oP '[0-9]*(?=\[)' $1 )  <(grep -oP '(?<=\d\[\&type="X",location=\")[0-9]' $1 )  > $2 

    # create taxa, times
    paste <(grep -oP '[0-9]*(?=\[)' $1 ) <( grep -oP '(?<=\d\[\&type="X",location=\"[0-9]\",reaction="Death",time=)[0-9]*.[0-9]*' $1 ) > $3

elif [ $4 = SCexp ]; then

echo "Use different file located in code/SCexp"

else    
    # create taxa, locations for BD tree
    paste <(grep -oP '[0-9]*(?=\[)' $1 )  <(grep -oP '(?<=\d\[\&type="X",location=\")[0-9]' $1 )  > $2 

    # create taxa, times
    paste <(grep -oP '[0-9]*(?=\[)' $1 ) <( grep -oP '(?<=\d\[\&type="X",location=\"[0-9]\",reaction="Sampling",time=)[0-9]*.[0-9]*' $1 ) > $3
fi

    # # create taxa, times
    # ## grep leafs at the end of the simulation, they don't contain a reaction attribute 
    # paste <(grep -oP '[0-9]*(?=\[&type="X",location=\"[0-1]\",time)' $1 ) <( grep -oP '(?<=\d\[\&type="X",location=\"[0-9]\",time=)[0-9]*.[0-9]*' $1 ) > $3
    # ## paste leafs which have died during the simulation and therefore contain a reaction attribute
    # paste <(grep -oP '[0-9]*(?=\[&type="X",location=\"[0-1]\",reaction=\"\S{5}\",time)' $1 ) <( grep -oP '(?<=\d\[\&type="X",location=\"[0-9]\",reaction=\"\S{5}\",time=)[0-9]*.[0-9]*' $1 ) >> $3 
    
