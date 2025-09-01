#!/bin/bash

SCRIPTS_DIR=$(dirname "$0")
TARGET_DIR=$1

if [[ -z "$TARGET_DIR" ]]; then
    echo "Usage: $0 <target-directory>"
    echo "This script will scrape your Pinterest feed and (re)start PinWall instances for all monitors."
    exit 1
fi

$SCRIPTS_DIR/pinterest-feed-scraper.sh "$TARGET_DIR" &
$SCRIPTS_DIR/hyprwall-multi.sh stop-all
wait
$SCRIPTS_DIR/hyprwall-multi.sh start-all 

