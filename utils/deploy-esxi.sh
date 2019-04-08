#!/bin/sh

datastore_dir="/vmfs/volumes/${1:? datastore name}"
base_vm_dir="${2:? base vm relative dir}"
new_vm_name="${3:?new vm name}"

cd "${datastore_dir}"
vmdk_name="$(ls "${base_vm_dir}/" | grep -E 'vmdk$' | grep -Ev 'flat.vmdk$')"
vmx_name="$(ls "${base_vm_dir}/" | grep -E 'vmx$')"

mkdir -p "${new_vm_name}"
vmkfstools -i "${base_vm_dir}/${vmdk_name}" -d thin "${new_vm_name}/${vmdk_name}"
find "${base_vm_dir}/" -not -name "*.vmdk" -exec cp {} "${new_vm_name}/" \;

vim-cmd solo/registervm "${datastore_dir}/${new_vm_name}/${vmx_name}" "${new_vm_name}"
