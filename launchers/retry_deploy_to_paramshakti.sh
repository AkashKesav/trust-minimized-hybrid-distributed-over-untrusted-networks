#!/usr/bin/env bash
set -u -o pipefail

DEPLOY_SCRIPT=/mnt/e/Paper/paramshakti/deploy_to_paramshakti.sh
LOG_FILE=/mnt/e/Paper/paramshakti/upload/deploy_retry.log
MAX_ATTEMPTS=24
RETRY_SECONDS=300

mkdir -p "$(dirname "$LOG_FILE")"
for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    printf '%s attempt=%d/%d\n' "$(date --iso-8601=seconds)" "$attempt" "$MAX_ATTEMPTS" | tee -a "$LOG_FILE"
    if "$DEPLOY_SCRIPT" 2>&1 | tee -a "$LOG_FILE"; then
        printf '%s deployment=complete\n' "$(date --iso-8601=seconds)" | tee -a "$LOG_FILE"
        exit 0
    fi
    status=${PIPESTATUS[0]}
    printf '%s deployment=retry exit=%d next_attempt_seconds=%d\n' \
        "$(date --iso-8601=seconds)" "$status" "$RETRY_SECONDS" | tee -a "$LOG_FILE"
    if (( attempt < MAX_ATTEMPTS )); then
        sleep "$RETRY_SECONDS"
    fi
done

printf '%s deployment=failed attempts=%d\n' \
    "$(date --iso-8601=seconds)" "$MAX_ATTEMPTS" | tee -a "$LOG_FILE"
exit 1
