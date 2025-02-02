# Development Container Features

This repository contains a _collection_ of community supported [Dev Container Features](https://containers.dev/implementors/features/) that allow you to quickly and easily add more tooling, runtime, or library "Features" into your [Development Container](https://containers.dev/) for you or your collaborators to use.

## Usage

To reference a Feature from this repository, add the desired Features to your `devcontainer.json` file and configure any additional options.

The example below installs the `bosh` and `credhub` cli Features as declared in the [`./src`](./src) directory of this repository.

> See the relevant Feature's README for supported options.

```jsonc
{
    "name": "my-project-devcontainer",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu", // Any generic, debian-based image.
    "features": {
        "ghcr.io/nulldriver/devcontainer-features/bosh-cli:1": {
            "version": "7.1"
        },
        "ghcr.io/nulldriver/devcontainer-features/credhub-cli:1": {
            "version": "2.9"
        }
    }
}
```

The `:latest` version annotation is added implicitly if omitted. To pin to a specific package version ([example](https://github.com/nulldriver/devcontainer-features/pkgs/container/devcontainer-features/bosh-cli/versions)), append it to the end of the Feature. Features follow semantic versioning conventions, so you can pin to a major version `:1`, minor version `:1.0`, or patch version `:1.0.0` by specifying the appropriate label.

```jsonc
"features": {
    "ghcr.io/nulldriver/devcontainer-features/bosh-cli:1.0.0": {
        "version": "7.1"
    }
}
```

## Supported Features

| Feature       | Description
| ---           | ---
| [`bosh-cli`](./src/bosh-cli)           | Installs [BOSH CLI](https://bosh.io/docs/cli-v2/), an open source tool for release engineering, deployment, lifecycle management, and monitoring of distributed systems.
| [`builder`](./src/builder)             | Installs [Builder](https://github.com/jtarchie/builder): Static Site Generation Tool.
| [`cf-cli`](./src/cf-cli)               | Installs [Cloud Foundry CLI](https://bosh.io/docs/cli-v2/), the official command line client for Cloud Foundry.
| [`credhub-cli`](./src/credhub-cli)     | Installs [CredHub CLI](https://github.com/cloudfoundry/credhub-cli), a credential manager for managing passwords, certificates, certificate authorities, ssh keys, rsa keys and arbitrary values (strings and JSON blobs).
| [`fly-cli`](./src/fly-cli)             | Installs the [Concourse Fly CLI](https://concourse-ci.org/fly.html).
| [`gem`](./src/gem/)                    | Installs RubyGems using the [gem cli](https://guides.rubygems.org/command-reference/#gem-install).
| [`kf-cli`](./src/kf-cli)               | Installs [Kf CLI](https://cloud.google.com/migrate/kf/docs/).  Kf offers developers the Cloud Foundry experience while empowering operators to adopt declarative Kubernetes practice.
| [`shellspec-cli`](./src/shellspec-cli) | Installs the [ShellSpec](https://github.com/shellspec/shellspec) BDD unit testing framework CLI.

## Contributing

This repository will accept improvement and bug fix contributions related to the [current set of maintained Features](./src).
