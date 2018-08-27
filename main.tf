variable "region" {
  default = "GRA3"
}

provider "openstack" {
  region = "${var.region}"
}

data "openstack_networking_subnet_v2" "subnet" {
  name = "workstation-network_subnet_0"
}

resource "openstack_networking_port_v2" "port_private_docker" {
  count          = "1"
  name           = "port_docker_workstation"
  network_id     = "${data.openstack_networking_subnet_v2.subnet.network_id}"
  admin_state_up = "true"

  fixed_ip {
    subnet_id = "${data.openstack_networking_subnet_v2.subnet.id}"
  }
}

resource "openstack_blockstorage_volume_v2" "volume_docker" {
  name = "volume_docker"
  size = 100
}

resource "openstack_compute_volume_attach_v2" "va_1" {
  instance_id = "${openstack_compute_instance_v2.docker.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.volume_docker.id}"
}

resource "openstack_compute_instance_v2" "docker" {
  count       = 1
  name        = "docker-workstation"
  image_name  = "Centos 7"
  flavor_name = "c2-7"
  key_pair    = "workstation-keypair"

  user_data   = <<USERDATA
#cloud-config
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVVg+yvpuhUa+Wl1MEaZoO5hjszmNTo+Dbq74+Wh8ZTKP8dfhlddq9mn22/Ddf9Qs3ilNct2TSOD5gEXQQry1H/lPiYQ7HcJZg4Z13qnsNO+owJu3JEReEIVba1mVQkST2ON32tMHaNRBFyrHqLgk0P8VmnkrjFMVAfbJ0eu4VgXt3Xe3vPoqg6DiYqPTA0jc5vb2thS9GeuxhuSeEy845/fbrVGzLwamaH6LbBZpiVuP4CJmNEDPqJVxyzycqZSi5bKgkvX49/fdBa8gGfH5Fq4seDU9uddynCyt7zY4PWKbIsRoDRu1vD9+CvpyApbNVZFRNosBoAyPrbOWwK1+5
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRjKIKAb/1NQV/mAmGEMzSLnPFvkRW85fqruYT6KnoFGLjaf5ArVpQ2OczsVnG5hyMi1l/17Slkzpzl6hyPDjuLG0YkP6t7uoK4+sS2/eIfkwVUroB8rx5q2GrbnyMJJOeH7ljlAzof4zqV9wMCirE+s2xTxZLsTPUCxOWIyvtOcE/NDSfbMYsoJDSN0j7KmAqE5QFfN8zY05ULG2zdv33XvHtB0vnX+zoMjmCrDjcOnTm0JDcerUyYMrOLJth+rsSvOHQL7GiNiA2BDTRpMZr88Gu4KuMzLpZLmzmdVn1EiYlLjB38RyQw1bowKBPDtQCatSyAPBJX989570WvJL3

## This route has to be added in order to reach other subnets of the network
bootcmd:
  - ip route add 10.1.0.0/16 dev eth0 scope link metric 0
write_files:
  - path: /etc/sysconfig/network-scripts/route-eth0
    content: |
      10.1.0.0/16 dev eth0 scope link metric 0
USERDATA

  network {
    port = "${openstack_networking_port_v2.port_private_docker.id}"
  }
}



resource "null_resource" "setup" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    instance_id = "${openstack_compute_instance_v2.docker.id}"
  }

  connection {
    type = "ssh"
    user = "centos"
    host = "${openstack_compute_instance_v2.docker.access_ip_v4}"
  }

  provisioner "file" {
    source = "profile"
    destination = "/home/centos/.profile"
  }

  provisioner "file" {
    source = "setup-vim.sh"
    destination = "/tmp/setup-vim.sh"
  }

  provisioner "file" {
    source = "setup-tmux.sh"
    destination = "/tmp/setup-tmux.sh"
  }

  provisioner "file" {
    source = "setup-docker.sh"
    destination = "/tmp/setup-docker.sh"
  }

  provisioner "file" {
    source = "setup-emacs.sh"
    destination = "/tmp/setup-emacs.sh"
  }

  provisioner "file" {
    source = "emacsclient"
    destination = "/tmp/emacsclient"
  }

  provisioner "file" {
    destination = "/tmp/setup.sh"
    content = <<EOF
sudo yum update -y
sudo yum groupinstall -y "Development Tools"
sudo yum install -y python34-pip bc zsh
(cd /home/centos && git clone https://github.com/openmaptiles/openmaptiles)
# keep ohmyzsh install at the end because it changes the shell thus breaks the script
sudo chsh -s /bin/zsh centos
ln -s /home/centos/.profile /home/centos/.zprofile
sudo -u centos sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
EOF
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "sh /tmp/setup.sh",
      "sh /tmp/setup-docker.sh",
      "sh /tmp/setup-emacs.sh",
      "sh /tmp/setup-vim.sh",
      "sh /tmp/setup-tmux.sh",
    ]
  }
}
