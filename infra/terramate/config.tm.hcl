stack {
  name        = "CS2023"
  description = "CS2023 Devops Infra"
  id = "team-stack"
}

globals {
  location = "eastus"
  domain_name = "cs2024.one"
  teams = [
    { id = "00", config = {} },
    # { id = "01", config = {} },
  ]
}
