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

variable "parent_dns" {
  type = object({
    name = string
    rg_name = string
  })
} 
