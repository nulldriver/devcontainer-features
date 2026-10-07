
# CA Certificates (ca-certificates)

Adds a custom CA certificate to the OS trust store, optionally imports it into the active Java truststore during installation and container creation, and optionally exports common CA environment variables.

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
| set_env_vars | Export common CA-related environment variables (NODE_EXTRA_CA_CERTS, SSL_CERT_FILE, SSL_CERT_DIR, REQUESTS_CA_BUNDLE, CURL_CA_BUNDLE, GIT_SSL_CAINFO, PIP_CERT, AWS_CA_BUNDLE) and import the certificate into the active Java truststore during installation and container creation. Only applies when 'cert' is set. | boolean | true |
| java_truststore_password | Password for the Java truststore (cacerts) used for immediate and deferred imports via keytool. Only applies when 'cert' is set and 'set_env_vars' is true. | string | changeit |

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

- OS trust and environment exports are installed immediately. Java import runs immediately if a JDK is already available, and again through this feature's `onCreateCommand` after all features have installed. A JDK installed by a later feature therefore receives the certificate before user-provided lifecycle commands run.
- The importer prefers a working `$JAVA_HOME/bin/keytool`, otherwise it derives the JDK location from `keytool` on `PATH`. The truststore is located at `$JAVA_HOME/lib/security/cacerts` (or `$JAVA_HOME/jre/lib/security/cacerts` for older JDK layouts).
- If no JDK is available, import is skipped with a message. A detected JDK with a missing truststore, an incorrect password, or a failed import causes the installation or lifecycle command to fail with diagnostics.
- The certificate is imported under an alias derived from `cert_filename`, using the standard JDK default truststore password `changeit`. If your JDK feature changes this default password, set the `java_truststore_password` option to match.
- Only the active JDK is targeted — if multiple JDKs are installed side-by-side, only one truststore is updated. Repeated imports leave an already-matching certificate unchanged and preserve unrelated trust entries.
- The truststore password is persisted in a root-readable file for the deferred import; it is not included in lifecycle metadata or command arguments. Like other feature options, it should not be treated as an image-build secret. Non-root remote users need passwordless `sudo` to run the importer; the standard Dev Containers base images provide this. The active JDK is resolved before privilege elevation so SDKMAN paths are preserved.
- Empty `cert` or `set_env_vars: false` disables both immediate and deferred Java imports. Containers without Java do not require `sudo`.

Keep `ca-certificates` first and use the upstream Java feature unchanged:

```jsonc
{
    "features": {
        "ghcr.io/nulldriver/devcontainer-features/ca-certificates:1": {
            "cert": "-----BEGIN CERTIFICATE-----\nMIIB...\n-----END CERTIFICATE-----"
        },
        "ghcr.io/devcontainers/features/java:1": {}
    },
    "overrideFeatureInstallOrder": [
        "ghcr.io/nulldriver/devcontainer-features/ca-certificates",
        "ghcr.io/devcontainers/features/java"
    ]
}
```

The deferred import happens at container creation, not during the image build. It cannot prepare Java trust for Java commands executed by other feature installers during that build. Tools that skip lifecycle commands must run `/usr/local/bin/import-java-certificates` explicitly.

After installing or switching to another JDK inside an existing container, run `/usr/local/bin/import-java-certificates` again with the desired `JAVA_HOME` or `keytool` on `PATH`. The hook does not monitor subsequent JDK changes or run at every container start.

## Learn More

- [Dev Container Features spec: feature installation order](https://containers.dev/implementors/features/#installation-order) - explains `installsAfter`, `dependsOn`, and `overrideFeatureInstallOrder`
- [devcontainer.json reference](https://containers.dev/implementors/json_reference/#general-properties) - `overrideFeatureInstallOrder` property definition


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/nulldriver/devcontainer-features/blob/main/src/ca-certificates/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
