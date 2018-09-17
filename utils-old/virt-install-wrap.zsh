#!/usr/bin/env zsh
set -u

end_index=0
typeset -A params

add(){
  params[${end_index}]="${1}"
  params[${1}]="${2:-}"
  let end_index++
}

add vcpu 2
add memory 500
add network bridge=virbr0
add virt-type kvm
add os-type linux
add os-variant
add name
add disk
add cdrom

for ((i=0; i < ${end_index}; i++)); do
  key="${params[${i}]}"

  case "${key}" in
    disk)
      params[disk]="/media/uplus/volume/vm/virt/${params[name]}.qcow2"
      ;;
  esac

  read input"?${key} [${params[${key}]}] => "

  case "${key}" in
    os-variant)
      if [[ -z $input || $input = 'list' ]]; then
        virt-install --os-variant=list | less
        let i--
        continue
      fi

      if [[ -z $(virt-install --os-variant=list | grep "^${input}\s\+") ]]; then
        echo "${input} is not support"
        let i--
        continue
      fi
      ;;
    name)
      if [[ -z $input ]]; then
        let i--
        continue
      fi
      ;;
    disk)
      if [[ -e ${params[disk]} ]]; then
        echo "${params[disk]} is already exists. Use it."
      else
        read disk_size'?Disk size? [5] =>'
        qemu-img create -f qcow2 "${params[disk]}" "${disk_size:-5}G"
      fi
      ;;
    cdrom)
      [[ -z $input ]] && continue

      if [[ ! -e $input ]]; then
        echo "${input} is not exist!"
        let i--
        continue
      fi

      if [[ ! -r $input ]]; then
        echo "${input} can not read!"
        let i--
        continue
      fi
      ;;
  esac

  if [[ -n $input ]]; then
    params[${key}]="${input}"
  fi
done

local -a arg
for ((i=0; i < ${end_index}; i++)); do
  key="${params[${i}]}"
  if [[ -z $params[$key] ]]; then
    continue
  fi

  arg+="--${key}=${params[${key}]}"
done

echo "${arg}"
virt-install ${arg}
