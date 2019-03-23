# New Iron Age, HBV collector pipeline

This repo contains a
[slurm-pipeline](https://github.com/acorg/slurm-pipeline) specification
file (`specification.json`) and associated scripts for collecting the reads
mapping against hbv using DIAMOND and bwa.

## Pipeline steps

* `00-start`: Logging. Find input FASTQ files for a sample, check they
  exist, issue a task for each.
* `01-collect`: Collects the reads mapping against HBV using DIAMOND and bwa.
* `02-stop`: Logging. Create `slurm-pipeline.done` in top-level dir.
* `03-error`: Run if an error occurs in earlier steps. Does some cleaning up.

## Output

The scripts in `00-start`, etc. are all submitted by `sbatch` for execution
under [SLURM](http://slurm.schedmd.com/). The step `01-collect` leaves
its output in `01-collect`. It makes two output files, one where the reads are
de-duplicated by sequence id, and one where the reads are de-duplicated by
sequence.
