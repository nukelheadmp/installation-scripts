_ansible-passbolt() {
  local localhost
  local directory

  if [[ "$1" == "local" ]]; then
    localhost=1
    directory="servers"
  else
    localhost=0
    directory="$1"
  fi
  shift

  if [[ -z "$1" ]]; then
    echo -e "Usage: ansible-${directory} <playbook> [options...]"
    return 1
  fi

  if [[ "$PWD" != "${PROJECTSDIR}/ansible-${directory}" ]]; then
    echo -e " -> Moving to ansible directory..."
    cd ${PROJECTSDIR}/ansible-${directory}
  fi

  local playbook="playbooks/${1}"

  if [[ ! -f "${playbook}" ]]; then
    echo -e "Error: Playbook not found: ${playbook}"
    return 1
  fi

  if [[ -z "${VIRTUAL_ENV:-}" || "${VIRTUAL_ENV}" != "${PYENV_PATH}/ansible" ]]; then
    activate ansible
  fi

  if [[ $localhost == 1 ]]; then
    ansible-playbook "$playbook" "${@:2}" \
      -i "localhost," -c local \
      --ask-become-pass
  else
    ansible-playbook "$playbook" "${@:2}" \
      -i inventories/production/ \
      --extra-vars @~/.ansible/vaults/vault_passbolt.yml \
      --ask-vault-pass
  fi
}

ansible-local() { _ansible-passbolt local "$@"; }
ansible-servers() { _ansible-passbolt servers "$@"; }
ansible-network() { _ansible-passbolt network "$@"; }
