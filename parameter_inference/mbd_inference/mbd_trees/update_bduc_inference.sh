#!/bin/bash

# script to take update the beast_mcmc_template for new tree and alignment
## step 1: getvalues from location and time tables,
##join them together to get the syntax needed to plug into BEAST xml
# DELETED# no seq info needed! step 2: change alignment data 
## step 3: insert newick tree

# Arguments:
## $1 input_dir, where location and time table files reside
## $2 inference template file
## $3 locations.txt file
## $4 times.txt file

# Step 1
declare -a files=("$3" "$4")


# format the information in the same syntax used in xml
for file in "${files[@]}"	    
do
    minSamplingTime=10
    echo "$1/$file"
    total_word=""    
    while IFS= read -r line
    do
	counter=0
	for word in $line
	do
	    #echo "word: $word counter: $counter"
	    if [ $counter -eq 0 ]
	    then
		#echo "$word"
		newword=$word
		counter=$(( $counter + 1 ))		
	
	    else
		newword=$newword=$word
		#echo "This is my sampling Time: $word"
		total_word="$total_word,$newword"
		#echo "this is not supposed to be empty: $total_word!"
		if (( $(echo "$word < $minSamplingTime" | bc -l) ));then
		    minSamplingTime=$word
		fi
	    fi
	done
    done < $1/$file
    
    total_word=${total_word:1} 

    #Change info in xml file    
    if [[ "$file" == *locations.txt ]]
    then
	echo "updating tip-type info"
	#echo "$total_word"
	sed -i "112s/.*/value=\"$total_word\">/" $2
    else
	# no longer needed in fixed tree analysis
	echo "updating tip date info"
	#echo "$total_word"
	sed -i "120s/.*/$total_word/" $2
    fi    
done


# insert correct entry                                                                                                                                                           
echo "Inserting tree"
tree=`cat $5` 
echo "value='$tree'" > $2_tmp.newick
sed -e "165r $2_tmp.newick" $2 > $2_inf
mv $2_inf $2                                                                                                                                        
echo "Updating sampling change time:"                              
echo "minimal sampling time: $minSamplingTime"
#sed -i -e "s/sRateChangeT/$minSamplingTime/g" $2

echo "Update finished"

