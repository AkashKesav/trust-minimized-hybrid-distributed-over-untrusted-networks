# Corrected Figure Captions

## Figure 1

Single-A100 ResNet-50/CIFAR-10 baseline across seeds 42–44. Left: mean test accuracy. Right: mean training loss on a logarithmic scale. Shaded bands show one sample standard deviation.

## Figure 2

Data parallelism with softmax aggregation. Left: global test accuracy for N=2,4,8 compared with the single-A100 baseline. Right: corresponding mean worker training loss. Curves are three-seed means with one-standard-deviation bands; the shared legend identifies every series.

## Figure 3

Softmax versus Top-K aggregation. Left: corrected final-epoch mean test accuracy with sample-standard-deviation error bars from independent trajectories. Right: epochwise three-seed mean accuracy difference. Softmax is ahead by 0.47–1.91 percentage points at the final epoch.

## Figure 4

Gradient-summary scatter at N=8 and f=2. Each panel plots update mean against update standard deviation for honest and malicious epoch-1 submissions across seeds 42–44 under zero-update, mean-shift, and Gaussian attacks; colours and markers are defined in the shared legend.

## Figure 5

Survival accuracy under Byzantine attacks with one-shot Krum-score filtering and softmax aggregation. Shaded bands show one standard deviation. Curves stop at numerical collapse rather than being imputed; f=4 and f=5 are empirical stress tests outside the standard Krum feasibility condition.

## Figure 6

Architecture-matched A100 overhead. Left: detector time per call for one-shot Krum-score filtering and K-means. Right: paired per-seed end-to-end epoch overhead relative to the reconstruction. Full-framework versus reconstruction overhead is 32.9%; Commit–Reveal's incremental overhead versus the no-Commit–Reveal configuration is 30.9%.

## Figure 7

Pipeline-attack survival accuracy over 20 epochs for K=4 with one of four stages malicious. The monitored and unmonitored trajectories are identical because the activation-norm monitor is observational; the dashed unmonitored curve is offset by +0.012 only for visibility. The legend identifies both series.

## Figure 8

Trust-weighted exponential-race validator selection. Left: representative seed-42 cumulative Gini trace. Right: mean node-selection counts across five independent 200-round trials. Aggregate weighted-race Gini is 0.113 ± 0.024.

## Figure 9

Scripted progressive penalties. Left: reputation history for all eight nodes. Right: all ten security events by type and node. Nodes 2 and 5 are evicted at epoch 40; node 0 remains active after two timeouts. The corrected event-level cumulative counts are provided in the accompanying CSV.

## Figure 10

Corrected ablation. Left: final-epoch test accuracy under mean-shift attack at f=2/8; no validation-selected global checkpoint exists for these runs. Right: Gaussian detection contrast, for which K-means collapses and Krum reaches TPR 1.0.

## Figure 11

Clean synchronous pipelines across seeds 42–44. Left: K=2 and K=4 convergence; the K=4 curve is offset by +0.012 only for visibility because the underlying trajectories are identical. Right: epochwise throughput for the single A100, K=2, and K=4 configurations. K=8 was cancelled before starting and is not shown.
