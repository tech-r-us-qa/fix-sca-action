#!/bin/bash

mkdir -p ~/.veracode && touch ~/.veracode/veracode.yml

cat > ~/.veracode/veracode.yml << EOF
api:
    key-id: $FIX_SCA_VERACODE_API_KEY_ID
    key-secret: $FIX_SCA_VERACODE_API_KEY_SECRET
oauth:
    enabled: false
    region: ""
packager:
    "":
        trust: true
    _users_someusers_project:
        trust: true
EOF

# Extract Veracode CLI
mkdir -p ~/veracode-cli-2
unzip "$ACTION_PATH"/cli/veracode.zip  -d ~/veracode-cli-2
chmod +x ~/veracode-cli-2/veracode
