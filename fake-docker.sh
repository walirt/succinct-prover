#!/bin/bash
echo "-------mock docker start-------"
echo "Command: $0 $@"
if [[ "$1" == "run" ]]; then
  nohup /root/moongate-server > /root/moongate-server.log 2>&1 &
  pid=$!
  echo "moongate-server started in background with PID: $pid"
  echo $pid > /root/moongate-server.pid
elif [[ "$1" == "rm" ]]; then
  if [[ -f /root/moongate-server.pid ]]; then
    pid=$(cat /root/moongate-server.pid)
    if [[ -n "$pid" && -e /proc/$pid ]]; then
      kill -TERM "$pid"
      echo "moongate-server stopping..."
      timeout=5
      while [[ -e /proc/$pid ]] && [[ $timeout -gt 0 ]]; do
        sleep 1
        ((timeout--))
      done
      if [[ -e /proc/$pid ]]; then
        kill -9 "$pid"
        echo "moongate-server forcibly stopped after timeout"
      else
        echo "moongate-server stopped gracefully"
      fi
      rm -f /root/moongate-server.pid
    else
      echo "moongate-server is not running (invalid PID or process not found)"
      rm -f /root/moongate-server.pid
    fi
  else
    pid=$(ps aux | grep '/root/moongate-server' | grep -v 'grep' | awk '{print $2}')
    if [[ -n "$pid" ]]; then
      kill -TERM "$pid"
      echo "moongate-server stopping..."
      timeout=5
      while [[ -e /proc/$pid ]] && [[ $timeout -gt 0 ]]; do
        sleep 1
        ((timeout--))
      done
      if [[ -e /proc/$pid ]]; then
        kill -9 "$pid"
        echo "moongate-server forcibly stopped after timeout"
      else
        echo "moongate-server stopped gracefully"
      fi
    else
      echo "moongate-server is not running"
    fi
  fi
else
  echo "Do nothing"
fi
echo "-------mock docker end---------"