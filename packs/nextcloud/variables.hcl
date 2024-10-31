variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = ""
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = "default"
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}

variable "task_driver" {
  description = "Driver name for the task execution"
  type        = string
  default     = "podman"
}

variable "pause_image_tag" {
  description = "Pause infra. container image tag string"
  type        = string
  default     = "3.9"
}

variable "nginx_image_tag" {
  description = "Nginx proxy container image tag string; for options, see https://hub.docker.com/_/nginx"
  type        = string
  default     = "1.27.2-alpine"
}

variable "nextcloud_image_tag" {
  description = "NextCloud Server container image tag string; for options, see https://hub.docker.com/_/nextcloud"
  type        = string
  default     = "29.0.8-fpm-alpine"
}

variable "postgres_image_tag" {
  description = "PostgreSQL container image tag string; for options, see https://hub.docker.com/_/postgres"
  type        = string
  default     = "16.4-alpine"
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [
    {
      attribute = "$${attr.kernel.name}",
      operator  = "=",
      value     = "linux",
    },
  ]
}

variable "network" {
  description = "The group network configuration options."
  type = object({
    ports = list(object({
      name   = string
      to     = number
      static = number
    }))
  })
  default = {
    ports = [
      {
        "name" = "http",
        "to" = 80,
        "static" = 9001,
      },
      {
        "name" = "php_fpm",
        "to" = 9000,
        "static" = null,
      },
      {
        "name" = "postgres",
        "to" = 5432,
        "static" = null,
      }
    ]
  }
}

variable "web_service" {
  description = "Configuration for the Web proxy service."
  type = object({
    service_name       = string
    service_tags       = list(string)
    service_port_label = string
    check_name         = string
    check_type         = string
    check_path         = string
    check_interval     = string
    check_timeout      = string
  })
  default = {
    service_name       = "nextcloud-web"
    service_tags       = ["nextcloud"]
    service_port_label = "http"
    check_name         = "TCP response check"
    check_type         = "tcp"
    check_path         = null
    check_interval     = "30s"
    check_timeout      = "5s"
  }
}

variable "web_resources" {
  description = "The resource to assign to the Nginx proxy task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 100
  }
}

variable "app_resources" {
  description = "The resource to assign to the NextCloud app task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 250
  }
}

variable "db_resources" {
  description = "The resource to assign to the PostgreSQL database task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 100,
    memory = 100
  }
}

variable "external_ports_list" {
  description = "List of port labels to expose outside of the private allocation's network"
  type        = list(string)
  default = ["http"]
}

variable "app_env_vars" {
  description = "Nextcloud environment variables."
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {
      key = "POSTGRES_HOST"
      value = "localhost:5432"
    }
  ]
}

variable "db_env_vars" {
  description = "PostgreSQL environment variables."
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {
      key = "POSTGRES_DB"
      value = "nextcloud"
    },
    {
      key = "POSTGRES_USER"
      value = "postgres"
    },
    {
      key = "POSTGRES_PASSWORD"
      value = "SuPers3cur3"
    }
  ]
}

variable "web_volumes" {
  description = "Volumes assigned to the Nginx proxy task"
  type = list(object({
    source   = string
    target   = string
    readonly = bool
  }))
  default = [
    {
      source   = "/opt/volumes/nextcloud/html/data"
      target   = "/var/www/html/"
      readonly = false
    },
    {
      source   = "local/nginx.conf"
      target   = "/etc/nginx/nginx.conf"
      readonly = true
    }
  ]
}
variable "app_volumes" {
  description = "Volumes assigned to the NextCloud server task"
  type = list(object({
    source   = string
    target   = string
    readonly = bool
  }))
  default = [
    {
      source   = "/opt/volumes/nextcloud/html/data"
      target   = "/var/www/html/"
      readonly = false
    }
  ]
}

variable "db_volumes" {
  description = "Volumes assigned to the PostgreSQL task"
  type = list(object({
    source   = string
    target   = string
    readonly = bool
  }))
  default = [
    {
      source   = "/opt/volumes/nextcloud/postgresql/data"
      target   = "/var/lib/postgresql/data"
      readonly = false
    }
  ]
}

variable "prestart_directory_creation" {
  description = "Whether or not to launch a prestart task to create volume directories on the host."
  type        = bool
  default     = true
}

variable "app_data_source_path" {
  description = "Volume path on the host machine used for application data"
  type        = string
  default     = "/opt/volumes/nextcloud/html/data"
}

variable "db_volume_source_path" {
  description = "Volume path on the host machine used for database data"
  type        = string
  default     = "/opt/volumes/nextcloud/postgresql/data"
}
