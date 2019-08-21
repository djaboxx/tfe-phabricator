
variable "database_flags_default" {
  description = "Default flags to use for this database (you shouldn't normally change this)"

  default = [
    {
      name  = "general_log"
      value = "on"
    },
    {
      name  = "slow_query_log"
      value = "on"
    },
    {
      name  = "log_output"
      value = "FILE"
    },
    {
      name  = "long_query_time"
      value = "0.25"
    },
    {
      name  = "log_queries_not_using_indexes"
      value = "on"
    },
    {
      name  = "max_allowed_packet"
      value = 268435456
    },
    {
      # Not valid for our tier of hardware
      # {
      #   name  = "performance_schema"
      #   value = "on"
      # },
      name = "query_cache_type"

      value = 0
    },
    {
      name  = "query_cache_size"
      value = 0
    },
  ]

}

# resource "google_sql_user" "users" {
#  name     = "${var.db_user}"
#  instance = "${google_sql_database_instance.master.self_link}"
#  password = "${var.db_password}"
#}

# Typical CloudSQL (mysql edition) master/failover set
locals {
  character_set_flag = [
    {
      name  = "character_set_server"
      value = "${var.character_set}"
    },
  ]
}

#data "null_data_source" "auth_netw_allowed" {
#  inputs = {
#    name  = "phabricator"
#    value = "${data.google_compute_instance.appserver.network_interface.0.access_config.0.nat_ip}"
#  }
#}
resource "random_pet" "server" {}

resource "google_sql_database_instance" "master" {
  name             = "phabricator-${local.netenv}-${local.datacenter}-${random_pet.server.id}"
  database_version = "MYSQL_5_6"
  region           = "${local.gcloud_region}"

  # Needed right now if we want to use internal IPs
  lifecycle {
    ignore_changes = ["settings.0.ip_configuration"]
  }

  settings {
    tier              = "db-n1-standard-1"
    disk_autoresize   = true
    disk_size = 50
    replication_type  = "SYNCHRONOUS"
    activation_policy = "ALWAYS"

    database_flags = ["${concat(var.database_flags_default, local.character_set_flag)}"]

    backup_configuration {
      enabled            = true
      binary_log_enabled = true
      start_time         = "08:00"
    }

    maintenance_window {
      day  = 1
      hour = 20
    }

    ip_configuration {
      private_network = "${data.google_compute_instance.appserver.network_interface.0.network}"
      require_ssl = false
    }

    location_preference {
      zone = "${local.gcloud_zone}"
    }
  }
}

resource "google_sql_user" "phab" {
  depends_on = [
    "google_sql_database_instance.master"
  ]
  name     = "phab"
  instance = "${google_sql_database_instance.master.name}"
  password = "${var.phabricator_db_password}"
}

data "google_compute_instance" "appserver" {
  self_link = "${element(module.phabricator.compute_instances, 0)}"
}