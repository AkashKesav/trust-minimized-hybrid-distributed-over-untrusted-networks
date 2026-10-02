#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --account=iitm
#SBATCH --job-name=paper_d5k2_smoke
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:2
#SBATCH --mem=120G
#SBATCH --time=00:45:00
#SBATCH --output=/scratch/mm24r002/paper_rerun_20260815/logs/day5_k2_smoke_%j.out
#SBATCH --error=/scratch/mm24r002/paper_rerun_20260815/logs/day5_k2_smoke_%j.err

set -euo pipefail

RUN_ROOT=/scratch/mm24r002/paper_rerun_20260815
PYTHON_BIN=/home/apps/MLDL/DL-CondaPy3/envs/Pytorch-gpu/bin/python
RUNNER=${RUN_ROOT}/env/dgx_a100_rerun.py
VALIDATOR=${RUN_ROOT}/env/validate_results.py

test -x "${PYTHON_BIN}"
test -f "${RUNNER}"
test -f "${VALIDATOR}"

export PYTHONNOUSERSITE=1
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export CUBLAS_WORKSPACE_CONFIG=:4096:8
export PAPER_SMOKE_TEST=1
export PAPER_OUTPUT_ROOT="${RUN_ROOT}/results/full"
export PAPER_OUTPUT_ROOT_SMOKE="${RUN_ROOT}/results/day5_smoke"
export PAPER_DATA_ROOT="${RUN_ROOT}/data"
export MASTER_ADDR
MASTER_ADDR=$(scontrol show hostnames "${SLURM_JOB_NODELIST}" | head -n 1)
export MASTER_PORT=$((20000 + SLURM_JOB_ID % 10000))
export NCCL_DEBUG=INFO

srun --ntasks=2 --ntasks-per-node=2 --gpus-per-task=1 --gpu-bind=closest \
    "${PYTHON_BIN}" "${RUNNER}" --task day5 --shards 2 --seed 42
"${PYTHON_BIN}" "${VALIDATOR}" "${RUN_ROOT}/results/day5_smoke" --mode day5-smoke --write-report

echo "day5_k2_smoke_complete=true"
