generate_hcl "main.tf" {
  content {
    locals {
      teams = global.teams
    }

    resource "random_id" "random" {
      byte_length = 8
    }

    module "team_module" {
      for_each = { for team in local.teams : team.id => team }

      source = "../modules/rg"

      random_id = random_id.random.hex
      team_name = each.value.id
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
