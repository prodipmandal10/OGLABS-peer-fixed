#!/bin/bash

# =========================================
# 🚀 OG NODE BY PRODIP
# 📩 DM- @PRODIPGO (TELEGRAM)
# =========================================

YELLOW='\033[1;33m'
NC='\033[0m' # No Color

install_node() {
    echo "========== INSTALL NODE =========="
    cd "$HOME"

    if [ -d "0g-storage-node" ]; then
        echo "✅ 0g-storage-node already installed."
        return
    fi

    echo "🔧 Installing dependencies..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl iptables build-essential git wget lz4 jq make cmake gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen ufw xdotool protobuf-compiler

    echo "🔧 Installing Rust..."
    if ! command -v rustc &> /dev/null; then
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    echo "🔧 Installing Go..."
    if ! command -v go &> /dev/null; then
        wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz
        rm go1.24.3.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
        source "$HOME/.bashrc"
    fi

    echo "📁 Cloning 0g-storage-node repository..."
    git clone https://github.com/0glabs/0g-storage-node.git
    cd 0g-storage-node
    git checkout v1.1.0
    git submodule update --init

    echo "⚙️ Building node..."
    cargo build --release

    echo "📄 Setting up config..."
    mkdir -p "$HOME/0g-storage-node/run"
    curl -o "$HOME/0g-storage-node/run/config.toml" https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/config.toml

    # Private key
    read -e -p "🔐 Enter PRIVATE KEY (64 hex chars): " k
    k=${k#0x}
    if [[ ${#k} -eq 64 && "$k" =~ ^[0-9a-fA-F]+$ ]]; then
        sed -i "s|miner_key = .*|miner_key = \"$k\"|" "$HOME/0g-storage-node/run/config.toml"
        echo "✅ Private key updated: ${k:0:4}****${k: -4}"
    else
        echo "❌ Invalid key! Must be 64 hex chars."
    fi

    # RPC endpoint
    read -e -p "🌐 Enter blockchain_rpc_endpoint URL: " r
    if [[ -n "$r" ]]; then
        sed -i "s|blockchain_rpc_endpoint = .*|blockchain_rpc_endpoint = \"$r\"|" "$HOME/0g-storage-node/run/config.toml"
        echo "✅ blockchain_rpc_endpoint updated: $r"
    else
        echo "❌ URL cannot be empty."
    fi

    # Systemd service
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
    sudo systemctl start zgs

    echo "🎉 Installation complete! Node started."
    echo "👉 Fast sync can be applied later from menu option 8."
}

stop_node() {
    echo "========== STOP NODE =========="
    sudo systemctl stop zgs
    echo "🛑 Node stopped."
}

rpc_change() {
    echo "========== RPC CHANGE =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/rpc_change.sh)
    echo "✅ RPC change completed."
}

pvt_key_change() {
    echo "========== PRIVATE KEY CHANGE =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/key_change.sh)
    echo "✅ Private key updated."
}

start_service() {
    echo "========== START SERVICE =========="
    sudo systemctl daemon-reload
    sudo systemctl enable zgs
    sudo systemctl restart zgs
    echo "🚀 Node restarted."
}

block_check() {
    echo "========== BLOCK CHECK =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/logs.sh)
    echo "✅ Block check done."
}

delete_node_data() {
    echo "========== DELETE NODE DATA =========="
    rm -rf $HOME/0g-storage-node/run/db/*
    echo "🗑️ Node DB data deleted."
}

delete_everything() {
    echo "========== DELETE EVERYTHING IN HOME =========="
    read -p "⚠️ Are you sure you want to delete ALL files in $HOME (y/n)? " choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        rm -rf $HOME/*
        echo "🗑️ All files in $HOME deleted."
    else
        echo "❌ Cancelled."
    fi
}

apply_fast_sync() {
    echo "========== APPLY FAST SYNC =========="
    sudo systemctl stop zgs
    rm -rf ~/0g-storage-node/run/db/flow_db
    mkdir -p ~/0g-storage-node/run/db
    echo "⬇️ Downloading flow_db.tar.gz from Mega.nz..."
    wget --quiet --show-progress --progress=bar:force:noscroll \
        "https://mega.nz/file/eJ0RXY4Q#5RDf_7Y7HW8eUKzQvqACCkynNAOrtXDfp4Z0uYCWnsg" \
        -O ~/0g-storage-node/run/db/flow_db.tar.gz

    tar --strip-components=1 -xzvf ~/0g-storage-node/run/db/flow_db.tar.gz -C ~/0g-storage-node/run/db/
    rm -f ~/0g-storage-node/run/db/flow_db.tar.gz

    sudo systemctl start zgs
    echo "✅ Fast sync applied and node restarted."
    tail -f ~/0g-storage-node/run/log/zgs.log.$(date +%Y-%m-%d)
}

# ================================
# MENU LOOP
# ================================
while true; do
    clear
    echo -e "${YELLOW}"
    echo "======================================"
    echo "🚀 OG NODE BY PRODIP"
    echo "📩 DM- @PRODIPGO (TELEGRAM)"
    echo "======================================"
    echo "=========== MENU ==========="
    echo "0. INSTALL NODE"
    echo "1. STOP NODE"
    echo "2. RPC CHANGE"
    echo "3. PRIVATE KEY CHANGE"
    echo "4. START SERVICE"
    echo "5. BLOCK CHECK"
    echo "6. DELETE NODE DATA"
    echo "7. DELETE EVERYTHING IN VPS HOME"
    echo "8. APPLY FAST SYNC"
    echo "9. EXIT"
    echo "============================"
    echo -e "${NC}"

    read -p "Choose an option [0-9]: " choice
    case $choice in
        0) install_node ;;
        1) stop_node ;;
        2) rpc_change ;;
        3) pvt_key_change ;;
        4) start_service ;;
        5) block_check ;;
        6) delete_node_data ;;
        7) delete_everything ;;
        8) apply_fast_sync ;;
        9) echo "🚪 Exiting... Bye!"; exit 0 ;;
        *) echo "❌ Invalid option!" ;;
    esac
    read -p "Press Enter to continue..."
done
