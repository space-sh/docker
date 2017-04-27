---
modulename: Docker
title: /rm_by_name/
giturl: gitlab.com/space-sh/docker
weight: 200
---
# Docker module: Remove by name

Remove one or more containers given their name.

## Example

Remove multiple containers with in a single statement:
```sh
space -m docker /rm_by_name/ -- "space_hen"
```

Exit status code is expected to be 0 on success.
