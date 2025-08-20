#!/bin/bash

# ========== HEADER ==========
clear
echo -e "\e[1;33m"
echo "███████╗██╗      ██████╗ ██╗    ██╗    ███╗   ██╗ ██████╗ ██████╗ ███████╗"
echo "██╔════╝██║     ██╔═══██╗██║    ██║    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝"
echo "█████╗  ██║     ██║   ██║██║ █╗ ██║    ██╔██╗ ██║██║   ██║██████╔╝███████╗"
echo "██╔══╝  ██║     ██║   ██║██║███╗██║    ██║╚██╗██║██║   ██║██╔═══╝ ╚════██║"
echo "██║     ███████╗╚██████╔╝╚███╔███╔╝    ██║ ╚████║╚██████╔╝██║     ███████║"
echo "╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝     ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚══════╝"
echo "               🌐 OG NODE MANAGER | MADE BY PRODIP"
echo "            💬 DM: @prodipgo (TELEGRAM) | X: @prodipmandal10"
echo -e "\e[0m"

# ========== FUNCTIONS ==========

install_node() {
    echo "========== INSTALLING NODE =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/install.sh)
}

apply_fast_sync() {
    echo "========== APPLYING FAST SYNC =========="

    if ! command -v megadl &> /dev/null; then
        echo "Installing megatools (required for Mega.nz download)..."
        sudo apt update && sudo apt install -y megatools
    fi

    echo "Downloading flow_db.tar.gz from Mega..."
    megadl 'https://mega.nz/file/eJ0RXY4Q#5RDf_7Y7HW8eUKzQvqACCkynNAOrtXDfp4Z0uYCWnsg'

    echo "Extracting flow_db.tar.gz..."
    tar -xvzf flow_db.tar.gz
    echo "✅ Fast sync completed!"
}

stop_node() {
    echo "========== STEP 1: STOP YOUR NODE =========="
    sudo systemctl stop zgs
    echo "✅ Node stopped successfully."
}

rpc_change() {
    echo "========== STEP 2: RPC CHANGE =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/rpc_change.sh)
    echo "✅ RPC change completed."
}

key_change() {
    echo "========== STEP 3: PVT KEY CHANGE =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/key_change.sh)
    echo "✅ Private key change completed."
}

start_service() {
    echo "========== STEP 4: START SERVICE =========="
    sudo systemctl daemon-reload
    sudo systemctl enable zgs
    sudo systemctl start zgs
    echo "✅ Service reloaded, enabled, and started."
}

block_check() {
    echo "========== STEP 5: BLOCK CHECK =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/logs.sh)
    echo "✅ Block check complete."
}

delete_node_data() {
    echo "========== DELETING NODE DATA =========="
    sudo rm -rf /root/.0g-storage-node
    echo "✅ Node data deleted."
}

delete_everything() {
    echo "⚠️ WARNING: Deleting EVERYTHING in HOME directory!"
    read -p "Are you sure? Type YES to continue: " confirm
    if [[ $confirm == "YES" ]]; then
        sudo rm -rf ~/*
        echo "✅ Everything deleted from VPS home directory."
    else
        echo "❌ Cancelled."
    fi
}

# ========== MENU LOOP ==========

while true; do
    echo -e "\e[1;36m"
    echo "================= OG NODE MENU ================="
    echo "0. INSTALL NODE 🔧"
    echo "1. APPLY FAST SYNC ⚡"
    echo "2. STOP YOUR NODE 🛑"
    echo "3. RPC CHANGE 🔁"
    echo "4. PVT KEY CHANGE 🔐"
    echo "5. START SERVICE 🚀"
    echo "6. BLOCK CHECK 🧱"
    echo "7. DELETE NODE DATA ❌"
    echo "8. DELETE EVERYTHING 💥"
    echo "9. EXIT 🚪"
    echo "==============================================="
    echo -e "\e[0m"

    read -p "Enter your choice [0-9]: " choice
    case $choice in
        0) install_node ;;
        1) apply_fast_sync ;;
        2) stop_node ;;
        3) rpc_change ;;
        4) key_change ;;
        5) start_service ;;
        6) block_check ;;
        7) delete_node_data ;;
        8) delete_everything ;;
        9) echo "🚪 Exiting... Bye!" ; exit 0 ;;
        *) echo "❌ Invalid choice. Try again." ;;
    esac

    echo ""
    read -p "Press ENTER to return to menu..." _
    clear
done
