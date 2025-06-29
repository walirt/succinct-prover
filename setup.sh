#!/bin/bash

echo "-----Installing dependencies-----"
apt update
apt install build-essential pkg-config libssl-dev git protobuf-compiler -y
echo

echo "-----Installing rust-----"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env
echo

echo "-----Installing sp1up-----"
curl -L https://sp1up.succinct.xyz | bash
source ~/.bashrc
~/.sp1/bin/sp1up
echo

echo "-----Downloading moongate-server-----"
curl -L "https://raw.githubusercontent.com/walirt/succinct-prover/main/moongate-server" \
     -o ~/moongate-server
chmod +x ~/moongate-server
echo

echo "-----Creating fake-docker directory-----"
mkdir -p ~/fake-docker/bin
echo

echo "-----Downloading fake-docker.sh-----"
curl -L "https://raw.githubusercontent.com/walirt/succinct-prover/main/fake-docker.sh" \
     -o ~/fake-docker/bin/docker
chmod +x ~/fake-docker/bin/docker
echo "export PATH=\$PATH:$HOME/fake-docker/bin" >> ~/.bashrc
echo

echo "-----Downloading succint prover-----"
git clone https://github.com/succinctlabs/network.git
cd network/bin/node
RUSTFLAGS="-C target-cpu=native" cargo build --release
cd ~/network
./target/release/spn-node --version
cp ./target/release/spn-node /usr/local/bin/spn-node
echo

echo "-----Calibrating succint prover-----"
read -p "Cost Per Hour [default: 0.80]:" cost_per_hour
cost_per_hour=${cost_per_hour:-0.80}

read -p "Utilization Rate [default: 0.5]:" utilization_rate
utilization_rate=${utilization_rate:-0.5}

read -p "Profit Margin [default: 0.1]:" profit_margin
profit_margin=${profit_margin:-0.1}

read -p "Price of \$PROVE [default: 1.00]:" prove_price
prove_price=${prove_price:-1.00}

SP1_PROVER=cuda
spn-node calibrate \
    --usd-cost-per-hour $cost_per_hour \
    --utilization-rate $utilization_rate \
    --profit-margin $profit_margin \
    --prove-price $prove_price

echo "Please refer to the above output for calibration results"

read -p "Please enter the estimated throughput of the machine [default: 1742469]:" throughput
throughput=${throughput:-1000000}

read -p "Please enter the estimated bid price [default: 0.28]:" bid_price
bid_price=${bid_price:-0.28}

read -p "Please enter the private key:" private_key

read -p "Please enter the prover address:" prover_address

echo

echo "-----Enter the following command to start the prover node-----"
echo "source ~/.bashrc"
echo "export SP1_PROVER=cuda"
echo "spn-node prove \\"
echo "    --rpc-url https://rpc.sepolia.succinct.xyz \\"
echo "    --throughput $throughput \\"
echo "    --bid $bid_price \\"
echo "    --private-key $private_key \\"
echo "    --prover-address $prover_address"
echo
