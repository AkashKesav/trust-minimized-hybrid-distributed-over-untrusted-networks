#!/usr/bin/env bash
set -euo pipefail

# Resumable, checksum-gated deployment for the approved PARAM Shakti rerun.
# Authentication is provided by the dedicated `paramshakti` SSH key alias.

RUN_ROOT=/scratch/mm24r002/paper_rerun_20260815
PYTHON_BIN=/home/apps/MLDL/DL-CondaPy3/envs/Pytorch-gpu/bin/python
LOCAL_BUNDLE=/mnt/e/Paper/paramshakti/upload/paper_rerun_bundle_20260815_corrected_v6.tar.gz
LOCAL_CIFAR=/mnt/e/Paper/kaggle_results/day4_error/data/cifar-10-python.tar.gz
BUNDLE_SHA256=7ABF7EF7E0D3D6288B374FCEC5B50DD53D60DD3CE84F98F05C833B40E312BCBD
CIFAR_SHA256=6D958BE074577803D12ECDEFD02955F39262C83C16FE9348329D7FE0B5C001CE

SSH_OPTIONS=(
    -T
    -o BatchMode=yes
    -o ConnectTimeout=20
    -o ServerAliveInterval=15
    -o ServerAliveCountMax=4
)
SSH=(ssh "${SSH_OPTIONS[@]}" paramshakti)
RSYNC_RSH='ssh -T -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=15 -o ServerAliveCountMax=4'

sha256_local() {
    sha256sum "$1" | awk '{print toupper($1)}'
}

[[ -f "$LOCAL_BUNDLE" ]] || { echo "Missing bundle: $LOCAL_BUNDLE" >&2; exit 2; }
[[ -f "$LOCAL_CIFAR" ]] || { echo "Missing CIFAR-10 archive: $LOCAL_CIFAR" >&2; exit 2; }
[[ "$(sha256_local "$LOCAL_BUNDLE")" == "$BUNDLE_SHA256" ]] || {
    echo "Local bundle checksum mismatch" >&2
    exit 2
}
[[ "$(sha256_local "$LOCAL_CIFAR")" == "$CIFAR_SHA256" ]] || {
    echo "Local CIFAR-10 checksum mismatch" >&2
    exit 2
}

echo "Checking passwordless PARAM Shakti access..."
"${SSH[@]}" "test \"\$(readlink -f '$RUN_ROOT')\" = '$RUN_ROOT' && mkdir -p '$RUN_ROOT/env' '$RUN_ROOT/slurm' '$RUN_ROOT/data' '$RUN_ROOT/logs' '$RUN_ROOT/results'"

echo "Uploading the code bundle with resume support..."
rsync -ah --info=progress2 --partial --append-verify \
    -e "$RSYNC_RSH" \
    "$LOCAL_BUNDLE" \
    "paramshakti:$RUN_ROOT/env/.paper_rerun_bundle_20260815.tar.gz.upload"

echo "Uploading the verified CIFAR-10 archive with resume support..."
rsync -ah --info=progress2 --partial --append-verify \
    -e "$RSYNC_RSH" \
    "$LOCAL_CIFAR" \
    "paramshakti:$RUN_ROOT/data/.cifar-10-python.tar.gz.upload"

echo "Verifying and atomically installing the upload..."
"${SSH[@]}" bash -s -- "$RUN_ROOT" "$PYTHON_BIN" "$BUNDLE_SHA256" "$CIFAR_SHA256" <<'REMOTE_DEPLOY'
set -euo pipefail

run_root=$1
python_bin=$2
expected_bundle=$3
expected_cifar=$4

resolved=$(readlink -f "$run_root")
[[ "$resolved" == "$run_root" ]] || {
    echo "Unexpected run-root resolution: $resolved" >&2
    exit 3
}

bundle_upload="$run_root/env/.paper_rerun_bundle_20260815.tar.gz.upload"
cifar_upload="$run_root/data/.cifar-10-python.tar.gz.upload"
actual_bundle=$(sha256sum "$bundle_upload" | awk '{print toupper($1)}')
actual_cifar=$(sha256sum "$cifar_upload" | awk '{print toupper($1)}')
[[ "$actual_bundle" == "$expected_bundle" ]] || {
    echo "Remote bundle checksum mismatch" >&2
    exit 3
}
[[ "$actual_cifar" == "$expected_cifar" ]] || {
    echo "Remote CIFAR-10 checksum mismatch" >&2
    exit 3
}

stage=$(mktemp -d "$run_root/env/deploy.XXXXXX")
case "$stage" in
    "$run_root"/env/deploy.*) ;;
    *) echo "Unsafe deployment staging path: $stage" >&2; exit 3 ;;
esac
cleanup_stage() {
    rm -rf -- "$stage"
}
trap cleanup_stage EXIT

tar -xzf "$bundle_upload" -C "$stage"
"$python_bin" -m py_compile \
    "$stage/dgx/dgx_a100_rerun.py" \
    "$stage/paramshakti/validate_results.py"
bash -n "$stage"/paramshakti/slurm/*.sbatch

install -m 600 "$stage/dgx/dgx_a100_rerun.py" "$run_root/env/dgx_a100_rerun.py.tmp"
install -m 600 "$stage/dgx/dgx_a100_rerun.ipynb" "$run_root/env/dgx_a100_rerun.ipynb.tmp"
install -m 600 "$stage/paramshakti/validate_results.py" "$run_root/env/validate_results.py.tmp"
mv -f "$run_root/env/dgx_a100_rerun.py.tmp" "$run_root/env/dgx_a100_rerun.py"
mv -f "$run_root/env/dgx_a100_rerun.ipynb.tmp" "$run_root/env/dgx_a100_rerun.ipynb"
mv -f "$run_root/env/validate_results.py.tmp" "$run_root/env/validate_results.py"

for source in "$stage"/paramshakti/slurm/*.sbatch; do
    name=$(basename "$source")
    install -m 600 "$source" "$run_root/slurm/$name.tmp"
    mv -f "$run_root/slurm/$name.tmp" "$run_root/slurm/$name"
done

final_cifar="$run_root/data/cifar-10-python.tar.gz"
if [[ -f "$final_cifar" ]]; then
    existing_cifar=$(sha256sum "$final_cifar" | awk '{print toupper($1)}')
    [[ "$existing_cifar" == "$expected_cifar" ]] || {
        echo "Existing remote CIFAR-10 archive has an unexpected checksum" >&2
        exit 3
    }
    rm -f -- "$cifar_upload"
else
    mv "$cifar_upload" "$final_cifar"
fi

echo "DEPLOYMENT_SHA256_BEGIN"
sha256sum \
    "$run_root/env/dgx_a100_rerun.py" \
    "$run_root/env/dgx_a100_rerun.ipynb" \
    "$run_root/env/validate_results.py" \
    "$run_root"/slurm/*.sbatch \
    "$final_cifar"
echo "DEPLOYMENT_SHA256_END"
echo "DEPLOYMENT_OK"
REMOTE_DEPLOY
