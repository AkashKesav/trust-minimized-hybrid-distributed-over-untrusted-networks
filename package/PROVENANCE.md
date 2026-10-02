# PARAM Shakti Provenance

## Code identity

- Remote runner SHA-256: `8847bd319654311b7fab58e8dd7cfa367c208e2ec5b41c4c4e0d2e505b70469c`
- Local runner SHA-256: `8847bd319654311b7fab58e8dd7cfa367c208e2ec5b41c4c4e0d2e505b70469c`
- Runner match: **True**
- Remote notebook SHA-256: `f62373e7d4508f5c4e5b1d79da83920f0d96812ebc54f6f4efddceb7f7b93ef2`
- Local notebook SHA-256: `f62373e7d4508f5c4e5b1d79da83920f0d96812ebc54f6f4efddceb7f7b93ef2`
- Notebook match: **True**
- Frozen experiment config hash in the completed artifacts: `7e267c0bf303542b`

The remote validator is one revision older than the local validator. The only semantic validator change is that the local revision accepts `numerical_collapse` as an intentional terminal experimental outcome. Training code is identical.

## Job accounting verified on 2026-08-22

| Job | Purpose | State | Interpretation |
| --- | --- | --- | --- |
| 602539_0,2–7 | Production bundles | COMPLETED, exit 0:0 | Accepted |
| 602539_1 | Production bundle | FAILED, exit 1:0 | Superseded CUDA indexing failure |
| 602595_1 | Bundle-1 retry | COMPLETED, exit 0:0 | Accepted replacement for 602539_1 |
| 602864 | Day-5 K=2 | COMPLETED, exit 0:0 | Accepted |
| 602865 | Day-5 K=4 | COMPLETED, exit 0:0 | Accepted |
| 602866 | Day-5 K=8 | CANCELLED, zero runtime | Excluded |
| 603349 | Hybrid rank tests | CANCELLED, zero runtime | No result |
| 603351 | Tau sensitivity | CANCELLED, zero runtime | No result |

All accepted production stdout files contain their completion sentinel. The failed 602539_1 log is retained for provenance; its output is not used.

## Artifact policy

The authoritative raw A100 files in this package were copied directly from `/scratch/mm24r002/paper_rerun_20260815/results/full`. Eighteen local worker CSVs had previously been padded to the expected row count after numerical collapse; those edited copies are excluded. Primary CSVs, summaries, and all non-collapse worker traces matched the remote originals.

Available primary evidence: **135/138 CSVs**, **9,840/10,440 rows**. The missing three files and 600 rows are K=8 seeds 42–44.
