#!/bin/bash

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
    echo "========== STEP 6: DELETE NODE DATA =========="
    rm -rf ~/0g-storage-node/run/db/*
    echo "✅ Node DB data deleted successfully."
}

delete_everything() {
    echo "========== STEP 7: DELETE EVERYTHING IN VPS =========="
    read -p "⚠️ Are you sure you want to delete EVERYTHING in HOME directory? (yes/no): " confirm
    if [[ "$confirm" == "yes" ]]; then
        rm -rf ~/*
        echo "✅ All files in HOME directory deleted."
    else
        echo "❌ Cancelled."
    fi
}

download_flow_db() {
    echo "========== STEP 8: DOWNLOAD flow_db.tar.gz FROM GOOGLE DRIVE =========="

    # Check if pip is installed
    if ! command -v pip &> /dev/null; then
        echo "🔧 pip not found. Installing pip..."
        sudo apt-get update
        sudo apt-get install -y python3-pip
    fi

    # Install or upgrade gdown
    pip install --upgrade gdown

    # Download using gdown
    gdown --id 1Bu3A7rFEXF_sN9723glJjCT9sQ6wyC-8 -O $HOME/0g-storage-node/run/db/flow_db.tar.gz

    if [[ $? -ne 0 ]]; then
        echo "❌ Download failed. Please check your internet connection or file ID."
        return 1
    fi

    # Extract the tar.gz file
    tar -xzvf $HOME/0g-storage-node/run/db/flow_db.tar.gz -C $HOME/0g-storage-node/run/db/
    echo "✅ flow_db.tar.gz downloaded and extracted successfully."
}

install_node() {
    echo "========== STEP 0: INSTALL NODE =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/node.sh)
    echo "✅ Node installation script executed."
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
        3) key_change ;;
        4) start_service ;;
        5) block_check ;;
        6) echo "👋 Exiting..."; exit 0 ;;
        7) delete_node_data ;;
        8) delete_everything ;;
        9) download_flow_db ;;
        *) echo "❌ Invalid choice, try again." ;;
    esac

    echo ""
    read -p "Press ENTER to return to menu..." _
done
