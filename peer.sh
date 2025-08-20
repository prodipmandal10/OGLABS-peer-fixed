#!/bin/bash

# Color codes
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
RESET='\033[0m'

print_header() {
    clear
    echo -e "${YELLOW}"
    echo "██████╗ ███████╗███╗   ██╗ █████╗ ██╗     ██╗      ██████╗ ███████╗"
    echo "██╔══██╗██╔════╝████╗  ██║██╔══██╗██║     ██║     ██╔═══██╗██╔════╝"
    echo "██████╔╝█████╗  ██╔██╗ ██║███████║██║     ██║     ██║   ██║█████╗  "
    echo "██╔═══╝ ██╔══╝  ██║╚██╗██║██╔══██║██║     ██║     ██║   ██║██╔══╝  "
    echo "██║     ███████╗██║ ╚████║██║  ██║███████╗███████╗╚██████╔╝███████╗"
    echo "╚═╝     ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝"
    echo "              🌐 BENGAL CRYPTO NODE MANAGER"
    echo "          💬 DM: @prodipgo (Telegram) | X: @prodipmandal10"
    echo -e "${RESET}\n"
}

stop_node() {
    echo -e "${CYAN}========== STEP 1: STOP YOUR NODE ==========${RESET}"
    sudo systemctl stop zgs
    echo -e "${GREEN}✅ Node stopped successfully.${RESET}"
}

rpc_change() {
    echo -e "${CYAN}========== STEP 2: RPC CHANGE ==========${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/rpc_change.sh)
    echo -e "${GREEN}✅ RPC change completed.${RESET}"
}

key_change() {
    echo -e "${CYAN}========== STEP 3: PRIVATE KEY CHANGE ==========${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/key_change.sh)
    echo -e "${GREEN}✅ Private key change completed.${RESET}"
}

start_service() {
    echo -e "${CYAN}========== STEP 4: START SERVICE ==========${RESET}"
    sudo systemctl daemon-reload
    sudo systemctl enable zgs
    sudo systemctl start zgs
    echo -e "${GREEN}✅ Service reloaded, enabled, and started.${RESET}"
}

block_check() {
    echo -e "${CYAN}========== STEP 5: BLOCK CHECK ==========${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/logs.sh)
    echo -e "${GREEN}✅ Block check complete.${RESET}"
}

install_node() {
    echo -e "${CYAN}========== STEP 0: INSTALL NODE (Without Fast Sync) ==========${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/node.sh)
    echo -e "${GREEN}✅ Node installation script executed.${RESET}"
}

apply_fast_sync() {
    echo -e "${CYAN}========== APPLY FAST SYNC ==========${RESET}"
    echo "⬇️ Downloading flow_db.tar.gz from Mega.nz..."

    # Check if megadl command exists, if not install megatools
    if ! command -v megadl &> /dev/null; then
        echo "🔧 Installing megatools for Mega.nz download..."
        sudo apt update
        sudo apt install -y megatools
    fi

    # Delete existing flow_db folder and file if exists
    rm -rf "$HOME/0g-storage-node/run/db/flow_db"
    rm -f "$HOME/0g-storage-node/run/db/flow_db.tar.gz"

    megadl 'https://mega.nz/file/eJ0RXY4Q#5RDf_7Y7HW8eUKzQvqACCkynNAOrtXDfp4Z0uYCWnsg' -O "$HOME/0g-storage-node/run/db/flow_db.tar.gz"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ Download failed. Please check your internet connection or link.${RESET}"
        return 1
    fi

    echo "🗜️ Extracting flow_db.tar.gz ..."
    tar -xzvf "$HOME/0g-storage-node/run/db/flow_db.tar.gz" -C "$HOME/0g-storage-node/run/db/"
    echo -e "${GREEN}✅ Fast sync applied successfully.${RESET}"

    echo "🔄 Restarting node service..."
    sudo systemctl restart zgs
    echo -e "${GREEN}✅ Node restarted with fast sync data.${RESET}"
}

delete_node_data() {
    echo -e "${CYAN}========== DELETE NODE DATA ==========${RESET}"
    # List files to be deleted (for log)
    echo "Deleting files in $HOME/0g-storage-node/run/db/"
    ls "$HOME/0g-storage-node/run/db/"
    rm -rf "$HOME/0g-storage-node/run/db/"*
    echo -e "${GREEN}✅ Node DB data deleted successfully.${RESET}"
}

delete_everything() {
    echo -e "${RED}========== DELETE EVERYTHING IN VPS HOME DIRECTORY ==========${RESET}"
    read -p "⚠️ Are you sure you want to delete EVERYTHING in HOME directory? (yes/no): " confirm
    if [[ "$confirm" == "yes" ]]; then
        rm -rf ~/*
        echo -e "${GREEN}✅ All files in HOME directory deleted.${RESET}"
    else
        echo -e "${YELLOW}❌ Cancelled.${RESET}"
    fi
}

while true; do
    print_header
    echo -e "${YELLOW}========== MENU ==========${RESET}"
    echo -e "${CYAN}0.${RESET} INSTALL NODE (Without Fast Sync)"
    echo -e "${CYAN}1.${RESET} STOP YOUR NODE"
    echo -e "${CYAN}2.${RESET} RPC CHANGE"
    echo -e "${CYAN}3.${RESET} PRIVATE KEY CHANGE"
    echo -e "${CYAN}4.${RESET} START SERVICE (Reload + Enable + Start)"
    echo -e "${CYAN}5.${RESET} BLOCK CHECK"
    echo -e "${CYAN}6.${RESET} EXIT"
    echo -e "${CYAN}7.${RESET} DELETE ALL NODE DATA"
    echo -e "${CYAN}8.${RESET} APPLY FAST SYNC"
    echo -e "${RED}9.${RESET} DELETE EVERYTHING IN VPS HOME DIRECTORY"
    echo -e "${YELLOW}============================${RESET}"

    read -p "Enter choice [0-9]: " choice

    case $choice in
        0) install_node ;;
        1) stop_node ;;
        2) rpc_change ;;
        3) key_change ;;
        4) start_service ;;
        5) block_check ;;
        6) echo -e "${YELLOW}👋 Exiting... Bye!${RESET}"; exit 0 ;;
        7) delete_node_data ;;
        8) apply_fast_sync ;;
        9) delete_everything ;;
        *) echo -e "${RED}❌ Invalid choice, try again.${RESET}" ;;
    esac

    echo ""
    read -p "Press ENTER to return to menu..." _
done
