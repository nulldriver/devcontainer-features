
# Concourse Fly CLI (fly-cli)

Installs the Concourse Fly CLI.

## Example Usage

```json
"features": {
    "ghcr.io/nulldriver/devcontainer-features/fly-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| url | Concourse URL to download the Fly CLI from when version is empty | string | https://ci.concourse-ci.org |
| version | Optional exact Concourse release version to download from GitHub instead of the configured URL. | string | - |

## Architectures and version pinning

Downloads match the container architecture on AMD64 and ARM64. By default, Fly is
downloaded from the configured Concourse `url` and matches that server's version.

Set `version` to an exact Concourse release to download its GitHub release archive
instead. This allows building a bootstrap container before your Concourse server
exists and makes the installed CLI version reproducible.

```json
"features": {
    "ghcr.io/nulldriver/devcontainer-features/fly-cli:1": {
        "version": "8.3.2"
    }
}
```


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/nulldriver/devcontainer-features/blob/main/src/fly-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
