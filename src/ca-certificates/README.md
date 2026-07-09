
# CA Certificates (ca-certificates)

Adds a custom CA certificate to the OS trust store and optionally exports common environment variables (e.g. NODE_EXTRA_CA_CERTS, SSL_CERT_FILE) for tools that need it set explicitly.

## Example Usage

```json
"features": {
    "ghcr.io/nulldriver/devcontainer-features/ca-certificates:1": {
        "cert": "-----BEGIN CERTIFICATE-----\nMIIB...\n-----END CERTIFICATE-----"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| cert | PEM-encoded CA certificate content to trust. May contain multiple concatenated certificates. Leave empty to skip installation. | string | - |
| cert_filename | Filename to use when installing the certificate under /usr/local/share/ca-certificates/. Must end in .crt. | string | custom-ca.crt |
| set_env_vars | Export common CA-related environment variables (NODE_EXTRA_CA_CERTS, SSL_CERT_FILE, SSL_CERT_DIR, REQUESTS_CA_BUNDLE, CURL_CA_BUNDLE, GIT_SSL_CAINFO, PIP_CERT, AWS_CA_BUNDLE) pointing at the installed certificate/bundle. Only applies when 'cert' is set. | boolean | true |

## Notes

- Only Debian/Ubuntu-based images are supported (relies on `apt-get` and `update-ca-certificates`).
- `cert` can contain multiple concatenated `-----BEGIN CERTIFICATE-----` blocks if you need to trust more than one CA.
- `NODE_EXTRA_CA_CERTS` points at just the custom certificate (Node.js adds it to its own bundled trust store). All other variables point at the full system CA bundle (`/etc/ssl/certs/ca-certificates.crt`), since those tools replace their default trust store rather than extend it.
- Environment variables are written to `/etc/environment` and `/etc/profile.d/00-ca-certificates.sh`, so they apply to login shells and most remote/Codespaces sessions. They are not set via the feature's static `containerEnv`, since they must be skipped entirely when no `cert` is provided.
- If the `ca-certificates-java` package is installed in your image, `update-ca-certificates` will automatically import the certificate into the JVM's default keystore as well.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/nulldriver/devcontainer-features/blob/main/src/ca-certificates/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
