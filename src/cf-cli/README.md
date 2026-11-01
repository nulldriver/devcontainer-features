
# Cloud Foundry CLI (cf-cli)

Installs the Cloud Foundry CLI.

## Example Usage

```json
"features": {
    "ghcr.io/nulldriver/devcontainer-features/cf-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a Cloud Foundry CLI version. | string | latest |

## Architectures

AMD64 uses the Cloud Foundry package download endpoint. ARM64 uses the native
Linux ARM64 archive from the selected GitHub release, so the selected version
must publish that archive. The installer verifies the CLI runs after installation.

`latest`, `current`, and `lts` resolve the latest published GitHub release rather
than the highest Git tag, because tags can exist before their release binaries.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/nulldriver/devcontainer-features/blob/main/src/cf-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
