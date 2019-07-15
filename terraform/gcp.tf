variable "google_project" {
  type = "string"
}

provider "google" {
  credentials = "${var.google_credentials}"
  project = "${var.google_project}"
  region  = "us-east1"
  zone    = "us-east1-c"
}

resource "google_compute_address" "static" {
  count = "${length(var.gcp)}"

  name = "ipv4-address"
}

resource "google_compute_network" "ios_dev_network" {
  name = "ios-dev-network"
}

resource "google_compute_firewall" "ssh" {
  name    = "ios-dev-network-allow-ssh"
  network = "${google_compute_network.ios_dev_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction = "INGRESS"
  # target_tags = ["ios-dev-network-allow-ssh"]
}

resource "google_compute_firewall" "rdp" {
  name    = "ios-dev-network-allow-rdp"
  network = "${google_compute_network.ios_dev_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  direction = "INGRESS"
  # target_tags   = ["ios-dev-network-allow-rdp"]
}

resource "google_compute_firewall" "icmp" {
  name    = "ios-dev-network-allow-icmp"
  network = "${google_compute_network.ios_dev_network.name}"

  allow {
    protocol = "icmp"
  }

  # target_tags   = ["ios-dev-network-allow-icmp"]
}

resource "google_compute_firewall" "mosh" {
  name    = "ios-dev-network-allow-mosh"
  network = "${google_compute_network.ios_dev_network.name}"

  allow {
    protocol = "udp"
    ports    = ["60000-61000"]
  }

  direction = "INGRESS"

  # source_tags = ["ios-dev-network-allow-mosh"]
}

# resource "google_compute_firewall" "internal" {
#   name    = "ios-dev-network-allow-internal"
#   network = "${google_compute_network.ios_dev_network.name}"

#   allow {
#     protocol = "udp"
#     ports    = ["60000-61000"]
#   }

#   direction = "INGRESS"
#   source_ranges = [" 10.128.0.0/9"]

#   source_tags = ["ios-dev-network-allow-mosh"]
# }

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
    network = "${google_compute_network.ios_dev_network.name}"
    access_config {
        nat_ip = "${google_compute_address.static[count.index].address}"
        # network_tier = "STANDARD"
    }
  }

  metadata = {
    sshKeys = "root:${file(pathexpand("${var.privateSshKey}.pub"))}"
  }

  connection {
    type        = "ssh"
    host        = self.network_interface.0.access_config.0.nat_ip
    user        = "root"
    private_key = "${file("${var.privateSshKey}")}"
  }
  
  # hack to make sure local exec runs after machine is ready
  provisioner "remote-exec" {
    inline = ["mkdir /opt/ios-dev-machine"]
  }

  provisioner "file" {
    content     = <<-EOF
                    {
                      "name": "${var.gcp[count.index].name}",
                      "user": "${var.username}",
                      "roles": ${var.gcp[count.index].ansibleRoles}
                    }
                  EOF
    destination = "/opt/ios-dev-machine/config.json"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i 'root@${self.network_interface[0].access_config.0.nat_ip},' --private-key ${var.privateSshKey} ../ansible/provision/provision.yml"
  }
}
