#!/bin/bash

# Script to deploy all K8s resources

set -e

echo "=================================="
echo "Deploying Workshop Dev Environment"
echo "=================================="
echo ""

# Apply manifests in order
echo "1. Creating namespace..."
kubectl apply -f namespace.yaml

echo "2. Creating ServiceAccount..."
kubectl apply -f serviceaccount.yaml

echo "3. Creating Role..."
kubectl apply -f role.yaml

echo "4. Creating RoleBinding..."
kubectl apply -f rolebinding.yaml

echo ""
echo "✓ All resources deployed successfully!"
echo ""
echo "Next steps:"
echo "  1. Generate kubeconfig: ./generate-kubeconfig.sh"
echo "  2. Validate permissions: ./validate-permissions.sh"
