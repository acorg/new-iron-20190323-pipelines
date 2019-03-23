# New Iron Age, HBV bwa pipeline spec

This repo contains a
[slurm-pipeline](https://github.com/acorg/slurm-pipeline) specification
file (`specification.json`) and associated scripts for processing the new iron
age data from March 2019, using bwa, against a hbv database.

## Pipeline steps

* `00-start`: Logging. Find input FASTQ files for a sample, check they
  exist, issue a task for each.
* `01-bwa-aln`: Map reads to HBV references using `bwa aln`.
* `02-bwa-aln-l`: Map reads to HBV references using `bwa aln -l`.
* `03-bwa-mem`: Map reads to HBV references using `bwa mem`.
* `04-collect`: Collect the matching reads from the three bwa runs.
* `05-stop`: Logging. Create `slurm-pipeline.done` in top-level dir.
* `06-error`: Run if an error occurs in earlier steps. Does some cleaning up.

## Output

The scripts in `00-start`, etc. are all submitted by `sbatch` for execution
under [SLURM](http://slurm.schedmd.com/). The final step, `04-collect` leaves
its output in `04-collect`.
