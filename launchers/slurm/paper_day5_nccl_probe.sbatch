#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --account=iitm
#SBATCH --job-name=paper_d5nccl
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:2
#SBATCH --mem=64G
#SBATCH --time=00:20:00
#SBATCH --output=/scratch/mm24r002/paper_rerun_20260815/logs/day5_nccl_probe_%j.out
#SBATCH --error=/scratch/mm24r002/paper_rerun_20260815/logs/day5_nccl_probe_%j.err

set -euo pipefail
RUN_ROOT=/scratch/mm24r002/paper_rerun_20260815
PYTHON_BIN=/home/apps/MLDL/DL-CondaPy3/envs/Pytorch-gpu/bin/python
export PYTHONNOUSERSITE=1
export CUBLAS_WORKSPACE_CONFIG=:4096:8
export MASTER_ADDR
MASTER_ADDR=$(scontrol show hostnames "${SLURM_JOB_NODELIST}" | head -n 1)
export MASTER_PORT=$((21000 + SLURM_JOB_ID % 10000))
export NCCL_DEBUG=INFO
srun --ntasks=2 --ntasks-per-node=2 --gpus-per-task=1 --gpu-bind=closest \
    "${PYTHON_BIN}" "${RUN_ROOT}/env/day5_nccl_forward_probe.py"
echo "nccl_probe_complete=true"
