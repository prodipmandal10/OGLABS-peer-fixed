#!/bin/bash

# 💠 OG NODE BY PRODIP 💠 | 📬 DM - @PRODIPGO (TELEGRAM)

# =============== MENU COLORS ==================
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color
# ==============================================

# ============ FUNCTIONS =======================

install_node() {
    echo -e "${CYAN}🔧 Installing OG Node (no fast sync)...${NC}"
    curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/install.sh | bash
}

apply_fast_sync() {
    echo -e "${YELLOW}⚡ Applying Fast Sync from MEGA...${NC}"

    cd ~ || exit

    echo -e "${BLUE}📥 Downloading flow_db.tar.gz...${NC}"
    megadl 'https://mega.nz/file/eJ0RXY4Q#5RDf_7Y7HW8eUKzQvqACCkynNAOrtXDfp4Z0uYCWnsg'

    echo -e "${RED}🧹 Removing old flow_db if exists...${NC}"
    rm -rf 0g-storage-node/run/db/flow_db
    mkdir -p 0g-storage-node/run/db/
    tar -xzf flow_db.tar.gz -C 0g-storage-node/run/db/
    
    echo -e "${GREEN}✅ Fast Sync Applied Successfully!${NC}"
}

delete_everything() {
    echo -e "${RED}⚠️  Deleting EVERYTHING in your VPS home directory...${NC}"
    read -p "Are you sure? This will delete ALL files in HOME directory. (y/n): " confirm
    if [[ $confirm == "y" ]]; then
        cd ~ || exit
        ls -A | xargs rm -rf
        echo -e "${GREEN}✅ All files deleted from your VPS home directory.${NC}"
    else
        echo -e "${CYAN}❌ Delete cancelled.${NC}"
    fi
}

start_service() {
    echo -e "${GREEN}🚀 Starting Node Service...${NC}"
    sudo systemctl daemon-reexec
    sudo systemctl enable zgs
    sudo systemctl start zgs
    echo -e "${GREEN}✅ Node service started successfully.${NC}"
}

stop_service() {
    echo -e "${RED}🛑 Stopping Node Service...${NC}"
    sudo systemctl stop zgs
    echo -e "${GREEN}✅ Node stopped.${NC}"
}

check_block() {
    echo -e "${BLUE}🔍 Checking Block Sync Status...${NC}"
    logs_block=$(curl -s http://localhost:26657/status | jq -r '.result.sync_info.latest_block_height')
    live_block=$(curl -s https://api-nodes.0g.ai/ | jq -r '.result.sync_info.latest_block_height')
    peers=$(curl -s http://localhost:26657/net_info | jq -r '.result.n_peers')

    if [[ -n "$logs_block" && -n "$live_block" ]]; then
        behind=$((live_block - logs_block))
        speed=$((behind / 30))
        echo -e "${YELLOW}🧱 Logs Block: ${logs_block} | 🌍 Live Block: ${live_block} | 🤝 Peers: ${peers} | 🚀 Speed: ${speed} blocks/sec | 🔴 BEHIND: ${behind}${NC}"
    else
        echo -e "${RED}❌ Could not fetch block info. Node may not be running.${NC}"
    fi
}

# ================ MENU ========================

while true; do
    clear
    echo -e "${YELLOW}"
    echo "=============================================="
    echo "     💠 OG NODE BY PRODIP 💠"
    echo "     📬 DM - @PRODIPGO (TELEGRAM)"
    echo "=============================================="
    echo -e "${NC}"
    echo -e "${GREEN}=========== MENU ===========${NC}"
    echo -e "${CYAN}1) 🚀 Install Node (No Fast Sync)"
    echo -e "2) ⚡ Apply Fast Sync (from MEGA)"
    echo -e "3) 💣 Delete EVERYTHING in VPS"
    echo -e "4) 🟢 Start Node Service"
    echo -e "5) 🔴 Stop Node Service"
    echo -e "6) 🔍 Check Block Status"
    echo -e "7) ❌ Exit"
    echo -e "${GREEN}=============================${NC}"

    read -p "$(echo -e ${YELLOW}Choose an option [1-7]: ${NC})" choice

    case $choice in
        1) install_node ;;
        2) apply_fast_sync ;;
        3) delete_everything ;;
        4) start_service ;;
        5) stop_service ;;
        6) check_block ;;
        7) echo -e "${RED}🚪 Exiting... Bye!${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ Invalid Option. Try again.${NC}"; sleep 1 ;;
    esac
done
