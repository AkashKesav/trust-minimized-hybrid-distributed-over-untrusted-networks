#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --account=iitm
#SBATCH --job-name=paper_probe
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --mem=16G
#SBATCH --time=00:10:00
#SBATCH --output=/scratch/mm24r002/paper_rerun_20260815/logs/probe_%j.out
#SBATCH --error=/scratch/mm24r002/paper_rerun_20260815/logs/probe_%j.err

set -euo pipefail

echo "timestamp=$(date --iso-8601=seconds)"
echo "hostname=$(hostname)"
echo "job_id=${SLURM_JOB_ID}"
echo "cuda_visible_devices=${CUDA_VISIBLE_DEVICES:-unset}"

nvidia-smi -L
nvidia-smi --query-gpu=index,name,memory.total,driver_version,pstate --format=csv,noheader
nvidia-smi topo -m

PYTHON_BIN=/home/apps/MLDL/DL-CondaPy3/envs/Pytorch-gpu/bin/python
if [[ ! -x "$PYTHON_BIN" ]]; then
    echo "Missing expected Python: $PYTHON_BIN" >&2
    exit 2
fi

"$PYTHON_BIN" - <<'PY'
import importlib
import json
import platform
import sys

modules = {}
for name in ("torch", "torchvision", "numpy", "pandas", "sklearn", "matplotlib", "joblib"):
    try:
        module = importlib.import_module(name)
        modules[name] = getattr(module, "__version__", "unknown")
    except Exception as exc:
        modules[name] = f"ERROR: {type(exc).__name__}: {exc}"

import torch

report = {
    "python": sys.version,
    "platform": platform.platform(),
    "modules": modules,
    "torch_cuda_runtime": torch.version.cuda,
    "cudnn": torch.backends.cudnn.version(),
    "cuda_available": torch.cuda.is_available(),
    "cuda_device_count": torch.cuda.device_count(),
    "nccl_available": torch.distributed.is_nccl_available(),
}
if torch.cuda.is_available():
    report["devices"] = [
        {
            "index": i,
            "name": torch.cuda.get_device_name(i),
            "capability": torch.cuda.get_device_capability(i),
            "memory_bytes": torch.cuda.get_device_properties(i).total_memory,
        }
        for i in range(torch.cuda.device_count())
    ]
    left = torch.randn((1024, 1024), device="cuda")
    right = torch.randn((1024, 1024), device="cuda")
    product = left @ right
    torch.cuda.synchronize()
    report["cuda_smoke_checksum"] = float(product[0, 0])

print(json.dumps(report, indent=2, default=str))
if not report["cuda_available"] or report["cuda_device_count"] != 1:
    raise SystemExit("Probe did not receive exactly one CUDA device")
PY

df -h /scratch /home
echo "probe_complete=true"
