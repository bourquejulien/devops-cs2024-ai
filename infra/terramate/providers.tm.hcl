generate_hcl "providers.tf" {
  content {
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~>3.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "~>3.0"
        }
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = ">= 2.0.3"
        }
        helm = {
          source  = "hashicorp/helm"
          version = ">= 2.1.0"
        }
        kubectl = {
          source  = "gavinbunney/kubectl"
          version = ">= 1.7.0"
        }
        namecheap = {
          source = "namecheap/namecheap"
          version = ">= 2.0.0"
        }
      }
    }

    provider "azurerm" {
      features {
        resource_group {
          prevent_deletion_if_contains_resources = false
        }
      }
    }

    provider "namecheap" {
      user_name = var.namecheap_username
      api_user = var.namecheap_username
      api_key = var.namecheap_key
      use_sandbox = false
    }

    tm_dynamic "provider" {
      for_each = global.teams

      labels = ["kubernetes"]

      content {
        alias                  = "ai_${provider.value.id}"
        host                   = tm_hcl_expression("module.team_module[\"${provider.value.id}\"].ai_kube_host")
        client_key             = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].ai_kube_client_key)")
        client_certificate     = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].ai_kube_client_certificate)")
        cluster_ca_certificate = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].ai_kube_ca_certificate)")
      }
    }

    tm_dynamic "provider" {
      for_each = global.teams

      labels = ["kubernetes"]

      content {
        alias                  = "team_${provider.value.id}"
        host                   = tm_hcl_expression("module.team_module[\"${provider.value.id}\"].team_kube_host")
        client_key             = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].team_kube_client_key)")
        client_certificate     = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].team_kube_client_certificate)")
        cluster_ca_certificate = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].team_kube_ca_certificate)")
      }
    }

    tm_dynamic "provider" {
      for_each = global.teams

      labels = ["kubectl"]

      content {
        alias                  = "ai_${provider.value.id}"
        host                   = tm_hcl_expression("module.team_module[\"${provider.value.id}\"].ai_kube_host")
        client_key             = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].ai_kube_client_key)")
        client_certificate     = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].ai_kube_client_certificate)")
        cluster_ca_certificate = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].ai_kube_ca_certificate)")
        load_config_file       = false
      }
    }

    tm_dynamic "provider" {
      for_each = global.teams

      labels = ["kubectl"]

      content {
        alias                  = "team_${provider.value.id}"
        host                   = tm_hcl_expression("module.team_module[\"${provider.value.id}\"].team_kube_host")
        client_key             = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].team_kube_client_key)")
        client_certificate     = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].team_kube_client_certificate)")
        cluster_ca_certificate = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].team_kube_ca_certificate)")
        load_config_file       = false
      }
    }

    tm_dynamic "provider" {
      for_each = global.teams

      labels = ["helm"]

      content {
        alias                    = "ai_${provider.value.id}"
        kubernetes {
          host                   = tm_hcl_expression("module.team_module[\"${provider.value.id}\"].ai_kube_host")
          client_key             = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].ai_kube_client_key)")
          client_certificate     = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].ai_kube_client_certificate)")
          cluster_ca_certificate = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].ai_kube_ca_certificate)")
        }
      }
    }

    tm_dynamic "provider" {
      for_each = global.teams

      labels = ["helm"]

      content {
        alias                    = "team_${provider.value.id}"
        kubernetes {
          host                   = tm_hcl_expression("module.team_module[\"${provider.value.id}\"].team_kube_host")
          client_key             = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].team_kube_client_key)")
          client_certificate     = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].team_kube_client_certificate)")
          cluster_ca_certificate = tm_hcl_expression("base64decode(module.team_module[\"${provider.value.id}\"].team_kube_ca_certificate)")
        }
      }
    }
  }
}
