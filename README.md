# Reproducibility Package

**Paper:** *A Trust-Minimized Architecture for Hybrid Distributed Training on Untrusted Networks*

This repository contains the launcher scripts, configuration files, raw output CSVs, and job logs behind the results reported in the paper, together with the certified corrected-results package. Every reported number can be traced from a figure or table to the raw output file and the job that produced it.

## Repository layout

| Path | Contents |
| --- | --- |
| `package/` | Certified corrected-results package (frozen 2026-08-22): headline results, machine-readable metrics, figures, tables, raw CSV/JSON outputs, Slurm logs, validation and provenance records |
| `package/raw/param_shakti/full/` | Authoritative remote A100 outputs: per-run primary and worker CSVs (`logs/`), run summaries (`summaries/`), and environment / data-split / bundle manifests (`manifests/`) |
| `package/raw/kaggle/` | Corrected validator-selection (day 8) and penalty-state-machine (day 9) artifacts from the Kaggle control-plane runs |
| `package/provenance/slurm_logs/` | stdout / stderr of the accepted Slurm jobs |
| `package/provenance/remote_code/` | The exact Slurm launchers deployed to the cluster |
| `package/validation/` | Package-level audit report and the per-figure value audit (figure statistic versus raw-data cross-check) |
| `launchers/` | Slurm launchers (`launchers/slurm/`) and deployment / monitoring scripts (`launchers/*.sh`) |
| `configs/` | Authoritative experiment registry and Kaggle kernel submission configurations |

Start with [`package/RESULTS.md`](package/RESULTS.md) for the corrected narrative and headline values, [`package/CAPTIONS.md`](package/CAPTIONS.md) for the publication figure captions, and [`package/PROVENANCE.md`](package/PROVENANCE.md) for job accounting and artifact policy.

## How the experiments were run

**Hardware and software** (recorded per job in `package/raw/param_shakti/full/manifests/environment_*.json`):

- PARAM Shakti cluster (IITM), Slurm, account `iitm`, `gpu` partition
- NVIDIA A100 80GB PCIe nodes
- Python 3.10.13, PyTorch 2.2.1, torchvision 0.17.1, CUDA 11.8, cuDNN 8.7.0
- Deterministic mode, `CUBLAS_WORKSPACE_CONFIG=:4096:8`, bfloat16 AMP

**Model and data:** ResNet-50 with the standard 7x7 stride-2 stem and max-pool (10-class head; 23,528,522 parameters); CIFAR-10 split 45,000 train / 5,000 validation / 10,000 test with split seed `20260815` (`manifests/data_split_*.json`); seeds 42 / 43 / 44; batch size 128; SGD learning rate 0.1 with milestones 100/150 and gamma 0.1, momentum 0.9, Nesterov, weight decay 5e-4; aggregation temperature 0.1. Frozen experiment config hash: `7e267c0bf303542b`.

**Workflow:**

1. **Deploy** - `launchers/deploy_to_paramshakti.sh` uploads the checksum-pinned code bundle and the CIFAR-10 archive over SSH/rsync and installs them under the run root `/scratch/mm24r002/paper_rerun_20260815`. Retries are handled by `launchers/retry_deploy_to_paramshakti.sh`.
2. **Launch, single-A100 production array** - `sbatch launchers/slurm/paper_single_gpu_bundles.sbatch` runs the 8-task array covering experiment days 1, 2, 3, 4, 6, 7, 10. `paper_single_gpu_smoke.sbatch` is the acceptance smoke gate; `paper_probe.sbatch` and `paper_day5_probe.sbatch` are preflight probes.
3. **Launch, multi-GPU (NCCL)** - `paper_day5_k2.sbatch` (2 A100s) and `paper_day5_k4.sbatch` (4 A100s across 2 nodes) run the synchronous pipeline via `srun` with one shard per GPU, `NCCL_DEBUG=WARN` and `--kill-on-bad-exit=1`. `paper_day5_k2_smoke.sbatch` is the multi-GPU smoke gate. `paper_day5_k8.sbatch` is retained for completeness; its job was cancelled before starting and produced no results.
4. **Monitor** - `launchers/start_tmux_control.sh` and `launchers/poll_cluster.sh` provide the queue and progress monitors used during the campaign.
5. **Kaggle control-plane runs** - the validator-selection (day 8) and penalty state-machine (day 9) experiments executed as Kaggle kernels; their submission configurations are in `configs/kaggle/`.
6. **Accepted outputs** are collected under `package/raw/`; job accounting and superseded runs are recorded in `package/PROVENANCE.md`.

## Headline verified results

From the corrected package (`package/RESULTS.md`); accuracies are final-epoch test accuracy unless stated otherwise:

- **Single-A100 baseline:** validation-selected 88.48% +/- 0.17 pp; final-epoch 88.42% +/- 0.48.
- **Clean pipeline:** K=2 and K=4 produce identical optimization trajectories; validation-selected 88.25% for both; final-epoch 88.36% +/- 0.36. Final-three-epoch throughput 5683 +/- 92 samples/s (K=2) and 3074 +/- 4 samples/s (K=4), versus 5137 +/- 1047 samples/s on one A100.
- **Data parallelism, softmax versus Top-K:** N=2 87.81% / 87.16%; N=4 85.47% / 85.00%; N=8 82.97% / 81.06%.
- **Byzantine matrix:** 57 completed + 18 intentional numerical-collapse outcomes in the 75-run matrix. At N=8, f=2, the one-shot Krum filter gives TPR/FPR 1.0/0.0 for Gaussian and Byzantine-majority attacks.
- **Pipeline activation attacks** (validation-selected): 67.64% Gaussian, 67.78% sign flip, 10.00% zero activation; the observational activation-norm monitor does not discriminate (TPR=1.0, FPR=1.0).
- **Overhead:** full framework 17.15 s versus 12.91 s reconstruction (32.9%); incremental Commit-Reveal 4.05 s (30.9%) against the identical no-Commit-Reveal configuration.
- **Validator selection** (five 200-round trials): Gini 0.113 +/- 0.024; entropy 2.969 +/- 0.012 bits; accuracy-selection correlation 0.486 +/- 0.262.
- **Ablation** (mean-shift, f=2/8): K-means+Top-K 43.61% versus Krum+Top-K 49.50%.

## Evidence policy

- Cancelled, failed, smoke, padded, or otherwise superseded artifacts are retained only for provenance and are never treated as accepted results. `package/PROVENANCE.md` lists the accepted jobs (including the superseded failure/retry pair `602539_1` -> `602595_1`) and the exact evidence status of the campaign.
- Available production matrix: **135/138 primary CSVs** and **9,840/10,440 primary rows**; the only missing cases are the K=8 seeds 42-44, cancelled before starting.
- Scope limits - no claims are made for K=8, integrated N x K execution, tau sensitivity, deployed blockchain / VRF / ECDHE, network performance, or LLM-scale training - are stated in `package/RESULTS.md`.

## Integrity

[`SHA256SUMS.csv`](SHA256SUMS.csv) lists the size and SHA-256 digest of every file in this repository except itself. Verify a clone on Linux/macOS with:

```bash
sha256sum -c <(awk -F, 'NR>1 {print $3"  "$1}' SHA256SUMS.csv)
```

## Source code

This repository intentionally contains the experimental launchers, configuration, and raw outputs. The training runner, analysis, and validation source snapshots are versioned by SHA-256 in `package/PROVENANCE.md`; the authors can provide those revisions on request.

## Contact

Corresponding author: Ayush Saksena [![LinkedIn](https://img.shields.io/badge/-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ayush-saksena/) [![Portfolio](https://img.shields.io/badge/-000000?style=flat&logo=vercel&logoColor=white)](https://ayush-saksena.vercel.app/) [![GitHub](https://img.shields.io/badge/-181717?style=flat&logo=github&logoColor=white)](https://github.com/ayushsaksena30) [![Email](https://img.shields.io/badge/-EA4335?style=flat&logo=gmail&logoColor=white)](mailto:asaksena100@gmail.com) — [asaksena100@gmail.com](mailto:asaksena100@gmail.com)
