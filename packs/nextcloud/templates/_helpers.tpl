// allow nomad-pack to set the job name

[[ define "job_name" ]]
[[- if eq .nextcloud.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .nextcloud.job_name | quote -]]
[[- end ]]
[[- end ]]

// deploy to a region if specified

[[ define "region" -]]
[[- if not (eq .nextcloud.region "") -]]
  region = [[ .nextcloud.region | quote]]
[[- end -]]
[[- end -]]

// constraint list structure

[[ define "constraints" -]]
[[ range $idx, $constraint := . -]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    [[ if $constraint.operator -]]
    operator  = [[ $constraint.operator | quote ]]
    [[ end -]]
    value     = [[ $constraint.value | quote ]]
  }
[[- end -]]
[[- end -]]

// Nomad "service" block template
[[ define "service" -]]
[[ $service := . ]]
    service {
      provider = "nomad"
      name = [[ $service.service_name | quote ]]
      tags = [[ $service.service_tags | toJson ]]
      port = [[ $service.service_port_label | quote ]]
      check {
        name     = [[ $service.check_name | quote ]]
        type     = [[ $service.check_type | quote ]]
        [[- if $service.check_path]]
        path     = [[ $service.check_path | quote ]]
        [[- end]]
        interval = [[ $service.check_interval | quote ]]
        timeout  = [[ $service.check_timeout | quote ]]
      }
    }
[[- end ]]

// Generic env_vars template

[[ define "env_vars" -]]
      env {
        [[- range $idx, $var := . ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
[[- end ]]

// Generic container host volume template

[[ define "volumes" -]]
        volumes = [
        [[- range $idx, $volume := . ]]
          "[[ $volume.source ]]:[[ $volume.target ]][[ if $volume.readonly ]]:ro[[ end ]]",
        [[- end ]]
        ]
[[- end -]]

// Generic resources template

[[ define "resources" -]]
[[- $resources := . -]]
      resources {
        cpu    = [[ $resources.cpu ]]
        memory = [[ $resources.memory ]]
      }
[[- end ]]
