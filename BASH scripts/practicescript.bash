#! /bin/bash -l
# submission variables = experiment directory (eg CCA-ATP), num runs, sample frequency, runtime

echo "practice script started"

args=("$@")                           #store all submission variables as "args"

directory=$(pwd)                      # store the current working directory
experiment=${args[0]}                 # Save the experiment input more comprehensibly 
targetfile="step6_production.inp"     # save the script to be run more comprehensibly   ... kind of

cd $directory/$experiment/namd/       # switch to the namd directory for changing experiment variables


variable=("restartfreq" "dcdfreq" "xstFreq" "outputEnergies" "outputTiming" "numsteps" "run")   # variables to be changed from the standard namd outputs

for i in ${variable[@]}              # for each variable which needs changing
do
	if [ $i == "restartfreq" ]   # restart frequency is normally less often
	then
		tmpvar=$(expr ${args[2]} \* 10)  # set the restart frequency to 10x the sampling frequency

	elif [ $i == "numsteps" -o $i == "run" ]  # number of steps is different to sampling frequency
	then
		tmpvar=${args[3]}                 # set number of steps to input number 3
	else
		tmpvar=${args[2]}                 # set sampling frequency to input number 2
	fi

	sed -i "s/${i}.*/${i}        ${tmpvar};/g" $directory/$experiment/namd/$targetfile               # string search, set line containing variable "i" to variable "i", some whitespace, and then the relevant input variable
	                                                                                                 # end by specifying the target file which is being edited
done

cd $directory                                   #return to the initial directory containing the full experiment folders

touch $experiment"_params.txt"                  # create a paramater file for the batch script

pwd

for (( c=2; c<=${args[1]}; c++ ))               # weird for loop syntax for going through the number of runs (args 1). starts at 2 due to my odd numbering system starting (CCA, CCA_2...)
do
	cp -r $experiment $experiment"_$c"      # copy the the experiment files and rename them
done

pwd

echo "0001" $directory/$experiment/namd/$targetfile >> $experiment"_params.txt"        #add the initial experiment to the paramater file
for (( c=2; c<=${args[1]}; c++ ))                                                      #for loop to add any following experiments to the paramater file
do
	echo "000"$c $directory/$experiment"_$c"/namd/$targetfile >> $experiment"_params.txt"        
done

cat $experiment"_params.txt"               #check final paramater file



