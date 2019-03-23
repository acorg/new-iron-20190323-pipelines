#!/bin/bash -e

. ../common.sh

# We cannot initially write to a log file because the log directory may not
# exist yet. So write initial errors to stderr.

# Remove the top-level logging directory (with a sanity check on its name).
if [ ! "$logDir" = ../logs ]
then
    # SLURM will catch this output and put it into slurm-N.out where N is
    # out job id.
    echo "$0: logDir variable has unexpected value '$logDir'!" >&2
    exit 1
fi

rm -fr $logDir

mkdir $logDir || {
    # SLURM will catch this output and put it into slurm-N.out where N is
    # out job id.
    echo "$0: Could not create log directory '$logDir'!" >&2
    exit 1
}

# From here on we can write errors to a log file.

log=$sampleLogFile
logStepStart $log

# Remove the marker files that indicate when a job is fully complete or
# that there has been an error and touch the file that shows we're running.
rm -f $doneFile $errorFile
touch $runningFile

echo "  Removing all old slurm-*.out files." >> $log
rm -f ../*/slurm-*.out

tasks=$(tasksForSample)

for task in $tasks
do
    fastq=$dataDir/$task
    checkFastq $fastq $log
    echo "  task $task, FASTQ $fastq" >> $log
done

# Make sure the basenames of the task files are unique. Else the various
# pipeline steps will overwrite files.
TMP=$(mktemp)
for task in $tasks
do
    echo $(basename $task)
done > $TMP
count1=$(wc -l < $TMP)
count2=$(sort -u < $TMP | wc -l)
if [ $count1 -ne $count2 ]
then
    echo "  WARNING! Basenames of task files (below) are not unique. Cannot continue." >>$log
    cat $TMP >> $log
    rm $TMP
    exit 1
fi
rm $TMP


for task in $tasks
do
    # Emit task names (without job ids as this step does not start any
    # SLURM jobs).
    echo "TASK: $task"
done

logStepStop $log
