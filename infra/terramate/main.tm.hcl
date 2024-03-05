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

    module "global_module" {
      source = "../modules/global"

      random_id = random_id.random.hex
      location = local.location
      domain_name = local.domain_name
      dev_subdomain = local.dev_subdomain
      dev_domain_name = local.dev_domain_name
    }

    module "team_module" {
      for_each = { for team in local.teams : team.id => team }

      source = "../modules/rg"

      random_id = random_id.random.hex
      team_name = each.value.id
      rg_location = local.location
      ai_acr_id = module.global_module.ai_acr_id
      team_user_password = each.value.config.password

      parent_dns = {
        main_dns_name = local.domain_name
        name = module.global_module.parent_dns_name
        rg_name = module.global_module.rg_name
      }

      depends_on = [module.global_module]
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
