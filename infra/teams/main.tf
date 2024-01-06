resource "random_id" "random" {
  byte_length = 8
}

module "infra_module" {
  for_each = toset([
    "00",
    ])

  random_id = random_id.random.hex
  team_name = "${each.key}"
  source = "../modules/rg"
}
