## About

Corporate environments often require a custom CA certificate to be trusted before any network calls that rely on TLS will succeed (e.g. `apt-get`, `curl`, package manager installs performed by other features). Because dev container features are otherwise ordered by their dependency graph (`installsAfter`, `dependsOn`) and declaration order, this feature's install script may run *after* other features that already attempted outbound HTTPS requests — causing SSL/TLS verification failures.

To guarantee the CA certificate is trusted before any other feature runs, use the `overrideFeatureInstallOrder` property in `devcontainer.json` to force this feature to install first.

## Using `overrideFeatureInstallOrder`

Add `overrideFeatureInstallOrder` as a top-level property in your `devcontainer.json`, listing this feature's fully qualified id first:

```jsonc
{
    "features": {
        "ghcr.io/nulldriver/devcontainer-features/ca-certificates:1": {
            "cert": "-----BEGIN CERTIFICATE-----\nMIIB...\n-----END CERTIFICATE-----"
        },
        "ghcr.io/devcontainers/features/node:1": {}
    },
    "overrideFeatureInstallOrder": [
        "ghcr.io/nulldriver/devcontainer-features/ca-certificates",
        "ghcr.io/devcontainers/features/node"
    ]
}
```

Notes:

- `overrideFeatureInstallOrder` takes a list of feature ids (without the version tag). Any features not listed are installed afterwards, in their normal dependency-resolved order.
- You don't need to list every feature — only the ones whose relative order you want to pin. Listing just `ca-certificates` first is enough to move it ahead of everything else.
- This is a `devcontainer.json` setting, not something this feature can set for you automatically — the feature consumer must add it to their own `devcontainer.json`.
- If you're composing a custom base image or Dockerfile that installs tools before features run at all, `overrideFeatureInstallOrder` won't help — you'd need to bake the CA trust into the image itself instead.

## Learn More

- [Dev Container Features spec: feature installation order](https://containers.dev/implementors/features/#installation-order) - explains `installsAfter`, `dependsOn`, and `overrideFeatureInstallOrder`
- [devcontainer.json reference](https://containers.dev/implementors/json_reference/#general-properties) - `overrideFeatureInstallOrder` property definition
