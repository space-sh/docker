---
modulename: Docker
title: /exec_wrap/
giturl: gitlab.com/space-sh/docker
weight: 200
---
# Docker module: Execute wrap

Execute a command inside an existing container.

## Example

Run node named `/info/` from _OS_ module inside an existing container named `space_container`:
```sh
space -m os /info/ -m docker /exec_wrap/ -econtainer=space_container
```

Output:
```sh
[INFO]  OS_INFO: OS type: gnu.
[INFO]  OS_INFO: OS init system: systemd.
[INFO]  OS_INFO: OS package manager: apt.
[INFO]  OS_INFO: OS home directory: /home.
[INFO]  OS_INFO: Current directory: /..
```
