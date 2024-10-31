# Nomad Pack Alpine (tiny) registry

This registry contains curated Packs to be run on Alpine Linux clients, defaulting to `podman` task driver and `nomad` service provider.

Moreover, the job templates are rendered with a smaller default allocation filesystem and resource quotas, accounting for small hosts capacity.

## Required packages

The following packages are required for deploying packs in Nomad:

- `git` is needed to download the registry information through the `nomad-pack` command
- `slirp4netns` is required to run the packs in a rootless context

Moreover, it is mandatory to check the pack variables' defaults and override them if they do not match your installation: for example, the `job_name` and `datacenters` variables probably should be customized.

## PostmarketOS

This registry is tested mainly on PostmarketOS physical and virtual hosts. The target host is tested after provisioning with the Ansible playbook found at [this repository](https://github.com/smartphone-junknet/junknode-provisioner)

## Usage example

Add this registry as the *default* one, to implicitly use it for each `nomad-pack` command:

```bash
nomad-pack registry add default github.com/smartphone-junknet/pack-alpine-tiny-registry
```

> [!NOTE]
> The same `add` command as above is used to update the added registry afterwards, if new pack versions are available.

Run the `nextcloud` pack on the current host, after adding this registry as the default one and providing a variables file:

```bash
nomad-pack run nextcloud --parser-v1 -f packs/nextcloud_vars.hcl
```

> [!NOTE]
> The above commands exhibits the `--parser-v1` flag, which is necessary to use a nightly build of `nomad-pack` older than September 26, 2023 with the templates in this registry.
