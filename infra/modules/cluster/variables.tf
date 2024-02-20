variable "rg_name" {
    type = string
    description = "The name of the ressource group."
}

variable "rg_location" {
    type = string
    description = "The location of the ressource group."
}

variable "rg_id" {
    type = string
    description = "The id of the ressource group."
}

variable "subnet_id" {
    type = string
    description = "The id of the subnet."
}

variable "team_name" {
    type = string
    description = "The team name."
}

variable "side_name" {
    type = string
    description = "ai or team."
}

variable "random_id" {
    type = string
    description = "Random id to prevent name clashing."
}

variable "is_team_cluster" {
    type = bool
    description = "True for team cluster, false for AI cluster."
}

variable "parent_dns" {
  type = object({
    main_dns_name = string
    name = string
    rg_name = string
  })
} 
