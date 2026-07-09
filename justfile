set positional-arguments

test feature-name:
    devcontainer features test -f {{feature-name}}

test-scenario feature-name scenario-filter:
    devcontainer features test -f {{feature-name}} --filter "{{scenario-filter}}"

test-all:
    devcontainer features test
