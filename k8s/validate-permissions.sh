#!/bin/bash

# Script to validate ServiceAccount permissions

set +e  # Don't exit on error - we want to see all test results

NAMESPACE="workshop-dev"
KUBECONFIG_FILE="workshop-kubeconfig.yaml"

echo "=================================="
echo "Validating ServiceAccount Permissions"
echo "=================================="
echo ""

# Check if kubeconfig exists
if [ ! -f "${KUBECONFIG_FILE}" ]; then
    echo "❌ Kubeconfig file not found: ${KUBECONFIG_FILE}"
    echo "Run ./generate-kubeconfig.sh first"
    exit 1
fi

KUBECTL="kubectl --kubeconfig=${KUBECONFIG_FILE} -n ${NAMESPACE}"

# Test 1: List pods (should PASS)
echo "Test 1: Can list pods?"
$KUBECTL get pods > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Can list pods"
else
    echo "✗ Cannot list pods (UNEXPECTED)"
fi
echo ""

# Test 2: Create deployment (should PASS)
echo "Test 2: Can create deployment?"
$KUBECTL create deployment test-nginx --image=nginx:latest --dry-run=client -o yaml | $KUBECTL apply -f - > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Can create deployment"
    DEPLOYMENT_CREATED=true
else
    echo "✗ Cannot create deployment (UNEXPECTED)"
    DEPLOYMENT_CREATED=false
fi
echo ""

# Test 3: Update deployment (should PASS)
if [ "$DEPLOYMENT_CREATED" = true ]; then
    echo "Test 3: Can update deployment?"
    $KUBECTL set image deployment/test-nginx nginx=nginx:alpine > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ Can update deployment"
    else
        echo "✗ Cannot update deployment (UNEXPECTED)"
    fi
    echo ""
fi

# Test 4: Delete deployment (should FAIL with forbidden)
echo "Test 4: Cannot delete deployment?"
$KUBECTL delete deployment test-nginx > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "✓ Cannot delete deployment (forbidden) - EXPECTED"
else
    echo "✗ Can delete deployment (UNEXPECTED - should be forbidden)"
fi
echo ""

# Test 5: List deployments (should PASS)
echo "Test 5: Can list deployments?"
$KUBECTL get deployments > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Can list deployments"
else
    echo "✗ Cannot list deployments (UNEXPECTED)"
fi
echo ""

echo "=================================="
echo "Validation Complete"
echo "=================================="
echo ""
echo "Note: test-nginx deployment may still exist (cannot delete with this ServiceAccount)"
echo "Clean up with admin account: kubectl delete deployment test-nginx -n ${NAMESPACE}"
