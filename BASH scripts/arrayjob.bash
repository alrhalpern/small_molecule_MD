#!/bin/bash -l
# This top line ^ lets the system know it's running in the language "bash"


# These next few lines request resources from the cluster. Change them if you need to, but if you ask for too much the cluster will reject your job.

# Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=48:00:00


# Request 1 gigabyte of RAM (must be an integer followed by M, G, or T)
#$ -l mem=1G


# Request 15 gigabyte of TMPDIR space (default is 10 GB - remove if cluster is diskless)
#$ -l tmpfs=15G

#                                                          SET NAME!!!!!!!!!!!!!!!!!
#$ -N lserupu

#$ -pe mpi 2


#                                                              SET DIRECTORY!!!!!!!!!!!!!!!!!
# Set the working directory to somewhere in your scratch space.
# Replace "<your_UCL_id>" with your UCL user ID :)
#$ -wd /home/zcqshal/Scratch/Dimers

echo "step 1"
#                                                          SET NAME/DIRECTORY!!!!!!!!!!!!!!!!!
jobname="L-Ser-UpU"
directory="Dimers"


echo "step 2"


#                                                          
cd /home/zcqshal/Scratch/$directory/$jobname/namd


echo "step 3"

# Run the program (replace echo with your binary and options).
#echo "$index" "$variable1" "$variable2" "$variable3"

module load fftw/2.1.5/intel-2015-update2
module load namd/2.10/intel-2015-update2

echo "step 4"

#                                                         
gerun namd2 /home/zcqshal/Scratch/$directory/$jobname/namd/step5_equilibration.inp

echo "step 5"

#                                                          
cd /home/zcqshal/Scratch/$directory/
#                                                           SET JOB NUMBERS!!!!!
gerun /home/zcqshal/Scratch/$directory/practicescript.bash $jobname 100 5000 15000000

echo "practicescript complete"

exit
