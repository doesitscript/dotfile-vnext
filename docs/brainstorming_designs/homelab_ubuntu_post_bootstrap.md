Ubuntu Guest Provisioning (inside the VM)
Once the VM boots, you need to bootstrap it.

Roles
Code
geerlingguy.pip
geerlingguy.security
angstwad.ubuntu_python_apt
AdnanHodzic.python-ubuntu-bootstrap
Patterns
First task: ensure Python exists

Second: ensure SSH is configured

Third: ensure apt is sane

Fourth: install Docker

Fifth: install K3s