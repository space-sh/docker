---
modulename: Docker
title: /rm_by_id/
giturl: gitlab.com/space-sh/docker
editurl: /edit/master/doc/rm_by_id.md
weight: 200
---
# Docker module: Remove by ID

Remove one or more containers given their _ID_.

## Example

Remove multiple containers with in a single statement:
```sh
space -m docker /rm_by_id/ -- "7cb2fc04fc35 05c199f044f9"
```

Exit status code is expected to be 0 on success.
