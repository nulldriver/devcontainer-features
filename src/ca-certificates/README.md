
# CA Certificates (ca-certificates)

Adds a custom CA certificate to the OS trust store, optionally imports it into the Java truststore (cacerts) if a JDK is present, and optionally exports common environment variables (e.g. NODE_EXTRA_CA_CERTS, SSL_CERT_FILE) for tools that need it set explicitly.

## Example Usage

```json
"features": {
    "ghcr.io/nulldriver/devcontainer-features/ca-certificates:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| cert | PEM-encoded CA certificate content to trust. May contain multiple concatenated certificates. Leave empty to skip installation. | string | - |
| cert_filename | Filename to use when installing the certificate under /usr/local/share/ca-certificates/. Must end in .crt. | string | custom-ca.crt |
| set_env_vars | Export common CA-related environment variables (NODE_EXTRA_CA_CERTS, SSL_CERT_FILE, SSL_CERT_DIR, REQUESTS_CA_BUNDLE, CURL_CA_BUNDLE, GIT_SSL_CAINFO, PIP_CERT, AWS_CA_BUNDLE) pointing at the installed certificate/bundle, and import the certificate into the Java truststore (cacerts) if a JDK's 'keytool' is found on PATH. Only applies when 'cert' is set. | boolean | true |
| java_truststore_password | Password for the Java truststore (cacerts) used when importing the certificate via keytool. Only applies when 'cert' and 'set_env_vars' are set and a JDK's 'keytool' is found on PATH. | string | changeit |

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

## Java truststore import

When `set_env_vars` is `true` (the default) and a `cert` is provided, this feature also attempts to import the certificate into the Java truststore (`cacerts`) — not just export environment variables. Specifically:

- It looks for a `keytool` binary on `PATH`. If none is found (e.g. no JDK feature is installed, or a JDK feature installs *after* this one), the import is silently skipped and does not fail the build.
- `JAVA_HOME` is derived from the location of `keytool` if not already set, and the truststore is located at `$JAVA_HOME/lib/security/cacerts` (or `$JAVA_HOME/jre/lib/security/cacerts` for older JDK layouts).
- The certificate is imported under an alias derived from `cert_filename`, using the standard JDK default truststore password `changeit`. If your JDK feature changes this default password, set the `java_truststore_password` option to match.
- Only the JDK found on `PATH` is targeted — if multiple JDKs are installed side-by-side, only one truststore is updated.
- Because this depends on a JDK already being installed and on `PATH`, list a Java feature (e.g. `ghcr.io/devcontainers/features/java`) *before* `ca-certificates` in your `devcontainer.json`, or otherwise ensure it installs first (this feature's `installsAfter` already prefers this ordering when both are declared). Note this is in tension with the `overrideFeatureInstallOrder` recommendation above for OS-level trust — if you force `ca-certificates` to run first for that reason, the Java truststore import will be skipped, and you'll need to run `keytool -importcert` manually afterwards.

## Learn More

- [Dev Container Features spec: feature installation order](https://containers.dev/implementors/features/#installation-order) - explains `installsAfter`, `dependsOn`, and `overrideFeatureInstallOrder`
- [devcontainer.json reference](https://containers.dev/implementors/json_reference/#general-properties) - `overrideFeatureInstallOrder` property definition


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/nulldriver/devcontainer-features/blob/main/src/ca-certificates/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
