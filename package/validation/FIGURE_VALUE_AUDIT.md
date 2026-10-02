# Figure and Value Audit

Overall result: **PASS** (109/109 checks passed).

## Scope

Independent numerical cross-check of all generator headline statistics, error bars, counts, and the eleven output artifacts. Curves and scatter points are drawn directly from the packaged authoritative raw CSVs.

## Reporting rules

- Accuracy uses the final epoch unless explicitly described as validation-selected.
- Error bars use sample SD across seeds/trials.
- Weighted-VRF Gini is the mean of five per-trial Gini values.
- Pipeline timing/throughput uses each seed's final three epochs.

## Headline figure values

- Figure 1 baseline final accuracy: 88.42%.
- Figure 2 softmax final accuracy (N=2/4/8): 87.81%, 85.47%, 82.97%.
- Figure 8 fastest/weighted-VRF Gini: 0.87500 / 0.11275 ± 0.02400.
- Figure 10 K-means/Krum final accuracy: 43.613% / 49.497%.
- Figure 11 K=2/K=4 final accuracy: 88.36% / 88.36%.

The complete observed-versus-expected ledger is in `figure_value_audit.json`.
