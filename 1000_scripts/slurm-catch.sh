#!/bin/bash -l

##this will loop as long as jobs exist named $1 (command line input). it is most useful when pasted into a script in which the user is sending batch runs to slurm, but wants to pause and wait for slurm to finish before continuing

x=1
while [ $x -gt 0 ] 
do
sleep 1m
echo "."
x=$(smap -c | grep $1 | wc -l)
done
