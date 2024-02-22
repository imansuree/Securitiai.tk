#!/bin/bash

log_path="/mnt/monitor.log"

touch $log_path

echo $'Time:  ' >> $log_path
echo `date` >> $log_path

echo $'TEST DISK##########\n' >> $log_path

df -lh >> $log_path

echo $'TEST DISK-IO tmp##########\n' >> $log_path

dd if=/dev/zero of=/tmp/output conv=fdatasync bs=350k count=1k 2>>$log_path

echo $'TEST DISK-IO root##########\n' >> $log_path

dd if=/dev/zero of=/output conv=fdatasync bs=350k count=1k 2>>$log_path

rm /tmp/output
rm /output

echo $'TEST USAGE##########\n' >> $log_path

top -b | awk 'FNR>=7 && FNR<=15;FNR==15{exit}' >> $log_path

echo $'TEST USAGE MEM sorted##########\n' >> $log_path

top -b -o %MEM| awk 'FNR>=7 && FNR<=15;FNR==15{exit}'

echo $'TEST KUBERNETES USAGE##########\n' >> $log_path

kubectl top nodes >> $log_path

echo $'TEST KUBERNETES POD USAGE##########\n' >> $log_path

kubectl top pods -A >> $log_path

echo $'TEST CLUSTER HEALTH##########\n' >> $log_path

kubectl get cs >> $log_path

echo $'TEST GRAVITY STATUS##########\n' >> $log_path

gravity status >> $log_path

process_name="kube-apiserver"

# Define the memory usage threshold (in percentage)
threshold=10

pid=$(pgrep -x "$process_name")

if [ -n "$pid" ]; then
  mem_usage=$(ps -p "$pid" -o %mem | awk 'NR==2 {print $1}')

  # Check if memory usage exceeds the threshold
  if (( $(awk 'BEGIN {print ('$mem_usage' > '$threshold')}') )); then
    echo "Memory usage of $process_name exceeds $threshold% ($mem_usage%)"
    echo "Killing the process with PID $pid"
    kill -9 "$pid"
  else
    echo "Memory usage of $process_name is within acceptable limits ($mem_usage%)"
  fi
else
  echo "Process $process_name not found"
fi
