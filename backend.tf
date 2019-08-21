terraform {
  backend "remote" {
    hostname = "terraform.corp.clover.com"
    organization = "clover"

    workspaces {
      prefix = "phabricator-"
    }
  }
}