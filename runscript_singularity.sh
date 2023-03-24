#!/bin/bash

#SBATCH -J deepcam
#SBATCH -N 5
#SBATCH -p grete
#SBATCH -G 20
#SBATCH -c 12
#SBATCH --mem=400G
#SBATCH --gpus-per-task=1
#SBATCH --ntasks-per-node=4
#SBATCH -t 12:00:00

module load cuda
module load gcc/9.3.0 openmpi/gcc.9/4.1.1-cuda.11.2
module load singularity

totalranks="$(( $SLURM_NNODES * $SLURM_NTASKS_PER_NODE ))"
local_batch_size=2

run_tag="test_run_nranks-${totalranks}"

mounts="./data:/data/data,./output:/data/output,$PWD:/runscripts,./tmpdir:/tmp"

# ncu -f -o ncprof --set full --target-processes all python \
# nsys profile --force-overwrite true  -o /runscripts/timeline --trace cuda,nvtx,osrt,openacc python \

srun --mpi=pmi2  -n ${totalranks} \
  singularity run --nv --env="TMPDIR=/tmp" -B $mounts --pwd=/runscripts deepcam.sif \
    python \
    ./train.py \
    --wireup_method "nccl-slurm-pmi" \
    --run_tag ${run_tag} \
    --data_dir_prefix ${mnt_data_dir} \
    --output_dir ${mnt_output_dir} \
    --model_prefix "segmentation" \
    --optimizer "Adam" \
    --start_lr 0.0055 \
    --lr_schedule type="multistep",milestones="64",decay_rate="0.1" \
    --lr_warmup_steps 10 \
    --lr_warmup_factor 1. \
    --weight_decay 1e-2 \
    --logging_frequency 10 \
    --save_frequency 0 \
    --max_epochs 3 \
    --max_inter_threads 4 \
    --seed $(date +%s) \
    --batchnorm_group_size 1 \
    --local_batch_size ${local_batch_size}
