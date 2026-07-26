#!/usr/bin/env bash

HOST="server.vendore.tech"

if [ -f ~/.ssh/config ]; then

sed -i "/Host $HOST/,+3d" ~/.ssh/config 2>/dev/null || \
sed -i '' "/Host $HOST/,+3d" ~/.ssh/config

fi

echo "Vendore SSH configuration removed."
