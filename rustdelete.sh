#!/bin/bash

# === Settings ===
RUSTDESK_DIR="/root/rustdesk-server"  # Directory where RustDesk server is installed
PM2_PROCESS_NAMES=("hbbs" "hbbr")     # Names of PM2 processes for RustDesk

# === Functions ===
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# === Stop and delete PM2 processes ===
log_message "Stopping and deleting PM2 processes..."
for process in "${PM2_PROCESS_NAMES[@]}"; do
    if pm2 list | grep -q "$process"; then
        pm2 stop "$process"
        pm2 delete "$process"
        log_message "Stopped and deleted PM2 process: $process"
    else
        log_message "PM2 process $process not found."
    fi
done

# === Remove RustDesk files ===
if [ -d "$RUSTDESK_DIR" ]; then
    log_message "Removing RustDesk server files from $RUSTDESK_DIR..."
    rm -rf "$RUSTDESK_DIR"
    log_message "RustDesk server files removed."
else
    log_message "RustDesk directory $RUSTDESK_DIR not found."
fi

# === Remove RustDesk PM2 startup configuration ===
log_message "Removing PM2 startup configuration..."
pm2 unstartup
pm2 save --force
log_message "PM2 startup configuration removed."

# === Clean up RustDesk zip files (optional) ===
log_message "Removing RustDesk zip files from current directory..."
rm -f rustdesk-server-linux-amd64.zip
log_message "RustDesk zip files removed."

# === Final message ===
log_message "RustDesk server removal completed!"
