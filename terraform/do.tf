variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "default" {
  name       = "terraform ios-dev"
  public_key = "${file(pathexpand("${var.privateSshKey}.pub"))}"
}

resource "digitalocean_droplet" "do-instances" {
  count = "${length(var.do)}"

  name   = "${var.do[count.index].name}"
  image  = "${var.do[count.index].image}"
  region = "${var.do[count.index].region}"
  size   = "${var.do[count.index].machine_type}"

  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
}