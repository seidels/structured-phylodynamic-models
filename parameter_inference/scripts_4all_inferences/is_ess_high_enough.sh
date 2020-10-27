#!/bin/bash

display_usage(){
    echo "run on input directory, where inference log files reside. There the script creates 2 new directories: finished (min ESS > 200) and unfinished (min ESS <200) and moves the log files to their respective category."
    echo "Input Arguments:"
    echo "    $1 - dir, where log files reside | logfile (for kill option) "
    echo "    $2 - {kill, nokill}, whether to kill ongoing jobs, if ESS is high enough"
    echo "    $3 - Job description string, e.g. 'BDdetermSamp_scinf'"
    echo "    $4 - case number"
    echo "    $5 - seed number"
    echo "    $6 - int number"
}


#################################################################################
# kill option -> only execute script on file
if [ "$2" = "kill" ]
then
    mkdir finished
     min_ess=`mess -o h3n2 -t1000 -m $1 | awk -F ' ' '{print $2}'`
     if [ $( echo $min_ess'>'200 | bc -l) == 1 ]; then
	 echo "finished run"
	 echo "${3}_case:${4}_s:${5}_i:${6}"
	 bkill -J "${3}_case_${4}_s:${5}_i:${6}"
	 mv $1 finished/
	 rm sim_${seed}.out
     fi 
     exit 0
fi

#################################################################################
# nokill option - execute script on all logfiles in dir, don't kill jobs
mkdir $1/finished 
for file in $1/*.log; do

    echo $file

    # run mess on file and print smalles ESS value
    min_ess=`mess -o height -t1000 -b 10 -m $file | awk -F ' ' '{print $2}'`
    # check for error in log file
    if [ -z "$min_ess" ]; then
	echo "error in log file $file"
    else
	# if min_ess satisfies requirement, mv to finished
	if [ $( echo $min_ess'>'200 | bc -l) == 1 ]; then
	    echo "finished run"
	    cp $file $1/finished/
	# else keep unfinished runs 
	fi

    fi
done
