#!/usr/bin/env bash
# Control surface for PARAM Shakti work.
#
# Every window shares ONE multiplexed SSH connection. Opening a fresh
# connection per poll is what triggered the cluster's rate limiting on
# 2026-09-28 (the monitor windows used to open 2-4 connections every 20 s), so
# all invocations now pass the same ControlPath: the interactive window owns
# the master and the monitors reuse it. The socket lingers for
# CONTROL_PERSIST seconds after the last client disconnects.
#
# Environment overrides: PAPER_RUN_ROOT, PAPER_SMOKE_JOB, PAPER_PRODUCTION_JOB,
# PAPER_POLL_SECONDS, PAPER_CONTROL_PATH, PAPER_NO_MONITORS=1 (skip the three
# polling windows and keep only the persistent connection window).
set -euo pipefail

SESSION=paramsakti-control
RUN_ROOT=${PAPER_RUN_ROOT:-/scratch/mm24r002/paper_rerun_20260815}
SMOKE_JOB=${PAPER_SMOKE_JOB:-602538}
PRODUCTION_JOB=${PAPER_PRODUCTION_JOB:-602539}
POLL_SECONDS=${PAPER_POLL_SECONDS:-60}
CONTROL_PATH=${PAPER_CONTROL_PATH:-${HOME}/.ssh/cm-paramshakti}
CONTROL_PERSIST=600
SCRIPT=$(readlink -f "$0")

SSH_COMMON=(-o BatchMode=yes -o ControlMaster=auto -o ControlPath="${CONTROL_PATH}"
            -o ControlPersist="${CONTROL_PERSIST}" -o ConnectTimeout=20)

remote() {
    ssh -T "${SSH_COMMON[@]}" paramshakti "$@"
}

case "${1:-start}" in
    ssh)
        exec ssh -o ControlMaster=yes -o ControlPath="${CONTROL_PATH}" \
            -o ControlPersist="${CONTROL_PERSIST}" \
            -o ServerAliveInterval=15 -o ServerAliveCountMax=4 paramshakti
        ;;
    queue)
        while true; do
            printf '\033c'
            date --iso-8601=seconds
            remote squeue -u mm24r002 || true
            sleep "${POLL_SECONDS}"
        done
        ;;
    smoke-logs)
        while true; do
            printf '\033c'
            date --iso-8601=seconds
            remote sacct -X -j "${SMOKE_JOB}" \
                --format=JobID,JobName,State,Elapsed,ExitCode,Start,End || true
            echo
            echo "--- smoke stdout ---"
            remote tail -n 30 "${RUN_ROOT}/logs/smoke_${SMOKE_JOB}.out" 2>/dev/null || true
            echo
            echo "--- smoke stderr ---"
            remote tail -n 30 "${RUN_ROOT}/logs/smoke_${SMOKE_JOB}.err" 2>/dev/null || true
            sleep "${POLL_SECONDS}"
        done
        ;;
    production-logs)
        while true; do
            printf '\033c'
            date --iso-8601=seconds
            remote squeue -j "${PRODUCTION_JOB}" || true
            echo
            remote sacct -X -j "${PRODUCTION_JOB}" \
                --format=JobID,JobName,State,Elapsed,ExitCode,Start,End || true
            echo
            echo "--- latest production progress by task ---"
            remote "for file in ${RUN_ROOT}/logs/bundle_${PRODUCTION_JOB}_*.out; do
                    [ -f \"\$file\" ] || continue
                    echo \"--- \$(basename \"\$file\") ---\"
                    tail -n 8 \"\$file\"
                done" || true
            echo
            echo "--- production stderr tails ---"
            remote "for file in ${RUN_ROOT}/logs/bundle_${PRODUCTION_JOB}_*.err; do
                    [ -s \"\$file\" ] || continue
                    echo \"--- \$(basename \"\$file\") ---\"
                    tail -n 5 \"\$file\"
                done" || true
            sleep "${POLL_SECONDS}"
        done
        ;;
    start)
        if tmux has-session -t "${SESSION}" 2>/dev/null; then
            echo "tmux session already active: ${SESSION}"
            exit 0
        fi
        tmux new-session -d -s "${SESSION}" -n ssh "bash '${SCRIPT}' ssh"
        if [ "${PAPER_NO_MONITORS:-0}" = "1" ]; then
            # Monitor windows are opt-out: they are while-true pollers, and an
            # always-on poller was explicitly not wanted. On-demand status checks
            # go through this session's single multiplexed connection instead.
            echo "monitor windows skipped (PAPER_NO_MONITORS=1)"
        else
            tmux new-window -d -t "${SESSION}" -n queue "bash '${SCRIPT}' queue"
            tmux new-window -d -t "${SESSION}" -n smoke-logs "bash '${SCRIPT}' smoke-logs"
            tmux new-window -d -t "${SESSION}" -n production-logs "bash '${SCRIPT}' production-logs"
        fi
        tmux select-window -t "${SESSION}:ssh"
        echo "tmux session started: ${SESSION}"
        tmux list-windows -t "${SESSION}" \
            -F '#{window_index}:#{window_name}:#{pane_current_command}:active=#{window_active}'
        ;;
    stop)
        tmux kill-session -t "${SESSION}" 2>/dev/null || true
        ssh -O exit -o ControlPath="${CONTROL_PATH}" paramshakti 2>/dev/null || true
        echo "tmux session stopped: ${SESSION}"
        ;;
    *)
        echo "Usage: $0 [start|stop|ssh|queue|smoke-logs|production-logs]" >&2
        exit 2
        ;;
esac
