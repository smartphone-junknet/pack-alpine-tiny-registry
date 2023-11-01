# Nomad Pack Alpine (tiny) registry

This registry contains curated Packs to be run on Alpine Linux clients, defaulting to `podman` task driver and `nomad` service provider.

Moreover, the job templates are rendered with a smaller default allocation filesystem and resource quotas, accounting for small hosts capacity.

## PostmarketOS

This registry is tested mainly on PostmarketOS physical and virtual hosts. The target host is tested after provisioning with the Ansible playbook found at [this repository](https://github.com/smartphone-junknet/junknode-provisioner)
