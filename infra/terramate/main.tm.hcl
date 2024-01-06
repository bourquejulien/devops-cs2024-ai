generate_hcl "main.tf" {
  content {
    locals {
      teams = global.teams
    }

    resource "random_id" "random" {
      byte_length = 8
    }

    resource "azurerm_resource_group" "global_rg" {
      location = "eastus"
      name     = "Global-rg"
    }

    resource "azurerm_dns_zone" "parent" {
      name                = "cs2024.one"
      resource_group_name = azurerm_resource_group.global_rg.name

      depends_on = [ azurerm_resource_group.global_rg ]
    }

    resource "namecheap_domain_records" "namecheap_domain" {
      domain = azurerm_dns_zone.parent.name
      mode = "OVERWRITE"
      nameservers = azurerm_dns_zone.parent.name_servers

      depends_on = [ azurerm_dns_zone.parent ]
    }

    module "team_module" {
      for_each = { for team in local.teams : team.id => team }

      source = "../modules/rg"

      random_id = random_id.random.hex
      team_name = each.value.id

      parent_dns = {
        name = azurerm_dns_zone.parent.name
        rg_name = azurerm_resource_group.global_rg.name
      }

      depends_on = [ azurerm_dns_zone.parent, azurerm_resource_group.global_rg]
    }

    tm_dynamic "module" {
      for_each = global.teams

      labels = ["nginx_ai_${module.value.id}"]

      content {
        source = "../modules/nginx"
        providers = {
          helm = tm_hcl_expression("helm.ai_${module.value.id}")
          kubectl = tm_hcl_expression("kubectl.ai_${module.value.id}")
          kubernetes = tm_hcl_expression("kubernetes.ai_${module.value.id}")
        }
      }
    }
  }
}
