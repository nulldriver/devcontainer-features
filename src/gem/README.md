
# RubyGems (gem)

Installs RubyGems using the gem cli

## Example Usage

```json
"features": {
    "ghcr.io/nulldriver/devcontainer-features/gem:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| gem | Name of gem(s) to install. Can be a single gem, or space/comma separated list of gems | string | - |
| version | Specify version of gem to install | string | - |
| prerelease | Allow prerelease versions of a gem to be installed. (Only for listed gems) | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/nulldriver/devcontainer-features/blob/main/src/gem/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
