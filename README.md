# Deepcam benchmark 
Deepcam benchmark from Mlcommons HPC benchmark is restructured in this repository so that it can be run via singularity.
The original benchmark can be found here: https://github.com/mlcommons/hpc.

## workflow

1. Building the software stack

For the software stack, run the `make_singularity.sh` script (requires root previlages) 

```
git clone https://github.com/siligam/deepcam.git
cd deepcam
bash make_singularity.sh
```

2. Getting the pre-requisit data for the benchmark

Getting from the original source as explained in the following pad

https://pad.gwdg.de/Zr_gp75DQC2kLbNs-0hTYg?view

or on glogin9 copy data from here:
/scratch/usr/gzfbpks/deepcam/data

3. run script

submit the provided run script to slurm run the benchmark. 
