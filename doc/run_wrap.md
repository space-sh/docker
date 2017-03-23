---
modulename: Docker
title: /run_wrap/
giturl: gitlab.com/space-sh/docker
weight: 200
---
# Docker module: run_wrap

Execute a command inside a disposable container.

## Example

Run node named `/info/` from _OS_ module in a newly created _Debian_ container:
```sh
space -m os /info/ -m docker /run_wrap/ -eimage=debian
```
