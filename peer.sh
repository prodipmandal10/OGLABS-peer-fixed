#!/bin/bash

stop_node() {
    echo "========== STEP 1: STOP YOUR NODE =========="
    sudo systemctl stop zgs
    echo "Node stopped."
}

rpc_change() {
    echo "========== STEP 2: RPC CHANGE =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/rpc_change.sh)
    echo "RPC changed."
}

key_change() {
    echo "========== STEP 3: PVT KEY CHANGE =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/key_change.sh)
    echo "Private key changed."
}

start_service() {
    echo "========== STEP 4: START SERVICE =========="
    sudo systemctl daemon-reload
    sudo systemctl enable zgs
    sudo systemctl start zgs
    echo "Service started."
}

block_check() {
    echo "========== STEP 5: BLOCK CHECK =========="
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/logs.sh)
}

while true; do
    clear
    echo "==========================================="
    echo "         🚀  MADE BY PRODIP  🚀"
    echo "==========================================="
    echo "========== MENU =========="
    echo "1. STOP YOUR NODE"
    echo "2. RPC CHANGE"
    echo "3. PVT KEY CHANGE"
    echo "4. START SERVICE (Reload + Enable + Start)"
    echo "5. BLOCK CHECK"
    echo "6. EXIT"
    echo "=========================="
    read -p "Enter choice [1-6]: " choice

    case $choice in
        1) stop_node ;;
        2) rpc_change ;;
        3) key_change ;;
        4) start_service ;;
        5) block_check ;;
        6) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice, try again." ;;
    esac
    echo ""
    read -p "Press ENTER to return to menu..."
done
