# Kubernetes RBAC Workshop - Dev Environment

This directory contains Kubernetes manifests and scripts to set up a dev environment with proper RBAC (Role-Based Access Control).

## Overview

Creates a restricted ServiceAccount for deployment operations in the `workshop-dev` namespace with limited permissions.

## Resources Created

1. **Namespace**: `workshop-dev`
2. **ServiceAccount**: `workshop-deployer`
3. **Role**: `workshop-deployer-role` with permissions:
   - `get`, `list`, `create`, `update`, `patch` for deployments
   - `get`, `list` for pods
   - `get`, `list` for pod logs
4. **RoleBinding**: `workshop-deployer-binding`

## Prerequisites

- Minikube running
- kubectl configured
- Bash shell

## Quick Start

### 1. Deploy Resources

```bash
cd k8s/
chmod +x *.sh
./deploy.sh
```

### 2. Generate Kubeconfig

```bash
./generate-kubeconfig.sh
```

This creates `workshop-kubeconfig.yaml` with credentials for the `workshop-deployer` ServiceAccount.

### 3. Test the Kubeconfig

```bash
kubectl --kubeconfig=workshop-kubeconfig.yaml get pods -n workshop-dev
```

### 4. Validate Permissions

```bash
./validate-permissions.sh
```

Expected results:
- ✓ Can list pods
- ✓ Can create deployment
- ✓ Can update deployment
- ✓ Can list deployments
- ✓ Cannot delete deployment (forbidden)

## Manual Testing

### Test with kubeconfig:

```bash
# Set kubeconfig for current session
export KUBECONFIG=workshop-kubeconfig.yaml

# Should work - list pods
kubectl get pods -n workshop-dev

# Should work - create deployment
kubectl create deployment nginx --image=nginx -n workshop-dev

# Should work - list deployments
kubectl get deployments -n workshop-dev

# Should work - update deployment
kubectl set image deployment/nginx nginx=nginx:alpine -n workshop-dev

# Should FAIL - delete deployment (forbidden)
kubectl delete deployment nginx -n workshop-dev
```

## Cleanup

```bash
# Use admin kubeconfig
unset KUBECONFIG

# Delete all resources
kubectl delete namespace workshop-dev
```

## File Structure

```
k8s/
├── namespace.yaml              # Namespace definition
├── serviceaccount.yaml         # ServiceAccount definition
├── role.yaml                   # Role with permissions
├── rolebinding.yaml            # RoleBinding
├── deploy.sh                   # Deploy all resources
├── generate-kubeconfig.sh      # Generate kubeconfig file
├── validate-permissions.sh     # Validate RBAC permissions
└── README.md                   # This file
```

## Troubleshooting

### Token expired

Tokens are valid for 1 year. Regenerate kubeconfig:

```bash
./generate-kubeconfig.sh
```

### Permission denied errors

Check Role and RoleBinding:

```bash
kubectl describe role workshop-deployer-role -n workshop-dev
kubectl describe rolebinding workshop-deployer-binding -n workshop-dev
```

### Cannot create deployment

Ensure you're using the correct namespace:

```bash
kubectl --kubeconfig=workshop-kubeconfig.yaml get pods -n workshop-dev
```
