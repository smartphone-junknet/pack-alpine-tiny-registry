job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .nextcloud.datacenters | toJson ]]
  namespace   = [[ .nextcloud.namespace | quote ]]
  type        = "service"

  [[ template "constraints" .nextcloud.constraints ]]

  group "nextcloud" {
    network {
      [[- range $port := .nextcloud.network.ports ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.to ]]
        [[- if $port.static ]]
        static = [[ $port.static ]]
        [[- end ]]
      }
      [[- end ]]
    }
    [[- if .nextcloud.web_service -]]
    [[ template "service" .nextcloud.web_service ]]
    [[- end ]]

    task "pod" {
      lifecycle {
        hook    = "prestart"
        sidecar = "true"
      }
      driver = [[ .nextcloud.task_driver | quote ]]
      config {
        image = "registry.k8s.io/pause:[[ .nextcloud.pause_image_tag]]"
        ports = [[ .nextcloud.external_ports_list | toJson ]]
      }
      resources {
          cpu    = 10
          memory = 10
      }
    }

    task "proxy" {
      driver = [[ .nextcloud.task_driver | quote ]]
      config {
        image = "docker.io/library/nginx:[[ .nextcloud.nginx_image_tag ]]"
        [[- if gt (len .nextcloud.web_volumes) 0 ]]
        [[ template "volumes" .nextcloud.web_volumes ]]
        [[- end ]]
        network_mode = "task:pod"
      }
      template {
        destination = "local/nginx.conf"
        data        = file("./_nginix.conf")
      }
      [[ template "resources" .nextcloud.web_resources ]]
    }

    task "application" {
      driver = [[ .nextcloud.task_driver | quote ]]
      [[ template "env_vars" concat .nextcloud.app_env_vars .nextcloud.db_env_vars ]]
      config {
        image = "docker.io/library/nextcloud:[[ .nextcloud.nextcloud_image_tag ]]"
        [[- if gt (len .nextcloud.app_volumes) 0 ]]
        [[ template "volumes" .nextcloud.app_volumes ]]
        [[- end ]]
        network_mode = "task:pod"
        ports = ["php_fpm"]
      }
      [[ template "resources" .nextcloud.app_resources ]]
    }

    task "database" {
      driver = [[ .nextcloud.task_driver | quote ]]
      [[ template "env_vars" .nextcloud.db_env_vars ]]
      config {
        image = "docker.io/library/postgres:[[ .nextcloud.postgres_image_tag ]]"
        [[- if gt (len .nextcloud.db_volumes) 0 ]]
        [[ template "volumes" .nextcloud.db_volumes ]]
        [[- end ]]
        network_mode = "task:pod"
        ports = ["postgres"]
      }
      [[ template "resources" .nextcloud.db_resources ]]
    }

    [[ if .nextcloud.prestart_directory_creation -]]
    task "create-data-dirs" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }
      driver = "raw_exec"
      config {
        command = "sh"
        args = ["-c", "mkdir -p [[ .nextcloud.db_volume_source_path ]] && [[ .nextcloud.task_driver ]] unshare chown 1001:1001 [[ .nextcloud.db_volume_source_path ]] && mkdir -p [[ .nextcloud.app_data_source_path ]] && [[ .nextcloud.task_driver ]] unshare chown 1001:1001 [[ .nextcloud.app_data_source_path ]]"]
      }
      resources {
        cpu    = 10
        memory = 10
      }
    }
    [[- end ]]
  }
}
