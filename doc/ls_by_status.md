---
modulename: Docker
title: /ls_by_status/
giturl: gitlab.com/space-sh/docker
weight: 200
---
# Docker module: List by status

List all available containers by their current status.

## Example

List all running containers:
```sh
space -m docker /ls_by_status/ -- "Up"
```

Output:
```sh
24b156b78c02
```

List all stopped containers:
```sh
space -m docker /ls_by_status/ -- "Exited"
```

Output:
```sh
98ce58250e0f
05c199f044f9
e5a912fb32a8
4eea2236fcbe
8759288d4973
065850b50878
```
