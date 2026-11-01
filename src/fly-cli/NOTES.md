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
