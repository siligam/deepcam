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

https://pad.gwdg.de/o1JKVQthTXeflUt_VnjBPA

or on glogin9 copy source data from here:
/scratch/usr/gzfbpks/deepcam/data

create the following directories inside the cloned repository (i.e., deepcam)

```
mkdir input output tmpdir
```

`copy` or `move` the source data into `input` directory.


3. run script

submit the provided run script to slurm run the benchmark. 

### Hyperparameters
The table below contains the modifiable hyperparameters. Unless otherwise stated, parameters not listed in the table below are fixed and changing those could lead to an invalid submission.

Parameter Name	| Default	| Constraints	| Description
| --- | --- | --------- | -------- |
--optimizer	| "Adam"	| Optimizer of Adam or LAMB* type. This benchmark implements "Adam" and "AdamW" from PyTorch as well as "FusedLAMB" from NVIDIA APEX. Algorithmic equivalent implementations to those listed before are allowed. |	The optimizer to choose
--start_lr	|	1e-3	| >= 0.	|	Start learning rate (or base learning rate if warmup is used)
--optimizer_betas	|	[0.9, 0.999]	|	N/A		| Momentum terms for Adam-type optimizers
--weight_decay	|	1e-6		| >= 0.		| L2 weight regularization term
--lr_warmup_steps	|	0		| >= 0	|	Number of steps for learning rate warmup
--lr_warmup_factor	|	1.		| >= 1. 	|	When warmup is used, the target learning_rate will be lr_warmup_factor * start_lr
--lr_schedule	|	-		|type="multistep",milestones="<milestone_list>",decay_rate="<value>" or type="cosine_annealing",t_max="<value>",eta_min="<value>"		|Specifies the learning rate schedule. Multistep decays the current learning rate by decay_rate at every milestone in the list. Note that the milestones are in unit of steps, not epochs. Number and value of milestones and the decay_rate can be chosen arbitrarily. For a milestone list, please specify it as whitespace separated values, for example milestones="5000 10000". For cosine annealing, the minimal lr is given by the value of eta_min and the period length in number of steps by T_max
--batchnorm_group_size	|	1		|>= 1		|Determines how many ranks participate in the batchnorm. Specifying a value > 1 will replace nn.BatchNorm2d with nn.SyncBatchNorm everywhere in the model. Currently, nn.SyncBatchNorm only supports node-local batch normalization, but using an Implementation of that same functionality which span arbitrary number of workers is allowed
--gradient_accumulation_frequency 	|	1	|	>= 1		|Specifies the number of gradient accumulation steps before a weight update is performed
--seed	|		|333		|> 0		|Random number generator seed. Multiple submissions which employ the same seed are forbidden. Please specify a seed depending on system clock or similar.

**Note**:  the command line arguments do not directly correspond to logging entries. For compliance checking of oiutput logs, use the table below:

|Key	| Constraints |	Required
| --- | --- | ---|
seed	|	x > 0	|	True
global_batch_size	|	x > 0		|True
num_workers	|	x > 0	|	True
batchnorm_group_size	|	x > 0	|	False
gradient_accumulation_frequency	|	x >= 1	|	True
opt_name	|	x in ["Adam", "AdamW", "LAMB"]	|	True
opt_lr	|	x >= 0.		|True
opt_betas	|	unconstrained	|	True
opt_eps	|	x == 1e-6	|	True
opt_weight_decay	|	x >= 0.	|	True
opt_bias_correction	|	x == True		|True if opt_name == "LAMB" else False
opt_grad_averaging		|x == True		|True if opt_name == "LAMB" else False
opt_max_grad_norm	|	x == 1.0	|	True if opt_name == "LAMB" else False
scheduler_type	|	x in ["multistep", "cosine_annealing"]	|	True
scheduler_milestones	| unconstrained		|True if scheduler_type == "multistep" else False
scheduler_decay_rate	|	x <= 1.	|	True if scheduler_type == "multistep" else False
scheduler_t_max	|	x >= 0	|	True if scheduler_type == "cosine_annealing" else False
scheduler_eta_min	|	x >= 0.	|	True if scheduler_type == "cosine_annealing" else False
scheduler_lr_warmup_steps	|	x >= 0	|	False
scheduler_lr_warmup_factor	|	x >= 1.	|	True if scheduler_lr_warmup_steps > 0 else False

The first column lists the keys as they would appear in the logfile. The second column lists the parameters constraints as an equation for parameter variable x. Those can be used to generate lambda expressions in Python. The third one if the corresponding entry has to be in the log file or not. Since there are multiple optimizers and learning rate schedules to choose from, not all parameters need to be logged for a given run. This is expressed by conditional expressions in that column. Please note that besides the benchmark specific rules above, standard MLPerf HPC logging rules apply.
