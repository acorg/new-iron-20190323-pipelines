# IMPORTANT: All (relative) paths in this file are relative to the scripts
# in 00-start, etc. This file is sourced by those scripts.

logDir=../logs

if [ ! -d $logDir ]
then
    echo "  Log directory '$logDir' does not exist." >&2
    exit 1
fi

log=$logDir/common.sh.stderr

root=/rds/project/djs200/rds-djs200-acorg/bt/root

if [ ! -d $root ]
then
    echo "  Root directory '$root' does not exist." >> $log
    exit 1
fi

activate=$root/share/virtualenvs/365/bin/activate

if [ ! -f $activate ]
then
    echo "  Virtualenv activation script '$activate' does not exist." >> $log
    exit 1
fi

. $activate

doneFile=../slurm-pipeline.done
runningFile=../slurm-pipeline.running
errorFile=../slurm-pipeline.error
sampleLogFile=$logDir/sample.log

# A simple way to set defaults for our SP_* variables, without causing
# problems by using test when set -e is active (causing scripts to exit
# with status 1 and no explanation).
echo ${SP_SIMULATE:=0} ${SP_SKIP:=0} ${SP_FORCE:=0} >/dev/null

function stepName()
{
    # The step name is the basename of our parent directory.
    # E.g., 03-bwa-mem.
    echo $(basename $(/bin/pwd))
}

function sampleName()
{
    # The sample name is the basename of the directory name of our parent.
    # E.g., NEO999.
    echo $(basename $(dirname $(/bin/pwd)))
}

function logStepStart()
{
    # Pass a log file name.
    case $# in
        1) echo "$(stepName) (SLURM job $SLURM_JOB_ID) started at $(date) on $(hostname)." >> $1;;
        *) echo "logStepStart must be called with 2 arguments." >&2;;
    esac
}

function logStepStop()
{
    # Pass a log file name.
    case $# in
        1) echo "$(basename $(pwd)) (SLURM job $SLURM_JOB_ID) stopped at $(date)" >> $1; echo >> $1;;
        *) echo "logStepStop must be called with 2 arguments." >&2;;
    esac
}

function logTaskToSlurmOutput()
{
    local task=$1
    local log=$2

    # The following will appear in the slurm-*.out (because we don't
    # redirect it to $log). This is useful if there is an error that only
    # appears in the SLURM output, file because it tells us what sample log
    # file to go look at, to re-run, etc.
    echo "Task $task (SLURM job $SLURM_JOB_ID) started at $(date)"
    echo "Task log file is $log"
}

function rmFileAndLink()
{
    for file in "$@"
    do
        if [ -L $file ]
        then
            rm -f $(readlink $file)
        fi
        rm -f $file
    done
}
