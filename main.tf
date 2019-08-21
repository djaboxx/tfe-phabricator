module "phabricator" {
  source  = "terraform.corp.clover.com/clover/service/google"
  version = "< 0.3.0"

  name              = "phabricator"
  endpoint_prefix   = "phabricator"
  region            = "${local.gcloud_region}"
  zone              = "${local.gcloud_zone}"
  datacenter        = "${local.datacenter}"
  subnetwork        = "${local.gcloud_subnetwork}"
  network_type      = "${local.netenv}"
  appenv            = "${local.appenv}"
  machine_type      = "${var.instance_type}"
  disk_size         = "${var.disk_size}"
  data_disk_size_gb = 0

  # FIXME: Should probably export these from the project module somehow
  dns_domain = "${local.netenv}.${local.datacenter}.clover.network."
  dns_zone   = "${local.netenv}-${local.datacenter}"

  tags = ["egress-web"]

  scopes = ["sql-admin"]

  # autocreates mdb entries, 'base' is just a basic system with no puppet role
  template = "artifactory"
}

resource "random_pet" "db_name" {}

resource "google_compute_disk" "phabricator_service_instances_data_disk_snapshot" {
  count    = "${var.launch_from_snapshot ? 1 : 0}"
  name     = "data-disk-phabricator01-${local.netenv}-${local.datacenter}"
  zone     = "${local.gcloud_zone}"
  type     = "pd-ssd"
  size     = "${var.data_disk_size_gb}"
  snapshot = "${var.data_disk_backup}"
  timeouts = {
    create = "20m"
  }
}

resource "google_compute_disk" "artifactory_service_instances_data_disk_image" {
  resource_policies = "${google_compute_resource_policy.artifactory-backup.self_link}"
  count = "${var.launch_from_snapshot ? 0 : 1}"
  name  = "data-disk-phabricator01-${local.netenv}-${local.datacenter}"
  zone  = "${local.gcloud_zone}"
  type  = "pd-ssd"
  size  = "${var.data_disk_size_gb}"
  image = "${var.data_disk_image}"
  timeouts = {
    create = "20m"
  }
}

resource "google_compute_attached_disk" "artifactory_service_instances_data_disk_image" {
  provider = "google-beta"
  resource_policies = "${google_compute_resource_policy.artifactory-backup.self_link}"
  count       = "${var.launch_from_snapshot ? 0 : 1}"
  disk        = "${element(google_compute_disk.artifactory_service_instances_data_disk_image.*.self_link, 1)}"
  instance    = "${element(module.artifactory.compute_instances, count.index)}"
  device_name = "gce-data-disk"
  mode        = "READ_WRITE"
}

resource "google_compute_attached_disk" "artifactory_service_instances_data_disk_snapshot" {
  provider = "google-beta"
  count       = "${var.launch_from_snapshot ? 1 : 0}"
  disk        = "${element(google_compute_disk.artifactory_service_instances_data_disk_snapshot.*.self_link, 1)}"
  instance    = "${element(module.artifactory.compute_instances, count.index)}"
  device_name = "gce-data-disk"
  mode        = "READ_WRITE"
}

resource "google_compute_resource_policy" "artifactory-backup" {
  name  = "data-disk-phabricator01-${local.netenv}-${local.datacenter}"
  provider = "google-beta"
  region = "${local.gcloud_region}"
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time = "04:00"
      }
    }
  }
}