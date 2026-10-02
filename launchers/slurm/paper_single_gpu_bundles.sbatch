#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --account=iitm
#SBATCH --job-name=paper_bundle
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=64G
#SBATCH --time=2-00:00:00
#SBATCH --array=0-7%8
#SBATCH --requeue
#SBATCH --output=/scratch/mm24r002/paper_rerun_20260815/logs/bundle_%A_%a.out
#SBATCH --error=/scratch/mm24r002/paper_rerun_20260815/logs/bundle_%A_%a.err

set -euo pipefail

RUN_ROOT=/scratch/mm24r002/paper_rerun_20260815
PYTHON_BIN=/home/apps/MLDL/DL-CondaPy3/envs/Pytorch-gpu/bin/python
RUNNER=${RUN_ROOT}/env/dgx_a100_rerun.py

test -x "${PYTHON_BIN}"
test -f "${RUNNER}"
mkdir -p "${RUN_ROOT}/results/full" "${RUN_ROOT}/data"

export PYTHONNOUSERSITE=1
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export CUBLAS_WORKSPACE_CONFIG=:4096:8
export PAPER_SMOKE_TEST=0
export PAPER_RUN_DAYS=1,2,3,4,6,7,10
export PAPER_OUTPUT_ROOT="${RUN_ROOT}/results/full"
export PAPER_DATA_ROOT="${RUN_ROOT}/data"

echo "timestamp=$(date --iso-8601=seconds)"
echo "hostname=$(hostname)"
echo "job_id=${SLURM_JOB_ID} array_task=${SLURM_ARRAY_TASK_ID}"
nvidia-smi --query-gpu=index,name,memory.total,driver_version --format=csv,noheader

"${PYTHON_BIN}" "${RUNNER}" \
    --task bundle \
    --bundle-index "${SLURM_ARRAY_TASK_ID}" \
    --bundle-count 8

echo "bundle_complete=true"
