#!/usr/bin/env bash

# Pamo Creat Next App Starter Script
# By paul@pamosystems

DIR="$(dirname "$0")"
CURRENT_DIR="$PWD"
DATA="$DIR/data.json"
EXCLUDE="$DIR/exclude.txt"

DEPENDENCIES=$(jq -r '.dependencies | join(" ")' "$DATA")
TEMPLATE_URL=$(jq -r '.template' "$DATA")
CLEANUP=$(jq -r '.cleanup | join(" ")' "$DATA")

echo -e "Starting setup script...\n"

sleep 1

echo -e "Cloning GitHub template...\n"

sleep 1

mkdir template

git clone "$TEMPLATE_URL" "./template"

sleep 1

echo -e "\nCreate next project...\n"

sleep 1

read -p "Project name: " name

echo -e "\nStarting create-next-app...\n"

/usr/bin/npx create-next-app "$name"

echo -e "Installing npm latest dependencies...\n"

sleep 1

/usr/bin/npm --prefix "$CURRENT_DIR"/"$name" install $DEPENDENCIES

sleep 1

echo -e "\nSyncing template files...\n"

rsync -av template/ "$CURRENT_DIR"/"$name"/ --exclude-from="$EXCLUDE"

echo -e "\nCleaning up...\n"

sleep 1

rm -rf template

cd "$name" && rm -rf $CLEANUP

echo -e "Finished!"