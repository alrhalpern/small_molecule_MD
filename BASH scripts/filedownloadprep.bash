#!/bin/bash -l

# Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=01:00:00

# Request 1 gigabyte of RAM (must be an integer followed by M, G, or T)
#$ -l mem=1G


# Request 15 gigabyte of TMPDIR space (default is 10 GB - remove if cluster is diskless)
#$ -l tmpfs=15G

# Set the name of the job.
#$ -N filecollection

#$ -pe mpi 1

# Set the working directory to somewhere in your scratch space.
# Replace "<your_UCL_id>" with your UCL user ID :)                                      SET DIRECTORY!!!!!!!!!!!!!!!!!!!!!!
#$ -wd /home/zcqshal/Scratch/Dimers
#                                                                                       SET JOB NUMBERS!!!!!!!!!!!!!!!!!!!!!!!
args=(100 "L-Ser-ApA" "L-Ser-ApC" "L-Ser-ApG" "L-Ser-CpC" "L-Ser-CpG" "L-Ser-CpU" "L-Ser-GpA" "L-Ser-GpC" "L-Ser-GpG" "L-Ser-UpC" "L-Ser-UpU" "L-Phe-CpC")                           #store all submission variables as "args"

directory=$(pwd)                      # store the current working directory

runs=${args[0]} 

mkdir download-files
#echo ${args[$c]}
#echo $directory/${args[$c]}"/namd/step6_production.dcd"

for (( c=1; c<=$(expr ${#args[@]} - 1 ); c++ )) 
do
	mv $directory/${args[$c]}"/namd/step6_production.dcd" $directory/download-files/${args[$c]}"_step6_production.dcd"
	mv $directory/${args[$c]}"/namd/step4_input.pdb" $directory/download-files/${args[$c]}"_step4_input.pdb"
	mv $directory/${args[$c]}"/namd/step5_equilibration.dcd" $directory/download-files/${args[$c]}"_step5_equilibration.dcd"

	for (( d=2; d<=${args[0]}; d++ ))
	do
		mv $directory/${args[$c]}"_"$d"/namd/step6_production.dcd" $directory/download-files/${args[$c]}"_"$d"_step6_production.dcd"
	done
done

exit




