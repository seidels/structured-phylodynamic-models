#!/bin/bash

#echo "This script computes the fraction from the #sampled leaves from deme i by the total number of leaves from deme i generated in a particular simulation."


#use gnu grep on mac
if [[ "$OSTYPE" == "darwin"* ]]; then
    grep=/usr/local/bin/ggrep
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    grep=/usr/bin/grep
fi

#define necessary parameters

## tree file with all leaves 
fullTreeFile=$1
testmode=$2
## number of samples from each deme is fixed to 50
nSamples=50

# grep seed
seed=`echo $fullTreeFile | $grep -oP "(?<=s:)[0-9]*"`

# determine the total #leaves
nLeaves_0=`$grep -oP "location=\"0\",reaction=\"Death" $fullTreeFile | wc -l | tr -s [:space:]`
nLeaves_1=`$grep -oP "location=\"1\",reaction=\"Death" $fullTreeFile | wc -l | tr -s [:space:]`

# calculate sampling proportion
sampProp_0=`printf "%.2f\n" $( bc -l <<< "($nSamples / $nLeaves_0)")`
sampProp_1=`printf "%.2f\n" $( bc -l <<< "($nSamples / $nLeaves_1)")`

if [[ "$testmode" == "1" ]]; then
    
    test "$sampProp_0" = "0.94" && echo "sampProp_0 correct" >> compSampProp.corr || echo "sampProp_0 should be 0.94 but $sampProp_0 was returned" >> compSampProp.err 
    test "$sampProp_1" = "0.88" && echo "sampProp_1 correct"  >> compSampProp.corr || echo "sampProp_1 should be 0.88 but $sampProp_1 was returned" >> compSampProp.err
fi


echo "$seed;$sampProp_0;$sampProp_1"

