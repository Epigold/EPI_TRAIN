{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [ pkgs.sl pkgs.bashInteractive pkgs.xprop pkgs.xdotool ];

  shellHook = ''
    stty -echo
    trap '' SIGINT SIGTERM SIGQUIT SIGHUP
    clear

    TERMINAL_WIN_ID=$(xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)" | awk '{print $5}')

    CONTROL_FILE=/tmp/train_running
    touch $CONTROL_FILE

    (
      while [ -f $CONTROL_FILE ]; do
        sl > /dev/null 2>&1
        sleep 0.1
        xdotool windowraise $TERMINAL_WIN_ID
      done
    ) &

    TRAIN_PID=$!

    while true; do
      read -r cmd
      if [ "$cmd" = "kk" ]; then
        rm -f $CONTROL_FILE
        kill $TRAIN_PID 2>/dev/null
        break
      fi
    done

    stty echo
  '';
}
