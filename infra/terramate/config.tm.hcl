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
    { id = "test1", config = {password = "$#2GFg7+pTrewerweVHk34xK!00"} },
    { id = "test2", config = {password = "$#2GFgwerew7+pTVHwrwkRO0xK!00"} },
    # { id = "01", config = {password = "$#2GFg7+pTVHkRO0xK!00"} },
    # { id = "02", config = {password = "$#3c1OFhmg79t2gySS!00"} },
    # { id = "03", config = {password = "$#AGY2zj8GCir1cffc!00"} },
    # { id = "04", config = {password = "$#N+FfyeE98BEC9n8A!00"} },
    # { id = "05", config = {password = "$#xIBMyrof4Xt9pNS9!00"} },
    # { id = "06", config = {password = "$#Pwowrc7YHXOUf6GD!00"} },
    # { id = "07", config = {password = "$#W054kHg2YVzNNsiZ!00"} },
    # { id = "08", config = {password = "$#0Z27hH59c7eblxip!00"} },
    # { id = "09", config = {password = "$#9JVgNLnbN9+bQbIl!00"} },
    # { id = "10", config = {password = "$#hvmxKmXLmEnAkaoA!00"} },
    # { id = "11", config = {password = "$#ylKoy02pdE1VVlKV!00"} },
    # { id = "12", config = {password = "$#ceYTPMR+NkDWm3DA!00"} },
    # { id = "13", config = {password = "$#fzUQdcGhb2pQgq+J!00"} },
    # { id = "14", config = {password = "$#5mxce0/3zOg+MZFY!00"} },
    # { id = "15", config = {password = "$#kC80luqvzanuSfFQ!00"} },
    # { id = "16", config = {password = "$#LjuLtIBGizlme3/M!00"} },
    # { id = "17", config = {password = "$#COPyT/Qyugh9hYxI!00"} },
    # { id = "18", config = {password = "$#Hrhtqs8BrMHL7wro!00"} },
    # { id = "19", config = {password = "$#THu92Hieh3W3kRdK!00"} },
    # { id = "20", config = {password = "$#E9S0WVxQRYaL8RZ+!00"} },
    # { id = "21", config = {password = "$#QyKbZkr207i1rCYt!00"} },
    # { id = "22", config = {password = "$#WbkadrS2VnGetC03!00"} },
  ]
}
