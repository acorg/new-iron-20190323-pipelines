#!/bin/bash -e

. ../common.sh

task=$1
sample=$(sampleName)
log=$logDir/$task.log
fastq=$dataDir/$task
out=$sample-hbv.fastq.gz

logStepStart $log
logTaskToSlurmOutput $task $log
checkFastq $fastq $log

function skip()
{
    # Copy our input FASTQ to our output unchanged.
    cp $fastq $out
}

function map()
{
    # Map against the HBV database using bwa aln.

    nproc=$(nproc --all)
    rmFileAndLink $out $sample.sai

    echo "  bwa aln -l started at `date`" >> $log
    zcat $fastq | bwa aln -l 1000 -t $(( $nproc - 1 )) $BWA_DB - 2>$sample.stderr > $sample.sai
    echo "  bwa aln -l stopped at `date`" >> $log

    echo "  bwa samse started at `date`" >> $log
    bwa samse $BWA_DB $sample.sai $fastq 2>>$sample.stderr | samtools fastq -F 1028 - | gzip > $out
    echo "  bwa samse stopped at `date`" >> $log

    rm $sample.sai
}


if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  $(stepName) is being skipped on this run." >> $log
        skip
    elif [ -f $out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output file $out exists, but --force was used. Overwriting." >> $log
            map
        else
            echo "  Will not overwrite pre-existing output file $out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output file $out does not exist." >> $log
        map
    fi
fi

logStepStop $log
