module "infra_module" {
  for_each = toset([
    "00",
    ])

  source = "../module"

  team_name = "${each.key}"
}
