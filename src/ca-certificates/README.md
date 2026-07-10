
# CA Certificates (ca-certificates)

Adds a custom CA certificate to the OS trust store and optionally exports common environment variables (e.g. NODE_EXTRA_CA_CERTS, SSL_CERT_FILE) for tools that need it set explicitly.

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
| set_env_vars | Export common CA-related environment variables (NODE_EXTRA_CA_CERTS, SSL_CERT_FILE, SSL_CERT_DIR, REQUESTS_CA_BUNDLE, CURL_CA_BUNDLE, GIT_SSL_CAINFO, PIP_CERT, AWS_CA_BUNDLE) pointing at the installed certificate/bundle. Only applies when 'cert' is set. | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/nulldriver/devcontainer-features/blob/main/src/ca-certificates/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
