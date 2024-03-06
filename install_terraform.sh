#!/bin/bash

# Function to check if a package is installed
is_package_installed() {
  if rpm -q "$1" &> /dev/null; then
    return 0  # True - package is installed
  else
    return 1  # False - package is not installed
  fi
}

# Function to check if a repository is added
is_repo_added() {
  if dnf repolist | grep -q "$1" &> /dev/null; then
    return 0  # True - repo is added
  else
    return 1  # False - repo is not added
  fi
}

# Function to check for and install prerequisite packages
install_prerequisites() {
  if ! is_package_installed yum-utils; then
    echo "Installing 'yum-utils'..."
    sudo dnf install -y yum-utils
  else
    echo "'yum-utils' is already installed"
  fi
}

# Function to add the HashiCorp repository
add_hashicorp_repo() {
  if ! is_repo_added hashicorp; then
    echo "Adding HashiCorp repository..."
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  else 
    echo "HashiCorp repository is already added"
  fi
}

# Function to install Terraform
install_terraform() {
  if ! is_package_installed terraform; then
    echo "Installing Terraform..."
    sudo dnf install -y terraform
  else
    echo "Terraform is already installed"
  fi
}
# Function to validate the operating system
validate_os() {
  os=$(cat /etc/os-release | grep '^NAME=' | cut -d '"' -f 2)
  version=$(cat /etc/os-release | grep '^VERSION=' | cut -d '=' -f 2 | tr -d '"')

  if [[ "$os" == "Rocky Linux" && "$version" =~ 9\.[0-9] ]]; then
    echo "Supported OS detected: $os $version"
  else
    echo "Unsupported OS or version: $os $version"
    echo "Installation will not proceed."
    exit 1
  fi
}
# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (or with sudo)" 
   exit 1
fi

# 1. Validate OS
validate_os

# 2. Install prerequisites (if OS is supported)
install_prerequisites

# 3. Add HashiCorp Repository
add_hashicorp_repo

# 4. Install Terraform
install_terraform

# 5. Verify installation
echo "Verifying Terraform installation..."
terraform --version
