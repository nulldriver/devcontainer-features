
# CredHub CLI (credhub-cli)

Installs the CredHub CLI.

## Example Usage

```json
"features": {
    "ghcr.io/nulldriver/devcontainer-features/credhub-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a CredHub CLI version. | string | latest |

## Native ARM64 installation

The feature downloads a release archive matching the container architecture.
When a release has no Linux ARM64 archive, it builds the selected source tag with
vendored dependencies instead. Unqualified legacy Linux archives are used only
on AMD64.

For ARM64 source builds, include the official Go feature. Select a Go version
that satisfies the selected CredHub tag's `go.mod`; CredHub 2.9.62 requires Go
1.26.0 or newer. The feature orders itself after Go and uses the installed
toolchain without automatically downloading another version.

```json
"features": {
    "ghcr.io/devcontainers/features/go:1": {
        "version": "1.27.2",
        "installGoTools": false
    },
    "ghcr.io/nulldriver/devcontainer-features/credhub-cli:1": {
        "version": "2.9.62"
    }
}
```


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/nulldriver/devcontainer-features/blob/main/src/credhub-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
