generate_hcl "main.tf" {
  content {
    locals {
      teams = global.teams
      location = global.location
      domain_name = global.domain_name
      dev_subdomain = global.dev_subdomain
      dev_domain_name = global.dev_domain_name
    }

    resource "random_id" "random" {
      byte_length = 8
    }

    resource "azurerm_resource_group" "global_rg" {
      location = local.location
      name     = "Global-rg"
    }

    resource "azurerm_dns_zone" "parent" {
      name                = local.dev_domain_name
      resource_group_name = azurerm_resource_group.global_rg.name

      depends_on = [ azurerm_resource_group.global_rg ]
    }

    resource "azurerm_dns_txt_record" "validation_record" {
      name                = "@"
      zone_name           = azurerm_dns_zone.parent.name
      resource_group_name = azurerm_resource_group.global_rg.name
      ttl                 = 3600
      
      record {
        value = "MS=ms96251819"
      }

      depends_on = [ azurerm_dns_zone.parent ]
    }

    resource "namecheap_domain_records" "namecheap_domain" {
      domain = local.domain_name
      mode = "OVERWRITE"
      # nameservers = azurerm_dns_zone.parent.name_servers

      record {
        hostname = local.dev_subdomain
        type = "NS"
        address = tolist(azurerm_dns_zone.parent.name_servers)[0]
        ttl = 60
      }

      depends_on = [ azurerm_dns_zone.parent  ]
    }

    module "team_module" {
      for_each = { for team in local.teams : team.id => team }

      source = "../modules/rg"

      random_id = random_id.random.hex
      team_name = each.value.id
      rg_location = local.location

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
        static_ip = tm_hcl_expression("module.team_module[\"${module.value.id}\"].ai_static_ip")
        rg_name = tm_hcl_expression("module.team_module[\"${module.value.id}\"].rg_name")

        source = "../modules/nginx"
        depends_on = [ tm_hcl_expression("module.team_module[\"${module.value.id}\"]") ]
        providers = {
          helm = tm_hcl_expression("helm.ai_${module.value.id}")
          kubectl = tm_hcl_expression("kubectl.ai_${module.value.id}")
          kubernetes = tm_hcl_expression("kubernetes.ai_${module.value.id}")
        }
      }
    }

    tm_dynamic "module" {
      for_each = global.teams

      labels = ["nginx_team_${module.value.id}"]

      content {
        static_ip = tm_hcl_expression("module.team_module[\"${module.value.id}\"].team_static_ip")
        rg_name = tm_hcl_expression("module.team_module[\"${module.value.id}\"].rg_name")

        source = "../modules/nginx"
        depends_on = [ tm_hcl_expression("module.team_module[\"${module.value.id}\"]") ]
        providers = {
          helm = tm_hcl_expression("helm.team_${module.value.id}")
          kubectl = tm_hcl_expression("kubectl.team_${module.value.id}")
          kubernetes = tm_hcl_expression("kubernetes.team_${module.value.id}")
        }
      }
    }
  }
}
