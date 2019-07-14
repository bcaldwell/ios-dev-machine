variable "google_credentials" {
  type = "string"
}

variable "google_project" {
  type = "string"
}

provider "google" {
  credentials = "${var.google_credentials}"
  project = "${var.google_project}"
  region  = "us-east1"
  zone    = "us-east1-c"
}

resource "google_compute_instance" "gcp-instances" {
  count = "${length(var.gcp)}"

  name         = "${var.gcp[count.index].name}"
  machine_type = "${var.gcp[count.index].machine_type}"
  zone         = "${var.gcp[count.index].zone}"

  boot_disk {
    initialize_params {
      image = "${var.gcp[count.index].image}"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "default"
    access_config {
    }
  }

  metadata = {
    sshKeys = "${var.username}:${file(pathexpand("${var.privateSshKey}.pub"))}"
  }

  # hack to make sure local exec runs after machine is ready
  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      host        = self.network_interface.0.access_config.0.nat_ip
      user        = "${var.username}"
      private_key = "${file("${var.privateSshKey}")}"
    }
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${var.username}@${self.network_interface[0].access_config.0.nat_ip},' --private-key ${var.privateSshKey} ../ansible/provision/provision.yml"
  }
}
