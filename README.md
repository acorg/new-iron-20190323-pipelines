# New Iron Age pipelines

This repo contains three
[slurm-pipeline](https://github.com/acorg/slurm-pipeline) specification
files (`specification.json`) and associated scripts for processing the new iron
age data from March 2019.

The three pipelines run DIAMOND against the refseq database (`new-iron-20190323-refseq-diamond`), bwa against the hbv database (`new-iron-20190323-hbv-bwa`), and collects the output (`new-iron-20190323-hbv-collector`).
