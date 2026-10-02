#!/bin/bash
#SBATCH --partition=standard
#SBATCH --account=iitm
#SBATCH --job-name=paper_d6inspect
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:10:00
#SBATCH --output=/scratch/mm24r002/paper_rerun_20260815/logs/day6_inspect_%j.out
#SBATCH --error=/scratch/mm24r002/paper_rerun_20260815/logs/day6_inspect_%j.err

set -euo pipefail

RUN_ROOT=/scratch/mm24r002/paper_rerun_20260815
PYTHON_BIN=/home/apps/MLDL/DL-CondaPy3/envs/Pytorch-gpu/bin/python

export PYTHONNOUSERSITE=1
export PAPER_SMOKE_TEST=1
export PAPER_DATA_ROOT="${RUN_ROOT}/data"
export PAPER_OUTPUT_ROOT_SMOKE="${RUN_ROOT}/diagnostics/import_scratch"
"${PYTHON_BIN}" "${RUN_ROOT}/diagnostics/inspect_day6_checkpoint.py" \
  "${RUN_ROOT}/diagnostics/day6_zero_activation_activation_norm_seed42_latest.pt" \
  --runner "${RUN_ROOT}/env/dgx_a100_rerun.py"
echo "day6_checkpoint_inspection_complete=true"
