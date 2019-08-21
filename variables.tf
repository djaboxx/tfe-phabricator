variable "vars_organization" {}

variable "vars_workspace" {}

variable "instance_type" {
  default = "n1-highmem-32"
}

variable "disk_size" {
  default = "100"
}

variable "db_instance_type" {
  default = "db-n1-standard-1"
}

variable "launch_from_snapshot" {
  default = false
}

variable "data_disk_image" {
  default = "projects/clover-images/global/images/family/clover-empty-xfs"
}

variable "data_disk_backup" {
  default = ""
}

variable "data_disk_size_gb" {
  default = 6188
}


variable "db_user" {}
variable "db_password" {}

variable "character_set" {
  description = "Value for character_set_server flag (character set for server)"
  default     = "latin1"
}

variable "database_flags_extra" {
  description = "Extra flags to be used for this database"
  default     = []
}

variable "phabricator_db_password" {
  description = "Phabricator MySQLdb Password"
}