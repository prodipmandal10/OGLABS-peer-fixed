#!/bin/bash

# =========================
# 0G Storage Node Helper Script
# MADE BY PRODIP
# =========================

FLOW_DB_URL="https://drive.usercontent.google.com/uc?id=1Bu3A7rFEXF_sN9723glJjCT9sQ6wyC-8&export=download"
FLOW_DB_DIR="/home/ubuntu/0g-storage-node/run/db"

install_node() {
    echo "🚀 Starting 0G Storage Node Auto Installer..."
    echo "Do you want to use Fast Sync with flow_db restore from Google Drive? (y/n): "
    read fast_sync

    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/node.sh)

    if [[ "$fast_sync" == "y" || "$fast_sync" == "Y" ]]; then
        echo "📥 Downloading flow_db from Google Drive..."
        mkdir -p "$FLOW_DB_DIR"
        wget -O "$FLOW_DB_DIR/flow_db.zip" "$FLOW_DB_URL"

        echo "🧩 Extracting flow_db.zip..."
        unzip -o "$FLOW_DB_DIR/flow_db.zip" -d "$FLOW_DB_DIR"

        echo "✅ Fast sync data applied."
    fi

    echo "Press ENTER to return to menu..."
    read
}

stop_node() {
    echo "🛑 Stopping Node..."
    sudo systemctl stop zgs
    echo "✅ Node Stopped."
    read -p "Press ENTER to return to menu..."
}

rpc_change() {
    echo "🔁 Changing RPC..."
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/rpc_change.sh)
    read -p "Press ENTER to return to menu..."
}

pvt_key_change() {
    echo "🔑 Changing Private Key..."
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/pvt_key.sh)
    read -p "Press ENTER to return to menu..."
}

start_service() {
    echo "🚀 Enabling & Starting Service..."
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl enable zgs
    sudo systemctl restart zgs
    echo "✅ Node Started."
    read -p "Press ENTER to return to menu..."
}

block_check() {
    echo "📦 Checking Blocks..."
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/check_block.sh)
    read -p "Press ENTER to return to menu..."
}

delete_node_data() {
    echo "⚠️ Deleting all node-related data..."
    rm -rf ~/0g-storage-node
    echo "✅ Node data deleted."
    read -p "Press ENTER to return to menu..."
}

delete_everything() {
    echo "⚠️ WARNING: This will delete EVERYTHING under /home/ubuntu. Are you sure? (y/n): "
    read confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        sudo rm -rf /home/ubuntu/*
        echo "✅ Everything deleted from VPS."
    else
        echo "❌ Aborted."
    fi
    read -p "Press ENTER to return to menu..."
}

download_flow_db_only() {
    echo "📥 Downloading only flow_db from Google Drive..."
    mkdir -p "$FLOW_DB_DIR"
    wget -O "$FLOW_DB_DIR/flow_db.zip" "$FLOW_DB_URL"
    unzip -o "$FLOW_DB_DIR/flow_db.zip" -d "$FLOW_DB_DIR"
    echo "✅ flow_db downloaded and extracted."
    read -p "Press ENTER to return to menu..."
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
    echo "7. DELETE ALL NODE DATA"
    echo "8. DELETE EVERYTHING IN VPS HOME DIRECTORY"
    echo "9. DOWNLOAD FLOW_DB DATA FROM GOOGLE DRIVE"
    echo "============================"
    read -p "Enter choice [0-9]: " choice

    case $choice in
        0) install_node ;;
        1) stop_node ;;
        2) rpc_change ;;
        3) pvt_key_change ;;
        4) start_service ;;
        5) block_check ;;
        6) echo "👋 Exiting..."; break ;;
        7) delete_node_data ;;
        8) delete_everything ;;
        9) download_flow_db_only ;;
        *) echo "❌ Invalid choice."; sleep 1 ;;
    esac
done
