
#!#!# RANDOM: 
@/Users/joshc/.cursor/plans/yarn_nvm_lessons_learned_ee30d3d9.plan.md @dotfile-vnext/docs/plan/homelab_pattern_ubuntu.md  please put this with the like or make a note for the planner that these resources right here or examples of managing some of the infrastructure with him

These need to be placed inside of our library and are for downloading local and re-searching by the research agent for instance.

 ### Pattern:
  NetBox + NetBox Ansible Dynamic Inventory Plugin

 mkdir -p roles collections

ansible-galaxy collection install ansible.windows --collections-path ./collections
ansible-galaxy collection install community.windows --collections-path ./collections
ansible-galaxy collection install community.docker --collections-path ./collections

ansible-galaxy role install geerlingguy.docker --roles-path ./roles
ansible-galaxy role install geerlingguy.pip --roles-path ./roles
ansible-galaxy role install geerlingguy.security --roles-path ./roles
 
ansible-galaxy role install geerlingguy.docker --roles-path ./roles
# download collection to inspect locallly
ansible-galaxy collection install ansible.windows --collections-path ./collections
ansible-galaxy role install geerlingguy.docker --roles-path ./roles
ansible-galaxy collection install ansible.windows --collections-path ./collections
ansible-galaxy collection install community.windows --collections-path ./collections
What they give you
win_hyperv_guest

win_hyperv_host

win_feature

win_package

win_shell

win_command

Windows networking modules

Windows service modules

#######

# personal reference:
  https://github.com/timothystewart6/techno-tim.github.io/tree/master
  didd this whoe setup with k3s and trafick etc


 1. Search for roles
Code
ansible-galaxy role search hyperv | grep -i ubuntu
2. Pick one
Example: someauthor.hyperv_ubuntu_setup

3. Download it
Code
ansible-galaxy role install someauthor.hyperv_ubuntu_setup --roles-path ./roles
4. Inspect it
Code
tree ./roles/someauthor.hyperv_ubuntu_setup

# can curl collection 
# no result
curl -s "https://galaxy.ansible.com/api/v3/collections/?keywords=hyperv"
####
#####
 oliverprater.docker-ubuntu                                  Install Docker CE or EE on Ubuntu 14.04 LTS and 16.0>

  Qooh0.rbenv_ubuntu                                          rbenv system install to Directory 

   suzuki-shunsuke.docker-ubuntu                               Install docker on Ubuntu
    hamburger_software.vmware_ubuntu_cloud_image                Creates virtual machines based on Ubuntu Cloud Image>
     vermilion_tech.ansible_role_ubuntu_base                     Bootstraps Ubuntu Targets
      rosslopez.docker_ubuntu                                     Ansible role that installs Docker and Docker Compose>
       vinz2008.ubuntu_autoinstall                                 Generates an Ubuntu 20.04 Server ISO with a user-dat> 
        habdelazim743-collab.ubuntu_k8s_prereqs                     Install Docker and Kubernetes prerequisites on Ubuntu
         dottgonzo.add-ubuntu-ansible-extras                         add ansible deps for docker and kubernetes
          habdelazim743-collab.ubuntu_k8s_prereqs                     Install Docker and Kubernetes prerequisites on Ubuntu

# Search methods available or tested:

gh search code "ansible hyper-v ubuntu"
Step 2 — Search collections via API
curl -s "https://galaxy.ansible.com/api/v3/collections/?keywords=hyperv" \
  | jq '.data[] | select(.platforms | tostring | test("ubuntu"; "i"))'


(.venv) Joshs-MBP:dotfile-vnext joshc$ ansible-galaxy role search hyperv 

Found 4 roles matching your search:

 Name                            Description
 ----                            -----------
 andrelohmann.hetzner_hypervisor ansible galaxy to create a libvirt hypervisor and kvm VMs on a plain debian installe>
 egeneralov.hypervisor           Ensure target have hypervisor power
 nocsi.packer-rhel-hyperv        RedHat/CentOS configuration for Packer Hyper-V
 sgrech.role_hypervisor          Ansible role to provision virtualbox and vagrant on debian based distributions

 ansible-galaxy role search --platform windows 

servidor
  6nsh.docker                                                Install and configure Docker
