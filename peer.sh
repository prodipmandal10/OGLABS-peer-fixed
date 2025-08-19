#!/bin/bash

install_node() {
    echo "========== 0G STORAGE NODE INSTALLER =========="
    
    set -e
    cd "$HOME"

    if [ -d "0g-storage-node" ]; then
        echo "✅ 0g-storage-node is already installed. Skipping installation."
        return
    fi

    echo "🚀 Starting 0G Storage Node Auto Installer..."
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install -y curl iptables build-essential git wget lz4 jq make cmake gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen ufw xdotool

    if ! command -v rustc &> /dev/null; then
        echo "🔧 Installing Rust..."
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        source "$HOME/.cargo/env"
        echo 'source $HOME/.cargo/env' >> "$HOME/.bashrc"
    fi

    if ! command -v go &> /dev/null; then
        echo "🔧 Installing Go..."
        wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz
        rm go1.24.3.linux-amd64.tar.gz
        export PATH=$PATH:/usr/local/go/bin
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
    fi

    echo "📁 Cloning 0g-storage-node repository..."
    git clone https://github.com/0glabs/0g-storage-node.git
    cd 0g-storage-node
    git checkout v1.1.0
    git submodule update --init

    sudo apt install -y protobuf-compiler
    echo "⚙️ Building node..."
    cargo build --release

    if [ ! -f "$HOME/0g-storage-node/target/release/zgs_node" ]; then
        echo "❌ Build failed! zgs_node binary not found."
        return
    fi

    rm -f "$HOME/0g-storage-node/run/config.toml"
    mkdir -p "$HOME/0g-storage-node/run"
    curl -o "$HOME/0g-storage-node/run/config.toml" https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/config.toml

    read -e -p "🔐 Enter PRIVATE KEY (with or without 0x): " k
    k=${k#0x}; printf "\033[A\033[K"
    if [[ ${#k} -eq 64 && "$k" =~ ^[0-9a-fA-F]+$ ]]; then
        sed -i "s|miner_key = .*|miner_key = \"$k\"|" "$HOME/0g-storage-node/run/config.toml"
        echo "✅ Private key updated: ${k:0:4}****${k: -4}"
    else
        echo "❌ Invalid key! Must be 64 hex characters."
        return
    fi

    read -e -p "🌐 Enter new blockchain_rpc_endpoint URL: " r
    echo
    if [[ -z "$r" ]]; then
        echo "❌ Error: URL cannot be empty."
        return
    else
        sed -i "s|blockchain_rpc_endpoint = .*|blockchain_rpc_endpoint = \"$r\"|" "$HOME/0g-storage-node/run/config.toml"
        echo "✅ blockchain_rpc_endpoint updated to: $r"
    fi

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

    read -p "⚡ Do you want to apply Fast Sync? (y/n): " fastsync
    if [[ "$fastsync" =~ ^[Yy]$ ]]; then
        echo "⚡ Starting node and waiting 30 seconds before applying fast sync..."
        sudo systemctl start zgs
        sleep 60

        echo "🛑 Stopping node to apply fast sync..."
        sudo systemctl stop zgs
        rm -rf "$HOME/0g-storage-node/run/db/flow_db"

        echo "⬇️ Downloading and Extracting fast sync database..."
        wget https://github.com/HustleAirdrops/0G-Storage-Node/releases/download/Try/flow_db.tar.gz \
          -O $HOME/0g-storage-node/run/db/flow_db.tar.gz && \
          tar -xzvf $HOME/0g-storage-node/run/db/flow_db.tar.gz -C $HOME/0g-storage-node/run/db/

        echo "🚀 Restarting node with fast sync data..."
        sleep 5
        sudo systemctl restart zgs
    else
        echo "🚀 Starting node normally without fast sync..."
        sudo systemctl start zgs
    fi

    echo ""
    echo "🎉 Installation complete!"
    echo "👉 To start manually: sudo systemctl start zgs"
    echo "📄 Logs: tail -f \$HOME/0g-storage-node/run/log/zgs.log.\$(TZ=UTC date +%Y-%m-%d)"
    echo "📊 Monitor: bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/logs.sh)"
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
    echo "==========================================="
    echo "           MADE BY PRODIP"
    echo "==========================================="
    echo "=========== MENU ==========="
    echo "0. INSTALL NODE (With optional Fast Sync)"
    echo "1. STOP YOUR NODE"
    echo "2. RPC CHANGE"
    echo "3. PVT KEY CHANGE"
    echo "4. START SERVICE (Reload + Enable + Start)"
    echo "5. BLOCK CHECK"
    echo "6. EXIT"
    echo "============================"
    read -p "Enter choice [0-6]: " choice

    case $choice in
        0) install_node ;;
        1) stop_node ;;
        2) rpc_change ;;
        3) key_change ;;
        4) start_service ;;
        5) block_check ;;
        6) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice, try again." ;;
    esac

    echo ""
    read -p "Press ENTER to return to menu..." _
done
