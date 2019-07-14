gcp = [
{{ range $i, $machine := (ds "config").machines -}}
{{if eq $machine.provider "gcp" -}}
    {
      name = "{{$machine.name}}"
      machine_type = "{{$machine.machineType}}"
      image = "{{$machine.image}}"
      zone = "{{if has $machine "zone"}}{{$machine.zone}}{{else}}us-east1-c{{end}}"
      domainRecordName = "{{if has $machine "domainRecordName"}}{{$machine.domainRecordName}}{{else}}{{$machine.name}}{{end}}"
  },
{{end -}}
{{ end }}
]

do = [
{{ range $i, $machine := (ds "config").machines -}}
{{if eq $machine.provider "do" -}}
    {
      name = "{{$machine.name}}"
      machine_type = "{{$machine.machineType}}"
      image = "{{$machine.image}}"
      region = "{{if has $machine "region"}}{{$machine.region}}{{else}}nyc2{{end}}"
      domainRecordName = "{{if has $machine "domainRecordName"}}{{$machine.domainRecordName}}{{else}}{{$machine.name}}{{end}}"
  },
{{end -}}
{{ end }}
]

domainName = "{{(ds "config").domainName}}"
username = "{{(ds "config").username}}"
privateSshKey = "{{if has (ds "config") "privateSshKey"}}{{(ds "config").privateSshKey}}{{else}}~/.ssh/id_rsa.pub{{end}}"

google_credentials = <<EOF
{{((ds "secrets" | json).gcp.credentials) | toJSON}}
EOF
google_project = "{{(ds "secrets" | json).gcp.project}}"

do_token = "{{(ds "secrets" | json).do.token}}"

cloudflare_email = "{{(ds "secrets" | json).cloudflare.email}}"
cloudflare_token = "{{(ds "secrets" | json).cloudflare.token}}"