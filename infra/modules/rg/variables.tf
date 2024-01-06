variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "team_name" {
    type = string
    default = "00"
    description = "team_name"
}

variable "random_id" {
    type = string
    description = "Random id to prevent name clashing."
}
