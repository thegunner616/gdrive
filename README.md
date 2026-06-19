# Sistema de Respaldo Automático en Google Drive

## Descripción

Este proyecto implementa un sistema de respaldo automático en Linux que permite almacenar archivos locales en Google Drive utilizando la API de Google y autenticación OAuth 2.0.

El objetivo es automatizar la creación y almacenamiento de copias de seguridad de información importante, garantizando la disponibilidad de los datos en la nube.

---

## Estructura del Proyecto

```text
gdrive_backup/
│
├── README.md
├── .gitignore
│
├── scripts/
│   ├── auth_gdrive.sh
│   ├── backup_gdrive.sh
│   └── refresh_token.sh
│
└── datos/
    ├── archivo1.txt
    ├── archivo2.txt
    └── config.cfg
```

---

## Componentes del Sistema

### auth_gdrive.sh

Este script realiza el proceso de autenticación inicial con Google Drive mediante OAuth 2.0.

Funciones principales:

* Solicita autorización del usuario.
* Obtiene el código de autorización.
* Genera el Access Token y Refresh Token.
* Permite que el sistema acceda a Google Drive de forma segura.

Se ejecuta una sola vez durante la configuración inicial.

---

### refresh_token.sh

Este script actualiza automáticamente el Access Token cuando expira.

Funciones principales:

* Utiliza el Refresh Token previamente obtenido.
* Solicita un nuevo Access Token a Google.
* Evita que el usuario tenga que autenticarse nuevamente.

Esto permite mantener la conexión activa con Google Drive.

---

### backup_gdrive.sh

Es el script principal del proyecto.

Funciones principales:

* Comprime o prepara los archivos que serán respaldados.
* Verifica la validez del Access Token.
* Ejecuta la subida de archivos hacia Google Drive.
* Registra el resultado de la operación.

Este script puede ejecutarse manualmente o mediante tareas programadas (cron).

---

### Carpeta datos

Contiene los archivos de ejemplo utilizados para demostrar el funcionamiento del sistema de respaldo.

Estos archivos representan la información que será respaldada automáticamente hacia Google Drive.

---

## Funcionamiento General

1. El usuario ejecuta `auth_gdrive.sh` para autorizar el acceso a Google Drive.
2. Google genera un Access Token y un Refresh Token.
3. Cuando el Access Token expira, `refresh_token.sh` obtiene uno nuevo automáticamente.
4. `backup_gdrive.sh` toma los archivos de la carpeta `datos`.
5. Los archivos son enviados a la carpeta de respaldo en Google Drive.
6. El proceso puede automatizarse mediante tareas programadas en Linux.

---

## Tecnologías Utilizadas

* Ubuntu Server
* Bash Scripting
* Google Drive API
* OAuth 2.0
* cURL
* Cron

---

## Resultado Esperado

Al ejecutar el sistema, los archivos almacenados localmente son respaldados automáticamente en Google Drive, permitiendo mantener copias de seguridad seguras y accesibles desde cualquier lugar.
