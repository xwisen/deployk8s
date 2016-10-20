function restart_docker {
  attempt=0
  while [[ ! -f /run/flannel/subnet.env ]]; do 
    if (( attempt > 200 )); then
      echo "timeout waiting for /run/flannel/subnet.env" >> ~/kube/err.log 
      exit 2
    fi
    attempt=$((attempt+1))
    sleep 3
  done
  
  sudo ip link set dev docker0 down
  sudo brctl delbr docker0

  source /run/flannel/subnet.env
  echo DOCKER_OPTS=\"${DOCKER_OPTS} --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}\" > /etc/default/docker
  source /etc/default/docker
  sudo systemctl daemon-reload
  sudo systemctl restart docker
}

echo "start config docker --------------------"
restart_docker
echo "exit code is $?-------------------------"
