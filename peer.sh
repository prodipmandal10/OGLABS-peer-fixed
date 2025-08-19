#!/bin/bash

gdrive_download() {
    FILEID=$1
    FILENAME=$2

    CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
        "https://docs.google.com/uc?export=download&id=${FILEID}" -O- | \
        sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')

    wget --load-cookies /tmp/cookies.txt \
        "https://docs.google.com/uc?export=download&confirm=${CONFIRM}&id=${FILEID}" \
        -O "${FILENAME}"

    rm -rf /tmp/cookies.txt
}

install_node() {
    # ... [আপনার আগের install_node কোড এখানে থাকবে, আগের মতোই] ...
    echo "🚀 Starting 0G Storage Node Auto Installer..."
    # ... পুরো কোড আগের মতোই থাকবে ...
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

delete_all_nodedata() {
    echo "========== STEP 7: DELETE ALL NODE DATA =========="
    read -p "⚠️ Are you sure you want to DELETE ALL node data? This action is irreversible! (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Deleting all node data..."
        rm -rf "$HOME/0g-storage-node/run/db" "$HOME/0g-storage-node/run/log" "$HOME/0g-storage-node/run/flow_db.tar.gz"
        echo "All node data deleted."
    else
        echo "Deletion cancelled."
    fi
}

delete_everything() {
    echo "========== WARNING: DELETE EVERYTHING ON VPS =========="
    read -p "⚠️ Are you 100% sure to DELETE EVERYTHING in your VPS HOME directory? This is IRREVERSIBLE! (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Deleting ALL files and folders in $HOME ..."
        rm -rf "$HOME"/* "$HOME"/.[!.]* "$HOME"/..?*
        echo "All data in $HOME has been deleted."
        echo "Note: VPS OS and system files outside HOME are untouched."
    else
        echo "Deletion cancelled."
    fi
}

download_flowdb() {
    echo "========== DOWNLOAD FLOW_DB FROM GOOGLE DRIVE =========="
    read -p "⚠️ This will overwrite existing flow_db data. Continue? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Cancelled download."
        return
    fi

    DEST="$HOME/0g-storage-node/run/db/flow_db.tar.gz"
    echo "Downloading flow_db.tar.gz from Google Drive..."
    gdrive_download "1Bu3A7rFEXF_sN9723glJjCT9sQ6wyC-8" "$DEST"

    if [ $? -ne 0 ]; then
        echo "❌ Download failed! Please check your connection or Google Drive link."
        return
    fi

    echo "Removing old flow_db folder..."
    rm -rf "$HOME/0g-storage-node/run/db/flow_db"

    echo "Extracting flow_db.tar.gz..."
    tar -xzvf "$DEST" -C "$HOME/0g-storage-node/run/db/"

    echo "Download and extraction complete."
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
        6) echo "Exiting..."; exit 0 ;;
        7) delete_all_nodedata ;;
        8) delete_everything ;;
        9) download_flowdb ;;
        *) echo "Invalid choice, try again." ;;
    esac

    echo ""
    read -p "Press ENTER to return to menu..." _
done
