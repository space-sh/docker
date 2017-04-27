---
modulename: Docker
title: /wrap_run/
giturl: gitlab.com/space-sh/docker
weight: 200
---
# Docker module: Run wrap

Execute a command inside a disposable container.

## Example

Run node named `/info/` from _OS_ module in a newly created _Debian_ container:
```sh
space -m os /info/ -m docker /wrap_run/ -eimage=debian
```
