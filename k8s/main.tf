terraform {
  required_version = ">= 0.12.5"
}

# ubuntu archive
data sakuracloud_archive "ubuntu-archive" {
  os_type = "ubuntu"
}

# pub key
resource sakuracloud_ssh_key_gen "key"{
  name = "k8s_pubkey"

  provisioner "local-exec" {
    command = "echo \"${self.private_key}\" > id_rsa; chmod 0600 id_rsa"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f id_rsa"
  }
}

# switch
resource sakuracloud_switch "k8s-external-switch" {
  name = "k8s-external-switch"
}

resource sakuracloud_switch "k8s-internal-switch" {
  name = "k8s-internal-switch"
}

# disks
resource sakuracloud_disk "k8s-master-01-disk" {
  name              = "k8s-master-01-t"
  source_archive_id = "${data.sakuracloud_archive.ubuntu-archive.id}"
  size              = 100
}

resource sakuracloud_disk "k8s-node-01-disk" {
  name              = "k8s-node-01-t"
  source_archive_id = "${data.sakuracloud_archive.ubuntu-archive.id}"
  size              = 100
}

resource sakuracloud_disk "k8s-node-02-disk" {
  name              = "k8s-node-02-t"
  source_archive_id = "${data.sakuracloud_archive.ubuntu-archive.id}"
  size              = 100
}

resource sakuracloud_disk "k8s-node-03-disk" {
  name              = "k8s-node-03-t"
  source_archive_id = "${data.sakuracloud_archive.ubuntu-archive.id}"
  size              = 100
}

resource sakuracloud_disk "k8s-node-04-disk" {
  name              = "k8s-node-04-t"
  source_archive_id = "${data.sakuracloud_archive.ubuntu-archive.id}"
  size              = 100
}
# servers
resource sakuracloud_server "k8s-master-01-server" {
  name            = "k8s-master-01-server-t"
  hostname        = "k8s-master-01-server-t"
  core            = 8
  memory          = 32
  disks           = ["${sakuracloud_disk.k8s-master-01-disk.id}"]
  nic             = "shared"
  additional_nics = ["${sakuracloud_switch.k8s-internal-switch.id}"]
  additional_display_ipaddresses = ["192.168.100.1"]
  ssh_key_ids     = ["${sakuracloud_ssh_key_gen.key.id}"]
}


resource sakuracloud_server "k8s-node-01-server" {
  name            = "k8s-node-01-server-t"
  hostname        = "k8s-node-01-server-t"
  core            = 8
  memory          = 32
  disks           = ["${sakuracloud_disk.k8s-node-01-disk.id}"]
  nic             = "shared"
  additional_nics = ["${sakuracloud_switch.k8s-internal-switch.id}"]
  additional_display_ipaddresses = ["192.168.100.2"]
  ssh_key_ids     = ["${sakuracloud_ssh_key_gen.key.id}"]
}

resource sakuracloud_server "k8s-node-02-server" {
  name            = "k8s-node-02-server-t"
  hostname        = "k8s-node-02-server-t"
  core            = 8
  memory          = 32
  disks           = ["${sakuracloud_disk.k8s-node-02-disk.id}"]
  nic             = "shared"
  additional_nics = ["${sakuracloud_switch.k8s-internal-switch.id}"]
  additional_display_ipaddresses = ["192.168.100.3"]
  ssh_key_ids     = ["${sakuracloud_ssh_key_gen.key.id}"]
}

resource sakuracloud_server "k8s-node-03-server" {
  name            = "k8s-node-03-server-t"
  hostname        = "k8s-node-03-server-t"
  core            = 8
  memory          = 32
  disks           = ["${sakuracloud_disk.k8s-node-03-disk.id}"]
  nic             = "shared"
  additional_nics = ["${sakuracloud_switch.k8s-internal-switch.id}"]
  additional_display_ipaddresses = ["192.168.100.4"]
  ssh_key_ids     = ["${sakuracloud_ssh_key_gen.key.id}"]
}

resource sakuracloud_server "k8s-node-04-server" {
  name            = "k8s-node-04-server-t"
  hostname        = "k8s-node-04-server-t"
  core            = 8
  memory          = 32
  disks           = ["${sakuracloud_disk.k8s-node-04-disk.id}"]
  nic             = "shared"
  additional_nics = ["${sakuracloud_switch.k8s-internal-switch.id}"]
  additional_display_ipaddresses = ["192.168.100.5"]
  ssh_key_ids     = ["${sakuracloud_ssh_key_gen.key.id}"]
}

output "k8s-master-01-server_ipaddress"{
  value = "${sakuracloud_server.k8s-master-01-server.ipaddress}"
}

output "k8s-node-01-server_ipaddress"{
  value = "${sakuracloud_server.k8s-node-01-server.ipaddress}"
}

output "k8s-node-02-server_ipaddress"{
  value = "${sakuracloud_server.k8s-node-02-server.ipaddress}"
}

output "k8s-node-03-server_ipaddress"{
  value = "${sakuracloud_server.k8s-node-03-server.ipaddress}"
}

output "k8s-node-04-server_ipaddress"{
  value = "${sakuracloud_server.k8s-node-04-server.ipaddress}"
}
