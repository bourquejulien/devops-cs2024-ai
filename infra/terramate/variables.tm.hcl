generate_hcl "variables.tf" {
  content {

    variable "namecheap_username" {
      type = string
    }

    variable "namecheap_key" {
      type = string
    }
  }
}
