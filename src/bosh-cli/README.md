
# BOSH CLI (bosh-cli)

Installs the BOSH CLI, optionally installing additional dependencies.

## Example Usage

```json
"features": {
    "ghcr.io/nulldriver/devcontainer-features/bosh-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a BOSH CLI version. | string | latest |
| install_dependencies | Set to `false` to bypass installing additional dependencies. | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/nulldriver/devcontainer-features/blob/main/src/bosh-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
