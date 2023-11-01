# Nextcloud

Nextcloud is a suite of software for productivity and file management.

It is community-driven, free, and open source. It can be thought of as an OSS GSuite.

This pack will deploy on the same host a Nginx reverse proxy, NextCloud Server and PostgreSQL database and will expose by default the application over HTTP on port `9001`.

## Dependencies

This pack assumes that at least Nomad `1.6` is installed on the host it is deployed to; moreover, that is also assumed to be a Linux host. Finally, this pack will use Nomad's built-in service registry feature, and will persist container volumes under the host path `/opt/volumes`.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | The name to use as the job name which overrides using the pack name. | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace where the job should be placed. | `string` | `"default"` | no |
| <a name="input_datacenters"></a> [datacenters](#input\_datacenters) | A list of datacenters in the region which are eligible for task placement. | `list(string)` | <pre>[<br>  "dc1"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the job should be placed. | `string` | `"global"` | no |
| <a name="input_task_driver"></a> [region](#input\_task\_driver) | Driver name for the task execution, | `string` | `"podman"` | no |
| <a name="input_pause_image_tag"></a> [pause\_image\_tag](#input\_pause\_image\_tag) | Pause infra. container image tag string | `string` | `"3.9"` | no |
| <a name="input_nginx_image_tag"></a> [nginx\_image\_tag](#input\_nginx\_image\_tag) | Nginx proxy container image tag string; for options, see [here](https://hub.docker.com/_/nginx) | `string` | `"1.25.3-alpine"` | no |
| <a name="input_nextcloud_image_tag"></a> [nextcloud\_image\_tag](#input\_nextcloud\_image\_tag) | NextCloud Server container image tag string; for options, see [here](https://hub.docker.com/_/nextcloud) | `string` | `"27.1.3-fpm-alpine"` | no |
| <a name="input_postgres_image_tag"></a> [postgres\_image\_tag](#input\_postgres\_image\_tag) | PostgreSQL container image tag string; for options, see [here](https://hub.docker.com/_/postgres) | `string` | `"15.4-alpine"` | no |
| <a name="input_constraints"></a> [constraints](#input\_constraints) | Constraints to apply to the entire job. | <pre>list(object({<br>    attribute = string<br>    operator  = string<br>    value     = string<br>  }))</pre> | <pre>[<br>  {<br>    "attribute": "$${attr.kernel.name}",<br>    "operator": "=",<br>    "value": "linux"<br>  }<br>]</pre> | no |
| <a name="input_network"></a> [network](#input\_network) | The group network configuration options. | <pre>object({<br>    ports = list(object({<br>      name   = string<br>      to     = number<br>      static = number<br>    }))<br>  })</pre> | <pre>{<br>  "ports": [<br>    {<br>      "name": "http",<br>      "to": 80,<br>      "static": 9001,<br>    },<br>      "name": "php_fpm",<br>      "to": 9000,<br>      "static": null,<br>    },<br>    {<br>      "name": "postgres",<br>      "to": 5432<br>      "static": null,<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_web_service"></a> [web\_service](#input\_web\_service) | Configuration for the Web proxy service. | <pre>object({<br>    service_name       = string<br>    service_tags       = list(string)<br>    service_port_label = string<br>    check_name         = string<br>    check_type         = string<br>    check_path         = string<br>    check_interval     = string<br>    check_timeout      = string<br>  })</pre> | <pre>object({<br>    service_name       = "nextcloud-web"<br>    service_tags       = ["nextcloud"]<br>    service_port_label = "http"<br>    check_name         = "TCP response check"<br>    check_type         = "tcp"<br>    check_path         = null<br>    check_interval     = "30s"<br>    check_timeout      = "5s"<br>  })</pre> | no |
| <a name="input_web_resources"></a> [web\_resources](#input\_web\_resources) | The resource to assign to the Nginx proxy task. | <pre>object({<br>    cpu    = number<br>    memory = number<br>  })</pre> | <pre>{<br>  "cpu": 200,<br>  "memory": 100<br>}</pre> | no |
| <a name="input_app_resources"></a> [app\_resources](#input\_app\_resources) | The resource to assign to the NextCloud app task. | <pre>object({<br>    cpu    = number<br>    memory = number<br>  })</pre> | <pre>{<br>  "cpu": 200,<br>  "memory": 250<br>}</pre> | no |
| <a name="input_db_resources"></a> [db\_resources](#input\_db\_resources) | The resource to assign to the PostgreSQL database task. | <pre>object({<br>    cpu    = number<br>    memory = number<br>  })</pre> | <pre>{<br>  "cpu": 100,<br>  "memory": 100<br>}</pre> | no |
| <a name="input_external_ports_list"></a> [external\_ports\_list](#input\_external\_ports\_list) | List of port labels to expose outside of the private allocation's network | `list(string)` | <pre>[<br>  "http"<br>]</pre> | no |
| <a name="input_app_env_vars"></a> [app\_env\_vars](#input\_app\_env\_vars) | Nextcloud environment variables. | <pre>list(object({<br>    key   = string<br>    value = string<br>  }))</pre> | <pre>[<br>  {<br>    "key": "POSTGRES_HOST",<br>    "value": "localhost:5432"<br>  }<br>]</pre> | no |
| <a name="input_db_env_vars"></a> [db\_env\_vars](#input\_db\_env\_vars) | PostgreSQL environment variables. | <pre>list(object({<br>    key   = string<br>    value = string<br>  }))</pre> | <pre>[<br>  {<br>    "key": "POSTGRES_DB",<br>    "value": "nextcloud"<br>  },<br>  {<br>    "key": "POSTGRES_USER",<br>    "value": "nextcloud"<br>  },<br>  {<br>    "key": "POSTGRES_PASSWORD",<br>    "value": "SuPers3cur3"<br>  }<br>]</pre> | no |
| <a name="input_web_volumes"></a> [web\_volumes](#input\_web\_volumes) | Volumes assigned to the Nginx proxy task | <pre>list(object({<br>    source   = string<br>    target   = string<br>    readonly = bool<br>  }))</pre> | <pre>[<br>  {<br>    "source": "/opt/volumes/nextcloud/html/data",<br>    "target": "/var/www/html/",<br>    "readonly": false,<br>  },<br>  {<br>    "source": "local/nginx.conf",<br>    "target": "/etc/nginx/nginx.conf",<br>    "readonly": true,<br>  }<br>]</pre> | no |
| <a name="input_app_volumes"></a> [app\_volumes](#input\_app\_volumes) | Volumes assigned to the NextCloud server task | <pre>list(object({<br>    source   = string<br>    target   = string<br>    readonly = bool<br>  }))</pre> | <pre>[<br>  {<br>    "source": "/opt/volumes/nextcloud/html/data",<br>    "target": "/var/www/html/",<br>    "readonly": false,<br>  }<br>]</pre> | no |
| <a name="input_db_volumes"></a> [db\_volumes](#input\_db\_volumes) | Volumes assigned to the PostgreSQL task | <pre>list(object({<br>    source   = string<br>    target   = string<br>    readonly = bool<br>  }))</pre> | <pre>[<br>  {<br>    "source": "/opt/volumes/nextcloud/postgresql/data",<br>    "target": "/var/lib/postgresql/data",<br>    "readonly": false,<br>  }<br>]</pre> | no |
| <a name="input_prestart_directory_creation"></a> [prestart\_directory\_creation](#input\_prestart\_directory\_creation) | Whether or not to launch a prestart task to create volume directories on the host. | `bool` | `true` | no |
| <a name="input_app_data_source_path"></a> [app\_data\_source\_path](#input\_app\_data\_source\_path) | Volume path on the host machine used for application data | `string` | `"/opt/volumes/nextcloud/html/data"` | no |
| <a name="input_db_volume_source_path"></a> [db\_volume\_source\_path](#input\_db\_volume\_source\_path) | Volume path on the host machine used for database data | `string` | `"/opt/volumes/nextcloud/postgresql/data"` | no |
