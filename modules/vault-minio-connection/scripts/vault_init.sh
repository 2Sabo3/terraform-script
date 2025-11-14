#!/bin/bash
set -euo pipefail

NAMESPACE="$1"
KES_POLICY_PATH="$2"
POLICY_NAME="$3"
APPROLE_NAME="$4"

echo "⏳ Waiting for Vault-0 to be Ready..."
VAULT_POD="vault-0"

echo "⏳ Sleeping for 5 seconds to ensure pod is up..."
sleep 5

echo "🔐 Initializing Vault (HA / Raft mode)..."
INIT_DATA=$(kubectl exec -n "$NAMESPACE" "$VAULT_POD" -- \
    vault operator init -format=json)

# Save init output for debugging
echo "$INIT_DATA" > vault-init.json

echo "📦 Extracting root token (without jq)..."
ROOT_TOKEN=$(echo "$INIT_DATA" | grep '"root_token"' | sed -E 's/.*"root_token": *"([^"]+)".*/\1/')

echo "🔑 Root token extracted: $ROOT_TOKEN"

echo "🔓 Extracting unseal keys (without jq)..."
UNSEAL_KEYS=$(echo "$INIT_DATA" | grep '"unseal_keys_b64"' -A 10 | grep '"' | sed -E 's/.*"([^"]+)".*/\1/' | tail -n +2 | head -5)

echo "🔐 Unseal keys extracted:"
echo "$UNSEAL_KEYS"

echo "🔓 Unsealing all Vault pods..."
PODS=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=vault -o jsonpath='{.items[*].metadata.name}')

for POD in $PODS; do
  echo "➡️ Unsealing $POD"
  for KEY in $UNSEAL_KEYS; do
    kubectl exec -n "$NAMESPACE" "$POD" -- vault operator unseal "$KEY"
  done
done

echo "📦 Vault successfully initialized & unsealed."

# --------------------------------------------------------------------
# ORIGINAL SCRIPT (unchanged)
# --------------------------------------------------------------------

echo "🔐 Enabling AppRole auth method..."
kubectl exec -n "$NAMESPACE" "$VAULT_POD" -- sh -c \
  "VAULT_TOKEN=${ROOT_TOKEN} VAULT_ADDR=http://127.0.0.1:8200 vault auth enable approle" || true

echo "📁 Enabling KV secrets engine..."
kubectl exec -n "$NAMESPACE" "$VAULT_POD" -- sh -c \
  "VAULT_TOKEN=${ROOT_TOKEN} VAULT_ADDR=http://127.0.0.1:8200 vault secrets enable kv" || true

echo "📜 Copying KES policy into Vault pod..."
# Copy to /tmp instead of /
kubectl cp "$KES_POLICY_PATH" -n "$NAMESPACE" "$VAULT_POD:/tmp/kes-policy.hcl"

echo "🧩 Writing KES policy to Vault..."
kubectl exec -n "$NAMESPACE" "$VAULT_POD" -- sh -c \
  "VAULT_TOKEN=${ROOT_TOKEN} VAULT_ADDR=http://127.0.0.1:8200 vault policy write ${POLICY_NAME} /tmp/kes-policy.hcl"

echo "⚙️ Creating KES AppRole..."
kubectl exec -n "$NAMESPACE" "$VAULT_POD" -- sh -c \
  "VAULT_TOKEN=${ROOT_TOKEN} VAULT_ADDR=http://127.0.0.1:8200 vault write auth/approle/role/${APPROLE_NAME} token_num_uses=0 secret_id_num_uses=0 period=5m policies=${POLICY_NAME}"

echo "🧾 Fetching AppRole IDs..."
ROLE_ID=$(kubectl exec -n "$NAMESPACE" "$VAULT_POD" -- sh -c \
  "VAULT_TOKEN=${ROOT_TOKEN} VAULT_ADDR=http://127.0.0.1:8200 vault read auth/approle/role/${APPROLE_NAME}/role-id" | grep "role_id" | awk '{print $2}')

SECRET_ID=$(kubectl exec -n "$NAMESPACE" "$VAULT_POD" -- sh -c \
  "VAULT_TOKEN=${ROOT_TOKEN} VAULT_ADDR=http://127.0.0.1:8200 vault write -f auth/approle/role/${APPROLE_NAME}/secret-id" | grep "secret_id" | awk '{print $2}')

echo "🔑 ROLE_ID: $ROLE_ID"
echo "🔑 SECRET_ID: $SECRET_ID"

echo "$ROLE_ID" > vault-role-id.txt
echo "$SECRET_ID" > vault-secret-id.txt

echo "✅ Vault initialization + policy/AppRole setup complete."
