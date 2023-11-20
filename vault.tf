# Konfiguration der Userpass-Authentifizierung
resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

# Benutzer anlegen
resource "vault_generic_endpoint" "user1" {
  depends_on = [vault_auth_backend.userpass]
  path       = "auth/userpass/users/user1"

  data_json = <<-EOT
    {
      "policies": ["user-kv-policy-test"],
      "password": "password"
    }
  EOT
}

resource "vault_generic_endpoint" "user2" {
  depends_on = [vault_auth_backend.userpass]
  path       = "auth/userpass/users/user2"

  data_json = <<-EOT
    {
      "policies": ["user-kv-policy-test"],
      "password": "password"
    }
  EOT
}

resource "vault_generic_endpoint" "user3" {
  depends_on = [vault_auth_backend.userpass]
  path       = "auth/userpass/users/user3"

  data_json = <<-EOT
    {
      "policies": ["user-kv-policy-test"],
      "password": "password"
    }
  EOT
}

resource "vault_identity_entity" "u1_entity" {
  depends_on = [vault_generic_endpoint.user1]
  name       = "user1"
}

resource "vault_identity_entity" "u2_entity" {
  depends_on = [vault_generic_endpoint.user2]
  name       = "user2"
}

resource "vault_identity_entity" "u3_entity" {
  depends_on = [vault_generic_endpoint.user3]
  name       = "user3"
}

resource "vault_identity_entity_alias" "u1_entity_alias" {
  depends_on     = [vault_identity_entity.u1_entity]
  name           = "user1"
  canonical_id   = vault_identity_entity.u1_entity.id
  mount_accessor = vault_auth_backend.userpass.accessor
}

resource "vault_identity_entity_alias" "u2_entity_alias" {
  depends_on     = [vault_identity_entity.u2_entity]
  name           = "user2"
  canonical_id   = vault_identity_entity.u2_entity.id
  mount_accessor = vault_auth_backend.userpass.accessor
}

resource "vault_identity_entity_alias" "u3_entity_alias" {
  depends_on     = [vault_identity_entity.u3_entity]
  name           = "user3"
  canonical_id   = vault_identity_entity.u3_entity.id
  mount_accessor = vault_auth_backend.userpass.accessor
}

# Lade die Benutzernamen aus den variables
locals {
  usernames = var.usernames
}

# Konfiguration der KV-Secrets-Engine
resource "vault_mount" "kv" {
  type        = "kv-v2"
  description = "KV secrets engine"
  for_each    = toset(local.usernames)
  path        = each.value
}

# Erstellung der Secrets und Metadaten für Benutzer
resource "vault_generic_secret" "example" {
  for_each  = toset(local.usernames)
  path      = "${each.value}/${each.value}"
  data_json = <<EOT
{
  "public key":   "public_key",
  "private key": "private_key"
}
EOT
}

# Konfiguration der Richtlinien für Identity Templating
resource "vault_policy" "user_kv_policy" {
  name   = "user-kv-policy-test"
  policy = <<-EOT
    path "{{identity.entity.name}}/data/{{identity.entity.name}}" {
      capabilities = ["create", "update", "read", "delete"]
    }
    path "{{identity.entity.name}}/metadata/*" {
      capabilities = ["list"]
    }

  EOT
}

