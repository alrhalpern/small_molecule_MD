#!/bin/bash -l



# Batch script to run an array job.

# Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=48:00:00


# Request 1 gigabyte of RAM (must be an integer followed by M, G, or T)
#$ -l mem=1G


# Request 15 gigabyte of TMPDIR space (default is 10 GB - remove if cluster is diskless)
#$ -l tmpfs=15G


# Set up the job array.  In this instance we have requested 1000 tasks
# numbered 1 to 1000.
#$ -t 1-100                                                     
#                                                          SET JOB NUMBERS!!!!!!!!

#                                                          SET NAME!!!!!!!!!!!!!!!!!
#$ -N lserupu

#$ -pe mpi 2

#                                                          SET DIRECTORY!!!!!!!!!!!!!!!!!
# Replace "<your_UCL_id>" with your UCL user ID :)
#$ -wd /home/zcqshal/Scratch/Dimers

echo "step 1"
#                                                          SET NAME!!!!!!!!!!!!!!!!!
directory="Dimers"
jobname="L-Ser-UpU"

echo "step 2"

#                                                          SET DIRECTORY!!!!!!!!!!!!!!!!!
cd /home/zcqshal/Scratch/$directory/$jobname

echo "step 3"

# Run the program (replace echo with your binary and options).
#echo "$index" "$variable1" "$variable2" "$variable3"

module load fftw/2.1.5/intel-2015-update2
module load namd/2.10/intel-2015-update2

#                                                          SET DIRECTORY!!!!!!!!!!!!!!!!!
# Parse parameter file to get variables.
number=$SGE_TASK_ID
paramfile="/home/zcqshal/Scratch/$directory/"$jobname"_params.txt"

index="`sed -n ${number}p $paramfile | awk '{print $1}'`"
variable1="`sed -n ${number}p $paramfile | awk '{print $2}'`"

sleep  $((10 * $index))
sleep  $((10 * $index))

echo "step 7"

gerun namd2 $variable1

exit
