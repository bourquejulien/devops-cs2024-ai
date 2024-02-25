stack {
  name        = "CS2024"
  description = "CS2024 Devops Infra"
  id = "team-stack"
}

globals {
  location = "eastus"
  domain_name = "cs2024.one"
  dev_subdomain = "dev"
  dev_domain_name = "${global.dev_subdomain}.${global.domain_name}"
  teams = [
    { id = "00", config = {} },
    # { id = "01", config = {} },
  ]
}
