provider "google" {
  version     = "~> 2.5"
  credentials = "${data.terraform_remote_state.vars.credentials}"
  project     = "${local.gcloud_project}"
}

provider "google-beta" {
  version     = "~> 2.5"
  credentials = "${data.terraform_remote_state.vars.credentials}"
  project     = "${local.gcloud_project}"
}
