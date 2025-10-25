#!/bin/bash

# Script to generate kubeconfig for workshop-deployer ServiceAccount

set -e

NAMESPACE="workshop-dev"
SERVICE_ACCOUNT="workshop-deployer"
KUBECONFIG_FILE="workshop-kubeconfig.yaml"

echo "Generating kubeconfig for ${SERVICE_ACCOUNT} in ${NAMESPACE}..."

# Get cluster info
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
API_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

# Create token for ServiceAccount (valid for 1 year)
echo "Creating token for ServiceAccount..."
TOKEN=$(kubectl create token ${SERVICE_ACCOUNT} -n ${NAMESPACE} --duration=8760h)

# Generate kubeconfig
cat > ${KUBECONFIG_FILE} <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: ${API_SERVER}
  name: ${CLUSTER_NAME}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    namespace: ${NAMESPACE}
    user: ${SERVICE_ACCOUNT}
  name: ${SERVICE_ACCOUNT}@${CLUSTER_NAME}
current-context: ${SERVICE_ACCOUNT}@${CLUSTER_NAME}
users:
- name: ${SERVICE_ACCOUNT}
  user:
    token: ${TOKEN}
EOF

echo "✓ Kubeconfig generated: ${KUBECONFIG_FILE}"
echo ""
echo "Test with:"
echo "  kubectl --kubeconfig=${KUBECONFIG_FILE} get pods -n ${NAMESPACE}"
