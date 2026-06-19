#!/bin/bash
# ─────────────────────────────────────────────
# auth_gdrive.sh  -  Autenticacion OAuth2
# ─────────────────────────────────────────────
CONFIG_DIR="$HOME/backup_gdrive/config"
CREDS="$CONFIG_DIR/credentials.json"
TOKEN_FILE="$CONFIG_DIR/token.json"
 
# Extraer client_id y client_secret del JSON de credenciales
CLIENT_ID=$(jq -r '.installed.client_id' "$CREDS")
CLIENT_SECRET=$(jq -r '.installed.client_secret' "$CREDS")
SCOPE="https://www.googleapis.com/auth/drive.file"
REDIRECT_URI="urn:ietf:wg:oauth:2.0:oob"
 
# Paso 1: Mostrar URL de autorizacion al usuario
AUTH_URL="https://accounts.google.com/o/oauth2/auth?client_id=${CLIENT_ID}
  &redirect_uri=${REDIRECT_URI}&scope=${SCOPE}&response_type=code
  &access_type=offline"
 
echo "=== AUTENTICACION GOOGLE DRIVE ==="
echo "Abra la siguiente URL en su navegador:"
echo "$AUTH_URL"
echo ""
read -p "Pegue el codigo de autorizacion aqui: " AUTH_CODE
 
# Paso 2: Intercambiar codigo por tokens
RESPONSE=$(curl -s -X POST https://oauth2.googleapis.com/token \
  -d "code=${AUTH_CODE}" \
  -d "client_id=${CLIENT_ID}" \
  -d "client_secret=${CLIENT_SECRET}" \
  -d "redirect_uri=${REDIRECT_URI}" \
  -d "grant_type=authorization_code")
 
echo "$RESPONSE" > "$TOKEN_FILE"
chmod 600 "$TOKEN_FILE"
echo "Token guardado correctamente en $TOKEN_FILE"


