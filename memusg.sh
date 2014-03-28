# memusg version 1.0
# Copyright (c) 2014 KAUST All Rights Reserved.
# Author: Amin Allam
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.


# This script will compute peak memory usage of all processes running by a specific user
# To use this script, execute it before the launch of all processes you need to compute their peak memory usage
# The peak memory usage of each process will be save in a file inside the folder ./memusg
# The file name will be: processName_processId_processStartTime
# The file will contain two lines: first line contains memory usage in MBs, second line contains parent process ID, and the command which launched the process
# The script takes 5 parameters:
#   1) Time interval (in seconds) between consecutive checks
#   2) Minimum memory (in MBs) size to track (avoid tracking any process whose memory peak does not exceed this value)
#   3) Flag to empty the ./memusg folder before starting ("clean" or "noclean")
#   4) User name whose owned processes need to be tracked (or "all" if you need to track all users)
#   5) The name of the tracked process (or "all" if you need to track all processes)
# The script is tested on both linux and mac
# Example usage (track all processes with > 20 MBs peak memory of user "aminallam" every 10 seconds):
#    bash ./memusg.sh 10 20 clean aminallam all


MEMUSGDIR="./memusg"

if [ "$3" == "clean" ]
then
	rm -R "${MEMUSGDIR}" 2>/dev/null
	echo cleaned
fi

mkdir memusg 2>/dev/null

while [ true ]
do

echo -n .

stline=0

IFS=$'\r\n'
if [ -n "$5" -a "$5" != all ]; then
	if [ -n "$4" -a "$4" != all ]; then
		all_lines=($(ps xco pid,lstart,rss,command -ww -U "$4" | grep "$5"))
	else
		all_lines=($(ps xco pid,lstart,rss,command -ww | grep "$5"))
	fi
else
	stline=1
	if [ -n "$4" -a "$4" != all ]; then
		all_lines=($(ps xco pid,lstart,rss,command -ww -U "$4"))
	else
		all_lines=($(ps xco pid,lstart,rss,command -ww))
	fi
fi


unset IFS
for i in "${!all_lines[@]}"
do
if [ $i -ge ${stline} ]; then
	read -a cur_values <<<"${all_lines[$i]}"
	if [ "${cur_values[4]}" != "ps" -a "${cur_values[4]}" != "bash" ]
	then
		process_id="${cur_values[0]//[^a-zA-Z0-9]/-}"
		process_start="${cur_values[2]//[^a-zA-Z0-9]/-}-${cur_values[3]//[^a-zA-Z0-9]/-}-${cur_values[4]//[^a-zA-Z0-9]/-}"
		cur_mem_usage="${cur_values[6]}"
		process_name="${cur_values[7]//[^a-zA-Z0-9]/-}"
		num_cur_vals="${#cur_values[@]}"
		j=8
		while [ $j -lt "${num_cur_vals}" ]
		do
			process_name="${process_name}-${cur_values[$j]//[^a-zA-Z0-9]/-}"
			j=$(( $j + 1 ))
		done
		file_name="${process_name}_${process_id}_${process_start}.txt"
		cur_mem_usage=$(( ${cur_mem_usage} / 1024 ))
		max_mem_usage="$2"
		if [ ${cur_mem_usage} -gt ${max_mem_usage} ]
		then
			file_path="${MEMUSGDIR}/${file_name}"
			if [ -f "${file_path}" ]
			then
				max_mem_usage=$(head -1 "${file_path}")
			fi
			if [ ${cur_mem_usage} -gt ${max_mem_usage} ]
			then
				echo "$cur_mem_usage" > "${file_path}"
				echo "$(ps o ppid,command -ww -p ${process_id} | sed 1d)" >> "${file_path}"
			fi
		fi
	fi
fi
done

sleep $1

done
