---
modulename: Docker
title: /rm_by_status/
giturl: gitlab.com/space-sh/docker
weight: 200
---
# Docker module: Remove by status

Remove one or more containers given their status.

## Example

Remove all exited containers:
```sh
space -m docker /rm_by_status/ -- "Exited"
```

Exit status code is expected to be 0 on success.
