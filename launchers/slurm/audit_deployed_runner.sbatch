#!/bin/bash
#SBATCH --partition=standard
#SBATCH --account=iitm
#SBATCH --job-name=paper_audit
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=12G
#SBATCH --time=00:10:00
#SBATCH --output=/scratch/mm24r002/paper_rerun_20260815/logs/runner_audit_%j.out
#SBATCH --error=/scratch/mm24r002/paper_rerun_20260815/logs/runner_audit_%j.err

set -euo pipefail

RUN_ROOT=/scratch/mm24r002/paper_rerun_20260815
PYTHON_BIN=/home/apps/MLDL/DL-CondaPy3/envs/Pytorch-gpu/bin/python

export PYTHONNOUSERSITE=1
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export PAPER_SMOKE_TEST=0
export PAPER_DATA_ROOT="${RUN_ROOT}/data"
export PAPER_OUTPUT_ROOT="${RUN_ROOT}/diagnostics/runner_import"

"${PYTHON_BIN}" "${RUN_ROOT}/diagnostics/audit_deployed_runner.py" \
  "${RUN_ROOT}/env/dgx_a100_rerun.py" \
  --output "${RUN_ROOT}/diagnostics/deployed_runner_audit.json"
echo "deployed_runner_audit_complete=true"
