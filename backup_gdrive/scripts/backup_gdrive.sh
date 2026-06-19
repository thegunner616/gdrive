#!/bin/bash
# ══════════════════════════════════════════════
#  backup_gdrive.sh  -  Sistema de respaldo
# ══════════════════════════════════════════════
 
# --- Configuracion ---
BASE_DIR="$HOME/backup_gdrive"
SCRIPT_DIR="$BASE_DIR/scripts"
LOG_FILE="$BASE_DIR/logs/backup_$(date +%Y%m).log"
TEMP_DIR="$BASE_DIR/temp"
SOURCE_DIR="$HOME/datos"          # Directorio a respaldar
BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
GDRIVE_FOLDER="Respaldos_Linux"   # Carpeta destino en Drive
 
# --- Funcion de log ---
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
 
# Funcion para eliminar respaldos con mas de 7 dias en Drive
cleanup_old_backups() {
  local ACCESS_TOKEN=$1
  local FOLDER_ID=$2
  local MAX_DAYS=7
  local CUTOFF=$(date -d "-${MAX_DAYS} days" '+%Y-%m-%dT%H:%M:%S')
 
  OLD_FILES=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://www.googleapis.com/drive/v3/files?q=parents='$FOLDER_ID'
    +and+createdTime<'${CUTOFF}Z'&fields=files(id,name)")
 
  echo "$OLD_FILES" | jq -r '.files[] | .id' | while read FILE_ID; do
    curl -s -X DELETE \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      "https://www.googleapis.com/drive/v3/files/$FILE_ID"
    log "Eliminado respaldo antiguo: $FILE_ID"
  done
}

log "======= INICIO DE RESPALDO ======="
 
# --- 1. Comprimir directorio fuente ---
log "Comprimiendo $SOURCE_DIR..."
tar -czf "$TEMP_DIR/$BACKUP_NAME" -C "$(dirname $SOURCE_DIR)" \
  "$(basename $SOURCE_DIR)" 2>> "$LOG_FILE"
 
if [ $? -ne 0 ]; then
  log "ERROR: Fallo la compresion. Abortando."
  exit 1
fi
log "Archivo creado: $TEMP_DIR/$BACKUP_NAME"
 
# --- 2. Obtener token actualizado ---
ACCESS_TOKEN=$(bash $SCRIPT_DIR/refresh_token.sh)
if [ -z "$ACCESS_TOKEN" ]; then
  log "ERROR: No se pudo obtener token de acceso."
  exit 1
fi
 
# --- 3. Buscar o crear carpeta en Drive ---
log "Buscando carpeta '$GDRIVE_FOLDER' en Google Drive..."
FOLDER_SEARCH=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=name='$GDRIVE_FOLDER'
   +and+mimeType='application/vnd.google-apps.folder'
   +and+trashed=false&fields=files(id,name)")
 
FOLDER_ID=$(echo "$FOLDER_SEARCH" | jq -r '.files[0].id')
 
if [ "$FOLDER_ID" == "null" ] || [ -z "$FOLDER_ID" ]; then
  log "Carpeta no encontrada. Creando '$GDRIVE_FOLDER'..."
  FOLDER_RESP=$(curl -s -X POST \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name":"'$GDRIVE_FOLDER'","mimeType":"application/vnd.google-apps.folder"}' \
    https://www.googleapis.com/drive/v3/files)
  FOLDER_ID=$(echo "$FOLDER_RESP" | jq -r '.id')
  log "Carpeta creada con ID: $FOLDER_ID"
fi
 
# --- 4. Subir archivo a Google Drive ---
log "Subiendo $BACKUP_NAME a Google Drive..."
UPLOAD_RESP=$(curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "metadata={name:'$BACKUP_NAME',parents:['$FOLDER_ID']};type=application/json" \
  -F "file=@$TEMP_DIR/$BACKUP_NAME;type=application/gzip" \
  https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart)
 
FILE_ID=$(echo "$UPLOAD_RESP" | jq -r '.id')
 
if [ "$FILE_ID" != "null" ] && [ -n "$FILE_ID" ]; then
  log "Respaldo subido correctamente. ID Drive: $FILE_ID"
else
  log "ERROR al subir el archivo. Respuesta: $UPLOAD_RESP"
  exit 1
fi
 
# --- 5. Limpiar archivos temporales ---
rm -f "$TEMP_DIR/$BACKUP_NAME"
log "Archivo temporal eliminado."
log "======= RESPALDO COMPLETADO ======="
exit 0
