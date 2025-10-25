#!/bin/bash

# ตั้งค่าตัวแปร
NAMESPACE="workshop-dev"
SERVICE_ACCOUNT="workshop-deployer"
KUBECONFIG_FILE="workshop-kubeconfig.yaml"

# ดึงข้อมูลจาก cluster
echo "กำลังดึงข้อมูลจาก Kubernetes cluster..."
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
echo "CLUSTER_NAME: $CLUSTER_NAME"

API_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
echo "API_SERVER: $API_SERVER"

CA_CERT=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
echo "CA_CERT: ${CA_CERT:0:50}..."

# สร้าง token
echo "กำลังสร้าง token..."
TOKEN=$(kubectl create token ${SERVICE_ACCOUNT} -n ${NAMESPACE} --duration=8760h)
echo "TOKEN: ${TOKEN:0:50}..."

# สร้างไฟล์ kubeconfig
echo "กำลังสร้างไฟล์ ${KUBECONFIG_FILE}..."
cat > ${KUBECONFIG_FILE} <<'EOF'
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: CA_CERT_PLACEHOLDER
    server: API_SERVER_PLACEHOLDER
  name: CLUSTER_NAME_PLACEHOLDER
contexts:
- context:
    cluster: CLUSTER_NAME_PLACEHOLDER
    namespace: NAMESPACE_PLACEHOLDER
    user: SERVICE_ACCOUNT_PLACEHOLDER
  name: SERVICE_ACCOUNT_PLACEHOLDER@CLUSTER_NAME_PLACEHOLDER
current-context: SERVICE_ACCOUNT_PLACEHOLDER@CLUSTER_NAME_PLACEHOLDER
users:
- name: SERVICE_ACCOUNT_PLACEHOLDER
  user:
    token: TOKEN_PLACEHOLDER
EOF

# แทนที่ค่า placeholders
sed -i "s|CA_CERT_PLACEHOLDER|${CA_CERT}|g" ${KUBECONFIG_FILE}
sed -i "s|API_SERVER_PLACEHOLDER|${API_SERVER}|g" ${KUBECONFIG_FILE}
sed -i "s|CLUSTER_NAME_PLACEHOLDER|${CLUSTER_NAME}|g" ${KUBECONFIG_FILE}
sed -i "s|NAMESPACE_PLACEHOLDER|${NAMESPACE}|g" ${KUBECONFIG_FILE}
sed -i "s|SERVICE_ACCOUNT_PLACEHOLDER|${SERVICE_ACCOUNT}|g" ${KUBECONFIG_FILE}
sed -i "s|TOKEN_PLACEHOLDER|${TOKEN}|g" ${KUBECONFIG_FILE}

echo ""
echo "สร้างไฟล์ ${KUBECONFIG_FILE} สำเร็จ"
echo ""
echo "เนื้อหาไฟล์"
cat ${KUBECONFIG_FILE}
