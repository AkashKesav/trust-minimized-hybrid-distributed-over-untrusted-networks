#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --account=iitm
#SBATCH --job-name=paper_d5probe
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
#SBATCH --time=00:15:00
#SBATCH --output=/scratch/mm24r002/paper_rerun_20260815/logs/day5_probe_%j.out
#SBATCH --error=/scratch/mm24r002/paper_rerun_20260815/logs/day5_probe_%j.err

set -euo pipefail
RUN_ROOT=/scratch/mm24r002/paper_rerun_20260815
PYTHON_BIN=/home/apps/MLDL/DL-CondaPy3/envs/Pytorch-gpu/bin/python
export PYTHONNOUSERSITE=1
export CUBLAS_WORKSPACE_CONFIG=:4096:8
"$PYTHON_BIN" "$RUN_ROOT/env/day5_pipeline_probe.py"
echo "probe_complete=true"
