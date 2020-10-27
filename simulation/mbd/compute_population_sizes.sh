#!/bin/bash

#"this file can extract the final population sizes from a trajectory recording json file"

file=$1
testmode=$2

#use gnu grep on mac
if [[ "$OSTYPE" == "darwin"* ]]; then
    grep=/usr/local/bin/ggrep
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    grep=/usr/bin/grep
fi

# extract final popSize from json
popSize_0=`$grep -oP '[0-9]*.[0-9](?=])' $file | tail -2 | head -1`
popSize_1=`$grep -oP '[0-9]*.[0-9](?=])' $file | tail -1`
seed=`echo $file | $grep -oP "(?<=s:)[0-9]*"`

# test case
if [[ "$testmode" == "1" ]]; then

    test "$popSize_0" = "20.0" && echo "popSize_0 correct" >> compPopSize.corr || echo "popSize_0 should be 20.0 but $popSize_0 was returned" >> compPopSize.err 
    test "$popSize_1" = "0.0" && echo "popSize_1 correct" >> compPopSize.corr || echo "popSize_1 should be 0.0 but $popSize_1 was returned" >> compPopSize.err 
fi


# return result
echo "${seed};${popSize_0};${popSize_1}"
