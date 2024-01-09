generate_hcl "main.tf" {
  content {
    locals {
      teams = global.teams
      location = global.location
      domain_name = global.domain_name
    }

    resource "random_id" "random" {
      byte_length = 8
    }

    resource "azurerm_resource_group" "global_rg" {
      location = local.location
      name     = "Global-rg"
    }

    resource "azurerm_dns_zone" "parent" {
      name                = local.domain_name
      resource_group_name = azurerm_resource_group.global_rg.name

      depends_on = [ azurerm_resource_group.global_rg ]
    }

    resource "namecheap_domain_records" "namecheap_domain" {
      domain = azurerm_dns_zone.parent.name
      mode = "OVERWRITE"
      nameservers = azurerm_dns_zone.parent.name_servers

      depends_on = [ azurerm_dns_zone.parent ]
    }

    # resource "azurerm_static_site" "site" {
    #   name                = "cs2024site"
    #   resource_group_name = azurerm_resource_group.global_rg.name
    #   location            = azurerm_resource_group.global_rg.location
    # }

    # resource "azurerm_dns_cname_record" "validation_cname" {
    #   name                = local.domain_name
    #   zone_name           = azurerm_dns_zone.parent.name
    #   resource_group_name = azurerm_resource_group.global_rg.name
    #   ttl                 = 300
    #   record              = azurerm_static_site.site.default_host_name
    # }

    # resource "azurerm_static_site_custom_domain" "custom_domain" {
    #   static_site_id  = azurerm_static_site.site.id
    #   domain_name     = "${azurerm_dns_cname_record.validation_cname.name}.${azurerm_dns_cname_record.validation_cname.zone_name}"
    #   validation_type = "cname-delegation"
    # }

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
