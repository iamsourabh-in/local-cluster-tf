#!/bin/bash
set -e

BIN_DIR="/home/macbook/workspace/iamsourabh/foliov2/platform/bin"
mkdir -p "$BIN_DIR"
cd "$BIN_DIR"

echo "Downloading Terraform v1.9.0..."
wget -q https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip
if command -v unzip >/dev/null; then
    unzip -o terraform_1.9.0_linux_amd64.zip
else
    # Fallback to python if unzip is not available
    python3 -c "import zipfile; zipfile.ZipFile('terraform_1.9.0_linux_amd64.zip').extractall('.')"
fi
rm -f terraform_1.9.0_linux_amd64.zip
chmod +x terraform

echo "Downloading KinD v0.23.0..."
wget -q https://github.com/kubernetes-sigs/kind/releases/download/v0.23.0/kind-linux-amd64 -O kind
chmod +x kind

echo "Downloading Helm v3.15.2..."
wget -q https://get.helm.sh/helm-v3.15.2-linux-amd64.tar.gz
tar -zxf helm-v3.15.2-linux-amd64.tar.gz
mv linux-amd64/helm helm
rm -rf linux-amd64 helm-v3.15.2-linux-amd64.tar.gz
chmod +x helm

echo "All tools downloaded successfully!"
./terraform --version
./kind --version
./helm version
