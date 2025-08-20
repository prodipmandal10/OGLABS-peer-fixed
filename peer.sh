#!/bin/bash

# Color codes
YELLOW='\033[1;33m'
BOLD='\033[1m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

print_header() {
  echo -e "${YELLOW}${BOLD}═══════════════════════════════════════${NC}"
  echo -e "${YELLOW}${BOLD}           🟡 BENGAL AIRDROP 🟡          ${NC}"
  echo -e "${YELLOW}${BOLD}═══════════════════════════════════════${NC}"
  echo -e "${CYAN}👉 Join TG Channel: https://t.me/BENGAL_AIR ${NC}"
  echo -e ""
}

stop_node() {
    echo "========== STEP 1: STOP YOUR NODE =========="
    sudo systemctl stop zgs
    echo "Node stopped successfully."
}

rpc_change() {
    echo "========== STEP 2: RPC CHANGE =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/rpc_change.sh)
    echo "RPC change completed."
}

key_change() {
    echo "========== STEP 3: PVT KEY CHANGE =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/key_change.sh)
    echo "Private key change completed."
}

start_service() {
    echo "========== STEP 4: START SERVICE =========="
    sudo systemctl daemon-reload
    sudo systemctl enable zgs
    sudo systemctl start zgs
    echo "Service reloaded, enabled, and started."
}

block_check() {
    echo "========== STEP 5: BLOCK CHECK =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/logs.sh)
    echo "Block check complete."
}

while true; do
  clear
  print_header
  echo "======================================"
  echo "      🔵 0G STORAGE NODE MENU 🔵"
  echo "======================================"
  echo "1️⃣  Node Install (No Fast Sync)"
  echo "2️⃣  Apply Fast Sync Only (Mega Download)"
  echo "3️⃣  STOP YOUR NODE"
  echo "4️⃣  RPC CHANGE"
  echo "5️⃣  PVT KEY CHANGE"
  echo "6️⃣  START SERVICE (Reload + Enable + Start)"
  echo "7️⃣  BLOCK CHECK"
  echo "0️⃣  Exit"
  echo "======================================"
  read -p "Enter your choice [0-7]: " choice

  case $choice in
    1)
      echo "🚀 Starting Node Install (without Fast Sync)..."
      bash -c '
      set -e
      cd "$HOME"

      if [ -d "0g-storage-node" ]; then
          echo "✅ 0g-storage-node already installed."
          exit 0
      fi

      echo "🚀 Starting 0G Storage Node Auto Installer..."
      sudo apt-get update && sudo apt-get upgrade -y
      sudo apt install -y curl iptables build-essential git wget lz4 jq make cmake gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen ufw xdotool

      if ! command -v rustc &> /dev/null; then
          echo "🔧 Installing Rust..."
          curl https://sh.rustup.rs -sSf | sh -s -- -y
          source "$HOME/.cargo/env"
      fi

      if ! command -v go &> /dev/null; then
          echo "🔧 Installing Go..."
          wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
          sudo rm -rf /usr/local/go
          sudo tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz
          rm go1.24.3.linux-amd64.tar.gz
          echo "export PATH=$PATH:/usr/local/go/bin" >> "$HOME/.bashrc"
          source "$HOME/.bashrc"
      fi

      echo "📁 Cloning 0g-storage-node repository..."
      git clone https://github.com/0glabs/0g-storage-node.git
      cd 0g-storage-node
      git checkout v1.1.0
      git submodule update --init

      sudo apt install -y protobuf-compiler
      echo "⚙️ Building node..."
      cargo build --release

      rm -f "$HOME/0g-storage-node/run/config.toml"
      mkdir -p "$HOME/0g-storage-node/run"
      curl -o "$HOME/0g-storage-node/run/config.toml" https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/config.toml

      read -e -p "🔐 Enter PRIVATE KEY (with or without 0x): " k; k=${k#0x}; printf "\033[A\033[K"; [[ ${#k} -eq 64 && "$k" =~ ^[0-9a-fA-F]+$ ]] && sed -i "s|miner_key = .*|miner_key = \"$k\"|" "$HOME/0g-storage-node/run/config.toml" && echo "✅ Private key updated: ${k:0:4}****${k: -4}" || echo "❌ Invalid key!"
      read -e -p "🌐 Enter blockchain_rpc_endpoint URL: " r; echo; if [[ -z "$r" ]]; then echo "❌ URL cannot be empty."; else sed -i "s|blockchain_rpc_endpoint = .*|blockchain_rpc_endpoint = \"$r\"|" "$HOME/0g-storage-node/run/config.toml" && echo "✅ RPC updated to: $r"; fi

      sudo tee /etc/systemd/system/zgs.service > /dev/null <<EOF
[Unit]
Description=ZGS Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/0g-storage-node/run
ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

      sudo systemctl daemon-reload
      sudo systemctl enable zgs

      echo "🚀 Node installed successfully! Please apply fast sync manually if needed using Option 2."
      echo "👉 To start node manually: sudo systemctl start zgs"
      echo "📄 To view logs: tail -f \$HOME/0g-storage-node/run/log/zgs.log.\$(TZ=UTC date +%Y-%m-%d)"
      '
      read -p "Press Enter to continue..." ;;

    2)
      echo "🔄 Applying Fast Sync Only (Mega Download)..."
      bash -c '
      echo "========== STEP 1: STOP NODE =========="
      sudo systemctl stop zgs

      echo "========== STEP 2: INSTALL MEGATOOLS IF NOT PRESENT =========="
      if ! command -v megadl &> /dev/null; then
          echo "📦 Installing megatools..."
          sudo apt-get update
          sudo apt-get install -y megatools
      fi

      echo "========== STEP 3: CLEANING OLD DB FOLDER =========="
      rm -rf $HOME/0g-storage-node/run/db/
      mkdir -p $HOME/0g-storage-node/run/db/
      cd $HOME/0g-storage-node/run/db/

      echo "========== STEP 4: DOWNLOAD FROM MEGA =========="
      megadl "https://mega.nz/file/eJ0RXY4Q#5RDf_7Y7HW8eUKzQvqACCkynNAOrtXDfp4Z0uYCWnsg"

      echo "========== STEP 5: EXTRACTING flow_db.tar.gz =========="
      tar -xzvf flow_db.tar.gz

      echo "========== STEP 6: STARTING NODE AGAIN =========="
      sudo systemctl restart zgs

      echo "✅ Fast Sync Completed & Node Restarted Successfully!"
      '
      read -p "Press Enter to continue..." ;;

    3) stop_node ;;
    4) rpc_change ;;
    5) key_change ;;
    6) start_service ;;
    7) block_check ;;
    0)
      echo "Exiting... Bye!"
      exit 0
      ;;
    *)
      echo "Invalid option. Try again."
      sleep 1
      ;;
  esac

done
