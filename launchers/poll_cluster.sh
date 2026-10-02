#!/usr/bin/env bash
# Cluster poll loop: prints queue + partition state every 10 minutes.
# Line-buffered output so the monitor sees each poll immediately.
while true; do
    echo "[$(date --iso-8601=seconds)]"
    ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=4 paramshakti \
        "squeue -u mm24r002 -o '%.10i %.18j %.12T %.10M %R' -h; echo '---'; sinfo -p gpu -o '%t' -N -h | sort | uniq -c | sort -rn" \
        || echo "cluster_check_failed"
    sleep 600
done
