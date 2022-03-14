resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096

}

data "cloudinit_config" "master_cloudinit" {
  gzip = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      "apt": {
        "sources": {
          "ansibleppa": {
            "source": "ppa:ansible/ansible"
          }
        }
      },
      "package_update": true,
      "packages": [
        "python3",
        "software-properties-common",
        "ansible",
        "python3-pip",
        "nfs-common"
      ],
      "ntp": {
        "enabled": true,
        "ntp_client": "chrony",
        "packages": ["chrony"]
      },
      "write_files": [
        {
          "path": "/home/azadmin/.ssh/id_rsa",
          "permissions": "0600",
          "owner": "azadmin:azadmin",
          "content": tls_private_key.ssh_key.private_key_pem,
          "defer": true
        },
        {
          "path": "/home/azadmin/.ssh/id_rsa.pub",
          "permissions": "0644",
          "owner": "azadmin:azadmin",
          "content": tls_private_key.ssh_key.public_key_openssh,
          "defer": true
        },
        {
          "path": "/home/azadmin/.ssh/config",
          "permissions": "0644",
          "owner": "azadmin:azadmin",
          "content": "StrictHostKeyChecking no",
          "defer": true
        },
        {
          "path": "/home/azadmin/.ssh/authorized_keys",
          "permissions": "0644",
          "owner": "azadmin:azadmin",
          "content": "${tls_private_key.ssh_key.public_key_openssh}\n ${file(var.public_key_path)}",
          "defer": true,
          "append": true
        },
        {
          "path": "/home/azadmin/cloudinit_finished",
          "permissions": "0644",
          "owner": "azadmin:azadmin",
          "content": "1",
          "defer": true
        }
      ],
      "runcmd": [
        ["pip3", "install", "kubernetes"]
      ]
    })
  }
}

data "cloudinit_config" "worker_cloudinit" {
  gzip = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      "package_update": true,
      "packages": [
        "nfs-common"
      ],
      "ntp": {
        "enabled": true,
        "ntp_client": "chrony",
        "packages": ["chrony"]
      },
      "write_files": [
        {
          "path": "/home/azadmin/.ssh/config",
          "permissions": "0644",
          "owner": "azadmin:azadmin",
          "content": "StrictHostKeyChecking no",
          "defer": true
        },
        {
          "path": "/home/azadmin/.ssh/authorized_keys",
          "permissions": "0644",
          "owner": "azadmin:azadmin",
          "content": "${tls_private_key.ssh_key.public_key_openssh}\n ${file(var.public_key_path)}",
          "defer": true,
          "append": true
        }
      ]
    })
  }
}
