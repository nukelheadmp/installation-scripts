#!/bin/bash

echo "Install Ansible and set up environment for Passbolt integration"

echo "Checking environment variables"
if [[ -z ${PROJECTSDIR:-} ]]; then
  echo "Setting necessary variables"
  export PROJECTSDIR=$HOME/Projects
  export PYENV_PATH=$HOME/.local/lib/python
  export ANSIBLE_VAULTS=$HOME/.ansible/vaults
  echo "Copying environment config file"
  cp $PROJECTSDIR/installation-scripts/env/projects.sh $HOME/.config/environment.d/
fi

echo "Installing packages"
sudo dnf install -y \
  ansible \
  python3 \
  sshpass

echo "Clone Passbolt plugin repo"
mkdir -p $PROJECTSDIR
git clone https://github.com/passbolt/passbolt-ansible-lookup-plugin.git $PROJECTSDIR/passbolt-ansible-lookup-plugin
cd $PROJECTSDIR/passbolt-ansible-lookup-plugin

echo "Set up python environment"
python3 -m venv $PYENV_PATH/ansible
source $PYENV_PATH/ansible/bin/activate
pip install -r passbolt/passbolt_lookup/requirements.txt
pip install pywinrm ncclient jxmlease xmltodict

echo "Install Passbolt plugin"
ansible-galaxy collection install ./passbolt --force

echo "Copy Ansible/Passbolt config file"
mkdir -p $ANSIBLE_VAULTS
cp $PROJECTSDIR/installation-scripts/ansible/vault_passbolt.yml $ANSIBLE_VAULTS/vault_passbolt.yml

if [[ ! -d $HOME/.bashrc.d ]]; then
  mkdir -p $HOME/.bashrc.d
fi

cp $PROJECTSDIR/installation-scripts/ansible/bashrc.d/* $HOME/.bashrc.d
source $HOME/.bashrc

$EDITOR $ANSIBLE_VAULTS/vault_passbolt.yml

echo "Install Juniper Collection"
ansible-galaxy collection install juniper.device
