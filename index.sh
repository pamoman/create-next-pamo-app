#!/usr/bin/env bash

# Pamo Creat Next App Starter Script
# By paul@pamosystems

NAME="create-next-pamo-app"
DIR="$(dirname "$0")"
WORKING_DIR="$PWD"
DATA="$DIR/../$NAME/data.json"
EXCLUDE="$DIR/../$NAME/exclude.txt"

# Uncomment below and comment above when testing locally
# DATA="$DIR/data.json"
# EXCLUDE="$DIR/exclude.txt"

DEPENDENCIES=$(jq -r '.dependencies | join(" ")' "$DATA")
TEMPLATE_URL=$(jq -r '.template' "$DATA")
DEV_URL=$(jq -r '.devUrl' "$DATA")
CLEANUP=$(jq -r '.cleanup | join(" ")' "$DATA")

# Setup the user enviromental variables
function setupUserEnv
{
    echo -e "\nConfigure enviromental variables\n"

    read -p "API URL: " api_url

    read -p "Globals API route: " globals_api_route

    read -p "Next Production URL: " next_prod_url

    cat <<EOT >> .env
NEXT_PUBLIC_API_URL=$api_url
NEXT_PUBLIC_DATABASE_URL=mysql://strapi:strapi@localhost:3306/strapi?synchronize=true
GLOBALS_DATA_PATH="./data"
GLOBALS_API_ROUTE=$globals_api_route
OAUTH_CLIENT_ID=12345
OAUTH_CLIENT_SECRET=12345
EOT

    cat <<EOT >> .env.development
NEXTAUTH_URL=$DEV_URL
EOT

    cat <<EOT >> .env.production
NEXTAUTH_URL=$next_prod_url
EOT

    echo -e "\nSetting up package.json for enviromental variables...\n"

    sleep 1

    tmp=$(mktemp)

    jq '.scripts.getGlobals = "node ./services/globals.mjs"' package.json > "$tmp" && mv "$tmp" package.json
    jq '.scripts.dev = "npm run getGlobals && next dev"' package.json > "$tmp" && mv "$tmp" package.json
    jq '.scripts.build = "npm run getGlobals && next build"' package.json > "$tmp" && mv "$tmp" package.json
    jq '.scripts.rebuild = "npm run build && pm2 restart App-name"' package.json > "$tmp" && mv "$tmp" package.json
}

# Setup the default enviromental variables
function setupEnv
{
        cat <<EOT >> .env
NEXT_PUBLIC_API_URL=https://my-api.com
NEXT_PUBLIC_DATABASE_URL=mysql://strapi:strapi@localhost:3306/strapi?synchronize=true
GLOBALS_DATA_PATH="./data"
GLOBALS_API_ROUTE=site-globals
OAUTH_CLIENT_ID=12345
OAUTH_CLIENT_SECRET=12345
EOT

    cat <<EOT >> .env.development
NEXTAUTH_URL=https://dev.my-domain.com
EOT

    cat <<EOT >> .env.production
NEXTAUTH_URL=https://my-app.com
EOT
}

echo -e "Starting setup script...\n"

sleep 1

echo -e "Cloning GitHub template...\n"

sleep 1

mkdir .temp

git clone "$TEMPLATE_URL" "./.temp"

sleep 1

echo -e "\nCreate next project...\n"

sleep 1

if [ $# -eq 0 ];
  then
    read -p "Project name: " name
else
    name="$1"
fi

echo -e "\nStarting create-next-app...\n"

/usr/bin/npx create-next-app "$name"

echo -e "Installing npm latest dependencies...\n"

sleep 1

/usr/bin/npm --prefix "$WORKING_DIR"/"$name" install $DEPENDENCIES

sleep 1

echo -e "\nSyncing template files...\n"

rsync -av .temp/ "$WORKING_DIR"/"$name"/ --exclude-from="$EXCLUDE"

echo -e "\nCleaning up...\n"

sleep 1

rm -rf .temp

cd "$name"

rm -rf $CLEANUP

while true; do
    read -p "Do you wish to configure enviromental variables, y/n? " yn
    case $yn in
        [Yy]* ) setupUserEnv; break;;
        [Nn]* ) setupEnv; break;;
        * ) echo "Answer y or n.";;
    esac
done

cat << EOF
How to start:

cd $name
npm run dev

EOF

echo -e "Finished!"

exit 0