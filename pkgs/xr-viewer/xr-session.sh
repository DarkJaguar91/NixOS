# xr-session start|stop|toggle|restart [xr-viewer args...]
#
# Ties the Umbriel virtual outputs to the viewer's lifetime. xr-viewer creates
# one per screen in the layout (~/.config/xr-session/layout.toml, edited with
# xr-layout), follows the layout live as it's saved, and records which exist;
# whenever the viewer exits (stop, Ctrl+C, a crash, glasses missing) those
# outputs are destroyed. Umbriel moves any windows on them back to a real
# output, as for an unplugged monitor.

pidfile="${XDG_RUNTIME_DIR:?}/xr-session.pid"
logfile="$XDG_RUNTIME_DIR/xr-session.log"
recorded="$XDG_RUNTIME_DIR/xr-session.screens"
viewer=""
viewer_args=()

cleanup() {
  trap - EXIT INT TERM
  if [[ -n $viewer ]] && kill "$viewer" 2>/dev/null; then
    wait "$viewer" || true
  fi
  # The viewer's record of its outputs, or the layout's if it never wrote one
  local screen
  {
    if [[ -f $recorded ]]; then
      cat "$recorded"
    else
      xr-viewer "${viewer_args[@]}" --list || true
    fi
  } | while read -r screen _; do
    umbriel output-destroy "$screen" || true
  done
  rm -f "$recorded"
  # The viewer kept the glasses' output past the screens; with those gone,
  # bring it back beside the monitors so the pointer can't be stranded on it
  xr-viewer --reset-glasses || true
  rm -f "$pidfile"
  echo "--- $(date) stopped"
}

running() {
  [[ -f $pidfile ]] && kill -0 "$(<"$pidfile")" 2>/dev/null
}

start() {
  if running; then
    echo "xr-session: already running" >&2
    return 0
  fi
  echo $$ >"$pidfile"
  exec >>"$logfile" 2>&1

  trap cleanup EXIT
  trap 'exit 0' INT TERM

  viewer_args=("$@")
  rm -f "$recorded"
  echo "--- $(date) starting"
  xr-viewer "$@" &
  viewer=$!
  # Center on wherever the user is looking as the session starts
  echo recenter_screen=true >/dev/shm/xr_driver_control || true
  wait "$viewer" || echo "xr-viewer exited with status $?"
  viewer=""
}

stop() {
  if running; then
    kill "$(<"$pidfile")"
  fi
  # Wait for its cleanup, so a following start finds the outputs gone
  local i
  for ((i = 0; i < 50; i++)); do
    running || return 0
    sleep 0.1
  done
}

case "${1:-}" in
  start) shift; start "$@" ;;
  stop) stop ;;
  toggle)
    shift
    if running; then stop; else start "$@"; fi
    ;;
  restart)
    shift
    stop
    start "$@"
    ;;
  *)
    echo "usage: xr-session start|stop|toggle|restart [xr-viewer args...]" >&2
    exit 2
    ;;
esac
