#!/bin/bash

mkdir ./singtmp

SINGULARITY_CACHEDIR=./singtmp SINGULARITY_TMPDIR=./singtmp sudo singularity build deepcam.sif deepcam.def

sudo rm -rf singtmp
