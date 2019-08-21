data "terraform_remote_state" "vars" {
  backend = "atlas"

  config {
    name = "${var.vars_organization}/${var.vars_workspace}"
  }
}

locals {
  gcloud_region        = "${data.terraform_remote_state.vars.gcloud_region}"
  gcloud_zone          = "${data.terraform_remote_state.vars.gcloud_zone}"
  datacenter           = "${data.terraform_remote_state.vars.datacenter}"
  gcloud_subnetwork    = "${data.terraform_remote_state.vars.gcloud_subnetwork}"
  netenv               = "${data.terraform_remote_state.vars.netenv}"
  appenv               = "${data.terraform_remote_state.vars.appenv}"
  shared_network_host  = "${data.terraform_remote_state.vars.shared_network_host}"
  gcloud_zone_failover = "${data.terraform_remote_state.vars.gcloud_zone_failover}"
  gcloud_project       = "${data.terraform_remote_state.vars.gcloud_project}"
}

data "google_compute_network" "default" {
  name    = "default"
  project = "${local.shared_network_host}"
}
