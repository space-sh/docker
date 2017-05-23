---
modulename: Docker
title: /ps/
giturl: gitlab.com/space-sh/docker
editurl: /edit/master/doc/ps.md
weight: 200
---
# Docker module: Ps

List all available containers.

## Example

```sh
space -m docker /ps/
```

Output:
```sh
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
24b156b78c02        debian              "/bin/bash"         20 minutes ago      Up 20 minutes                           space_container
```
