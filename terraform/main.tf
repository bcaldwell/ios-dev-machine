variable "google_credentials" {
  type = "string"
}

data "terraform_remote_state" "state" {
  backend = "gcs"
  config = {
    bucket  = "tf-state-ios-dev-machine"
    prefix  = "ios-dev-machine/terraform/state"
    credentials = "${var.google_credentials}"
  }
}

variable "gcp" {
  type = "list"
  default = []
}

variable "do" {
  type = "list"
  default = []
}

variable "username" {
  type = "string"
  default = "root"
}

variable "privateSshKey" {
  type = "string"
  default = "ios-dev"
}

