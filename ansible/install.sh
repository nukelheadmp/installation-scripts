#!/bin/bash

echo "Install Ansible with Passbolt integration and custom functions"

echo "Checking environment variables"
if [[ -z ${ANSIBLE_VAULTS:-} ]]; then
  echo "Setting required variables"
  export ANSIBLE_VAULTS=$HOME/.ansible/vaults
  export PYENV_PATH=$HOME/.local/lib/python
fi

echo "Install environment conf files"
cp $HOME/.local/share/app-configs/ansible/environment.d/* $HOME/.config/environment.d/

echo "Add bash functions"
if [[ ! -d $HOME/.bashrc.d ]]; then
  mkdir -p $HOME/.bashrc.d
fi

cp $HOME/.local/share/app-configs/ansible/bashrc.d/* $HOME/.bashrc.d/
source $HOME/.bashrc

echo "Installing packages"
sudo dnf install -y \
  ansible \
  python3 \
  sshpass

echo "Clone Passbolt plugin repo"
git clone https://github.com/passbolt/passbolt-ansible-lookup-plugin.git $HOME/.local/share/passbolt-ansible-lookup-plugin
cd $HOME/.local/share/passbolt-ansible-lookup-plugin

echo "Set up python environment"
python3 -m venv $PYENV_PATH/ansible
activate ansible
pip install -r passbolt/passbolt_lookup/requirements.txt
pip install pywinrm ncclient jxmlease xmltodict

echo "Install Passbolt plugin"
ansible-galaxy collection install ./passbolt --force

echo "Copy Ansible/Passbolt config file"
mkdir -p $ANSIBLE_VAULTS
cp $HOME/.local/share/app-configs/ansible/vault_passbolt.yml $ANSIBLE_VAULTS/vault_passbolt.yml

$EDITOR $ANSIBLE_VAULTS/vault_passbolt.yml

echo "Install Juniper Collection"
ansible-galaxy collection install juniper.device

echo "A reboot, or logging out and back in recommended."
read -p "Reboot now? (y/n)" reboot_confirm
if [[ -n $reboot_confirm && ($reboot_confirm == "y" || $reboot_confirm == "Y") ]]; then
  reboot
fi
