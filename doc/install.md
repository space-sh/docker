---
modulename: Docker
title: /install/
giturl: gitlab.com/space-sh/docker
editurl: /edit/master/doc/install.md
weight: 200
---
# Docker module: Install

Install or reinstall the latest _Docker Engine_ from _Docker_ and set up user permissions for managing containers and images.

## Example

Install _Docker_ and set permissions to `username`:
```sh
space -m docker /install/ -- "username"
```

Exit status code is expected to be 0 on success.
