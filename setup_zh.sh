#!/bin/bash

echo "-----安装依赖包-----"
apt update
apt install build-essential pkg-config libssl-dev git protobuf-compiler -y
echo

echo "-----安装 Rust-----"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env
echo

echo "-----安装 sp1up-----"
curl -L https://sp1up.succinct.xyz | bash
source ~/.bashrc
~/.sp1/bin/sp1up
echo

echo "-----下载 moongate-server-----"
curl -L "https://raw.githubusercontent.com/walirt/succinct-prover/main/moongate-server" \
     -o ~/moongate-server
chmod +x ~/moongate-server
echo

echo "-----创建 fake-docker 目录-----"
mkdir -p ~/fake-docker/bin
echo

echo "-----下载 fake-docker.sh-----"
curl -L "https://raw.githubusercontent.com/walirt/succinct-prover/main/fake-docker.sh" \
     -o ~/fake-docker/bin/docker
chmod +x ~/fake-docker/bin/docker
echo "export PATH=\$PATH:$HOME/fake-docker/bin" >> ~/.bashrc
echo

echo "-----下载 Succinct 证明者-----"
git clone https://github.com/succinctlabs/network.git
cd network/bin/node
RUSTFLAGS="-C target-cpu=native" cargo build --release
cd ~/network
./target/release/spn-node --version
cp ./target/release/spn-node /usr/local/bin/spn-node
echo

echo "-----校准 Succinct 证明者-----"
read -p "每小时成本 [默认: 0.80]:" cost_per_hour
cost_per_hour=${cost_per_hour:-0.80}

read -p "利用率 [默认: 0.5]:" utilization_rate
utilization_rate=${utilization_rate:-0.5}

read -p "利润率 [默认: 0.1]:" profit_margin
profit_margin=${profit_margin:-0.1}

read -p "\$PROVE 价格 [默认: 1.00]:" prove_price
prove_price=${prove_price:-1.00}

SP1_PROVER=cuda
spn-node calibrate \
    --usd-cost-per-hour $cost_per_hour \
    --utilization-rate $utilization_rate \
    --profit-margin $profit_margin \
    --prove-price $prove_price

echo "请参考上述输出获取校准结果"

read -p "请输入机器的预估吞吐量 [默认: 1742469]:" throughput
throughput=${throughput:-1000000}

read -p "请输入预估投标价格 [默认: 0.28]:" bid_price
bid_price=${bid_price:-0.28}

read -p "请输入私钥:" private_key

read -p "请输入证明者地址:" prover_address

echo

echo "-----输入以下命令启动证明者节点-----"
echo "source ~/.bashrc"
echo "export SP1_PROVER=cuda"
echo "spn-node prove \\"
echo "    --rpc-url https://rpc.sepolia.succinct.xyz \\"
echo "    --throughput $throughput \\"
echo "    --bid $bid_price \\"
echo "    --private-key $private_key \\"
echo "    --prover-address $prover_address"
echo
