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
    { id = "test1", config = {password = "AStrongPassword$123!"} },
    { id = "01", config = {password = "pdt!jqd.vmz@GCF0bfj"} },
    { id = "02", config = {password = "mpf6pen.pht@jcb.JQA"} },
    { id = "03", config = {password = "dzp4kdn1xcf.vrf.JPG"} },
    { id = "04", config = {password = "DEH7wjh.rnc@exm6jau"} },
    { id = "05", config = {password = "NKP1rxb7urn!uya2cmq"} },
    { id = "06", config = {password = "NZD*reg3ufh7qrw0acn"} },
    { id = "07", config = {password = "jza4cmp-zhv7BRF1qwa"} },
    { id = "08", config = {password = "zfx0vzr.HBZ-kqj2rqb"} },
    { id = "09", config = {password = "zbf.xgf2end.qch*CQM"} },
    { id = "10", config = {password = "EUJ!jrh-bpy5htk2cgj"} },
    { id = "11", config = {password = "jtm*PUT4ecz2wfp.fbv"} },
    { id = "12", config = {password = "zfd-nek!UEP7xme4fxy"} },
    { id = "13", config = {password = "qva9YPQ@ene@dzf-mcd"} },
    { id = "14", config = {password = "DRX5adp7xnv.puv!bhv"} },
    { id = "15", config = {password = "nyd7RDH*vag5rpd!ctb"} },
    { id = "16", config = {password = "JWN1zdt1tqw5bgd_xqg"} },
    { id = "17", config = {password = "knt9XMW0jtj8pyn!cad"} },
    { id = "18", config = {password = "UVC1jue7wmj3ayu-han"} },
    { id = "19", config = {password = "qpu5TVH!mku.ncg0erx"} },
    { id = "20", config = {password = "ubz4PEN5ena.fdz4vjv"} },
    { id = "21", config = {password = "ABZ6ftd@tcj_prx4rhj"} },
    { id = "22", config = {password = "kjn!aru1PDK-xab!qkq"} }
  ]
}
