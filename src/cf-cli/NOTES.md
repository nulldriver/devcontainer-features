## Architectures

AMD64 uses the Cloud Foundry package download endpoint. ARM64 uses the native
Linux ARM64 archive from the selected GitHub release, so the selected version
must publish that archive. The installer verifies the CLI runs after installation.

`latest`, `current`, and `lts` resolve the latest published GitHub release rather
than the highest Git tag, because tags can exist before their release binaries.
