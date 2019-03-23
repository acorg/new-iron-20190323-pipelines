#!/bin/bash -e

. ../common.sh

log=$sampleLogFile
out=$(sampleName)-hbv.fastq
outBySeq=$(sampleName)-hbv-deduped-by-sequence.fastq

logStepStart $log
logTaskToSlurmOutput collect $log

function skip()
{
    echo "  Skipping at $(date)" >> $log
}

function collect()
{
    # Combine and de-duplicate (by id) FASTQ for HBV for this sample from
    # the DIAMOND and BWA pipelines.

    echo "  FASTQ collection started at $(date)" >> $log

    diamondDir=../../../refseq-diamond
    bwaDir=../../../hbv-bwa

    sample=$(sampleName)
    sampleIndex=$(egrep " $sample\$" $diamondDir/samples.index | cut -f1 -d' ')
    hbvIndex=$(egrep ' Hepatitis B virus$' $diamondDir/pathogens.index | cut -f1 -d' ')
    echo "    Sample $sample index is $sampleIndex" >> $log
    echo "    HBV index is $hbvIndex" >> $log

    countFile=$sample-hbv.read-count
    rmFileAndLink $out $countFile

    fastq=

    f=$diamondDir/$sample/04-panel/out/pathogen-$hbvIndex-sample-$sampleIndex.fastq
    if [ -s $f ]
    then
        echo "    DIAMOND HBV FASTQ for sample $sample found in $f" >> $log
        fastq="$fastq $f"
    else
        echo "    DIAMOND HBV FASTQ for sample $sample file $f does not exist (or is empty)" >> $log
    fi

    f=$bwaDir/$sample/04-collect/$sample-hbv.fastq
    if [ -s $f ]
    then
        echo "    BWA HBV FASTQ for sample $sample found in $f" >> $log
        fastq="$fastq $f"
    else
        echo "    BWA HBV FASTQ for sample $sample file $f does not exist (or is empty)" >> $log
    fi

    if [ -n "$fastq" ]
    then
        echo "    Combining HBV FASTQ for sample $sample" >> $log
        cat $fastq | filter-fasta.py --quiet --removeDuplicatesById --fastq > $out
        cat $fastq | filter-fasta.py --quiet --removeDuplicates --fastq > $outBySeq
        # The following count could have been extracted from the stderr of
        # the previous command if we hadn't used --quiet, but that's a bit
        # ugly and this count will be very quick.
        fasta-count.py --fastq < $out > $countFile
    else
        echo "    No HBV FASTQ for sample $sample" >> $log
    fi

    echo "  FASTQ collection stopped at $(date)" >> $log
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
            collect
        else
            echo "  Will not overwrite pre-existing output file $out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output file $out does not exist." >> $log
        collect
    fi
fi

logStepStop $log
