# Configure the Cloudflare provider
variable "cloudflare_email" {
  type = "string"
}

variable "cloudflare_token" {
  type = "string"
}

variable "domainName" {
  type = "string"
}

provider "cloudflare" {
 email = "${var.cloudflare_email}"
 token = "${var.cloudflare_token}"
}

# Create A records for gcp instances
resource "cloudflare_record" "www-gcp" {
  count = "${length(var.gcp)}"

  domain = "${var.domainName}"
  name   = "${var.gcp[count.index].domainRecordName}"
  value  = "${google_compute_instance.gcp-instances[count.index].network_interface[0].access_config.0.nat_ip}"
  type   = "A"
}

# Create A records for do instances
resource "cloudflare_record" "www-do" {
  count = "${length(var.do)}"

  domain = "${var.domainName}"
  name   = "${var.do[count.index].domainRecordName}"
  value  = "${digitalocean_droplet.do-instances[count.index].ipv4_address}"
  type   = "A"
}