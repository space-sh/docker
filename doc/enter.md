---
modulename: Docker
title: /enter/
giturl: gitlab.com/space-sh/docker
weight: 200
---
# Docker module: Enter

Enter a running container.

## Example

Enter existing container named `container_name`:
```sh
space -m docker /enter/ -- "container_name"
```  

Run command `/bin/ls` on container named `my_container`:
```sh
space -m docker /enter/ -- "my_container" "/bin/ls"
```
