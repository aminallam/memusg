memusg
======

Compute peak memory usage for Linux/Mac running processes

This script will compute peak memory usage of all processes running by a specific user
To use this script, execute it before the launch of all processes you need to compute their peak memory usage
The peak memory usage of each process will be save in a file inside the folder ./memusg
The file name will be: processName_processId_processStartTime
The file will contain two lines: first line contains memory usage in MBs, second line contains parent process ID, and the command which launched the process

The script takes 4 parameters:
   1) Time interval (in seconds) between consecutive checks
   2) Minimum memory (in MBs) size to track (avoid tracking any process whose memory peak does not exceed this value)
   3) Flag to empty the ./memusg folder before starting ("clean" or "noclean")
   4) User name whose owned processes need to be tracked
The script is tested on both linux and mac
Example usage: bash ./memusg.sh 30 30 clean aminallam
