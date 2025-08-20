
#!/bin/bash

# ===================================
# 🟡 BENGAL AIRDROP 🟡
# OG NODE - MADE BY PRODIP
# JOIN TG CHANNEL - https://t.me/BENGAL_AIR
# ===================================

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

install_node() {
    echo "========== STEP 1: INSTALL DEPENDENCIES =========="
    sudo apt update && sudo apt install -y curl git build-essential unzip jq

    echo "========== STEP 2: INSTALL RUST =========="
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env

    echo "========== STEP 3: INSTALL GO =========="
    wget https://golang.org/dl/go1.21.1.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
    source $HOME/.bash_profile

    echo "========== STEP 4: CLONE & BUILD =========="
    git clone https://github.com/0glabs/0g-storage-node.git
    cd 0g-storage-node
    git checkout testnet
    make install

    echo "========== STEP 5: CONFIGURE NODE =========="
    read -p "Enter your PRIVATE KEY: " PRIVATE_KEY
    read -p "Enter your RPC: " RPC
    ./target/release/zgs config --data-dir ~/.zgs --chain-id zgtendermint_9000-1 --p2p-listen /ip4/0.0.0.0/tcp/26656 --rpc-listen 0.0.0.0:26657 --consensus-create-empty-blocks=false --db-path ~/.zgs/db --private-key $PRIVATE_KEY --rpc-url $RPC

    echo "[Unit]
Description=0G Storage Node
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/0g-storage-node/target/release/zgs start --config $HOME/.zgs/config.toml
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/zgs.service

    sudo systemctl daemon-reload
    sudo systemctl enable zgs
    sudo systemctl start zgs

    echo "✅ Node installed and service started successfully!"
}

fast_sync() {
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
}

while true; do
    clear
    echo -e "\e[95m==========================================="
    echo -e "          🟡 BENGAL AIRDROP 🟡"
    echo -e "        🔧 OG NODE - MADE BY PRODIP"
    echo -e "     📢 JOIN TG: https://t.me/BENGAL_AIR"
    echo -e "===========================================\e[0m"

    echo -e "\e[95m========== 🌟 MENU 🌟 =========="
    echo "1️⃣ INSTALL NODE (No Fast Sync)"
    echo "2️⃣ APPLY FAST SYNC (from MEGA)"
    echo "3️⃣ STOP YOUR NODE"
    echo "4️⃣ RPC CHANGE"
    echo "5️⃣ PVT KEY CHANGE"
    echo "6️⃣ START SERVICE (Reload + Enable + Start)"
    echo "7️⃣ BLOCK CHECK"
    echo "0️⃣ EXIT"
    echo "================================\e[0m"

    read -p "🔸 Enter choice [0-7]: " choice

    case $choice in
        1) install_node ;;
        2) fast_sync ;;
        3) stop_node ;;
        4) rpc_change ;;
        5) key_change ;;
        6) start_service ;;
        7) block_check ;;
        0) echo "🚪 Exiting... Bye!"; exit 0 ;;
        *) echo "❌ Invalid choice, try again." ;;
    esac

    echo ""
    read -p "🔁 Press ENTER to return to menu..." _
done
