variable "rg_location" {
  type        = string
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

variable "parent_dns" {
  type = object({
    main_dns_name = string
    name = string
    rg_name = string
  })
} 
