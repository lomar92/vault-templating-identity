#!/bin/bash

# Benutzer zur Eingabe des Benutzernamens und des Passworts auffordern
read -p "Bitte geben Sie Ihren Benutzernamen ein: " username
read -s -p "Bitte geben Sie Ihr Passwort ein: " password
echo

# Bei Vault mit dem userpass-Authentifizierungsmethode anmelden und Token extrahieren
TOKEN=$(vault login -format=json -method=userpass username=$username password=$password | jq -r '.auth.client_token')

# Überprüfen, ob die Anmeldung erfolgreich war und ein Token erhalten wurde
if [ -z "$TOKEN" ]; then
    echo "Fehler bei der Anmeldung. Bitte überprüfen Sie Ihren Benutzernamen und Ihr Passwort."
    exit 1
fi

# Setzen des Tokens als Umgebungsvariable
export VAULT_TOKEN=$TOKEN

# Den genauen Pfad zum Secret des Benutzers generieren
secret_path="$username/$username"

# Den Inhalt des Secrets abrufen
vault kv get $secret_path