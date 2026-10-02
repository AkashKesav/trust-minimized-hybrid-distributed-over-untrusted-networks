#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --account=iitm
#SBATCH --job-name=paper_smoke
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
#SBATCH --time=00:45:00
#SBATCH --output=/scratch/mm24r002/paper_rerun_20260815/logs/smoke_%j.out
#SBATCH --error=/scratch/mm24r002/paper_rerun_20260815/logs/smoke_%j.err

set -euo pipefail

RUN_ROOT=/scratch/mm24r002/paper_rerun_20260815
PYTHON_BIN=/home/apps/MLDL/DL-CondaPy3/envs/Pytorch-gpu/bin/python
RUNNER=${RUN_ROOT}/env/dgx_a100_rerun.py
VALIDATOR=${RUN_ROOT}/env/validate_results.py

test -x "${PYTHON_BIN}"
test -f "${RUNNER}"
test -f "${VALIDATOR}"
mkdir -p "${RUN_ROOT}/results/smoke" "${RUN_ROOT}/data"

export PYTHONNOUSERSITE=1
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export CUBLAS_WORKSPACE_CONFIG=:4096:8
export PAPER_SMOKE_TEST=1
export PAPER_OUTPUT_ROOT="${RUN_ROOT}/results/full"
export PAPER_OUTPUT_ROOT_SMOKE="${RUN_ROOT}/results/smoke"
export PAPER_DATA_ROOT="${RUN_ROOT}/data"

echo "timestamp=$(date --iso-8601=seconds)"
echo "hostname=$(hostname)"
echo "job_id=${SLURM_JOB_ID}"
nvidia-smi --query-gpu=index,name,memory.total,driver_version --format=csv,noheader

"${PYTHON_BIN}" "${RUNNER}" --task smoke
"${PYTHON_BIN}" "${VALIDATOR}" "${RUN_ROOT}/results/smoke" --mode smoke --write-report

echo "smoke_complete=true"
