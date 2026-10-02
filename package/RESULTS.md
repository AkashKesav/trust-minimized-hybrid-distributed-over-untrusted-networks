# Corrected Results and Validation Record

Generated from the authoritative PARAM Shakti snapshot and accepted Kaggle control-plane outputs. Test accuracy is reported at the final epoch unless a validation-selected checkpoint is explicitly available. Maximum test accuracy is never used as a selection rule in the corrected headline results.

## Evidence status

- PARAM Shakti training runner and completed Slurm launchers matched the local canonical files byte-for-byte.
- Completed production jobs: seven original bundle tasks plus successful retry 602595_1, Day-5 K=2 job 602864, and Day-5 K=4 job 602865.
- The failed bundle task 602539_1 was superseded by successful retry 602595_1.
- Day-5 K=8 job 602866 was cancelled before starting; hybrid rank and tau-sensitivity tests were also cancelled and are not results.
- Available production matrix: **135/138 primary CSVs** and **9,840/10,440 primary rows**. The only missing production cases are the three K=8 seeds.
- Eighteen locally padded Byzantine worker CSVs were rejected as provenance sources. Their original shortened remote traces are included in `raw/param_shakti/full/logs`.

## Single-A100 baseline

Across seeds 42, 43, and 44, validation-selected test accuracy is **88.48% ± 0.17 percentage points** (sample SD), with mean best-validation accuracy **89.71%**. Final-epoch test accuracy is **88.42% ± 0.48**.

## Clean multi-GPU pipeline

K=2 and K=4 produce identical optimization trajectories across all three seeds. Validation-selected test accuracy is **88.25%** for both depths. Final-epoch accuracy is **88.36% ± 0.36**. Final-three-epoch throughput is **5683 ± 92 samples/s** for K=2 and **3074 ± 4 samples/s** for K=4, versus **5137 ± 1047 samples/s** on one A100. K=8 is unmeasured.

## Data parallelism: corrected final-epoch results

| N | Softmax final | Top-K final | Softmax - Top-K |
| --- | --- | --- | --- |
| 2 | 87.81% | 87.16% | 0.66 pp |
| 4 | 85.47% | 85.00% | 0.47 pp |
| 8 | 82.97% | 81.06% | 1.91 pp |

These replace the prior maxima selected from the test curve. Softmax remains ahead at all three worker counts, with a final-epoch difference of **0.47–1.91 percentage points**.

## Byzantine experiments

The 75-run matrix contains **57 completed runs** and **18 intentional numerical-collapse outcomes**. At N=8, f=2, seed 42, the one-shot Krum-score filter gives TPR/FPR 1.0/0.0 for Gaussian and Byzantine-majority attacks, and 0.0/0.333 for zero-update and mean-shift attacks. Krum keeps Gaussian and mean-shift training finite at all tested ratios; zero-update reaches chance accuracy for f≥4, and Byzantine-majority Krum runs collapse numerically for f≥4. These are empirical outcomes; the retained-set heuristic does not inherit the standard Krum theorem.

## Pipeline activation attacks

Using validation-selected checkpoints, mean test accuracy is **67.64%** for Gaussian activation, **67.78%** for sign flip, and **10.00%** for zero activation. The observational activation-norm monitor has TPR=1.0 and FPR=1.0, so it does not discriminate honest from malicious stages and does not repair corrupted activations.

## Overhead

Mean final-three-epoch totals are **12.91 s** for the reconstruction, **13.10 s** for the proposed configuration without Commit-Reveal, and **17.15 s** with Commit-Reveal. The full framework is **4.24 s (32.9%)** slower than the reconstruction. The incremental Commit-Reveal cost against the otherwise identical no-Commit-Reveal configuration is **4.05 s (30.9%)**. The standalone full digest benchmark is **3.90 s**.

## Validator selection

Across five 200-round trials, trust-weighted exponential-race selection gives Gini **0.113 ± 0.024**, entropy **2.969 ± 0.012 bits**, monopolization **0.113 ± 0.027**, and accuracy-selection correlation **0.486 ± 0.262**. The cumulative curve in Figure 8 is explicitly a representative seed-42 trace; the count bars and reported statistics are five-trial aggregates.

## Scripted penalty state machine

Nodes 2 and 5 are evicted at epoch 40 after four Byzantine events each. Node 0 receives timeout penalties at epochs 24 and 45 and finishes active with reputation 0.6. Seven event-log rows originally contained the node's final violation count rather than the cumulative count at that event; `tables/day9_event_log_corrected.csv` fixes that field. The 800-row state history independently replays without mismatch.

## Ablation: corrected final epoch

Under mean-shift attack at f=2/8, final-epoch test accuracy is **43.61%** for K-means+Top-K and **49.50%** for Krum+Top-K, a **5.88-point** difference. These values are final-epoch results, not validation-selected checkpoints. Under Gaussian attack, all three K-means runs collapse numerically, whereas Krum gives TPR 1.0 and FPR 0.0.

## Scope limits

No claim is made for K=8, integrated N×K execution, tau sensitivity, deployed blockchain/VRF/ECDHE, network performance, cryptographic security, or LLM-scale performance. The smart-contract experiment is scripted and does not estimate a false-positive rate.
