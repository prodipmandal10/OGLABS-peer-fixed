#!/bin/bash

echo "========== STEP 1: STOP YOUR NODE =========="
sudo systemctl stop zgs
echo "Node stopped successfully."
echo "--------------------------------------------"
sleep 2

echo "========== STEP 2: RPC CHANGE =========="
bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/rpc_change.sh)
echo "RPC change completed."
echo "--------------------------------------------"
sleep 2

echo "========== STEP 3: PVT KEY CHANGE =========="
bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/key_change.sh)
echo "Private key change completed."
echo "--------------------------------------------"
sleep 2

echo "========== STEP 4: START SERVICE =========="
sudo systemctl daemon-reload
sudo systemctl enable zgs
sudo systemctl start zgs
echo "Service reloaded, enabled, and started."
echo "--------------------------------------------"
sleep 2

echo "========== STEP 5: BLOCK CHECK =========="
bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/logs.sh)
echo "Block check complete."
