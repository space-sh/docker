# Docker container management. | [![build status](https://gitlab.com/space-sh/docker/badges/master/build.svg)](https://gitlab.com/space-sh/docker/commits/master)


## /enter/
	Enter a running container.


## /install/
	Install the latest Docker Engine.

	Downloads and installs the latest Docker Engine from Docker.
	Also adds the targetuser to the docker group.
	Will reinstall if already installed.
	


## /logs/
	Get container logs


## /ls_by_status/
	List container(s) by their status


## /ps/
	List containers.


## /rm_all/
	Remove all docker containers


## /rm_by_id/
	Remove container(s) by their id


## /rm_by_name/
	Remove container(s) by their name


## /rm_by_status/
	Remove container(s) by their status


## /rmi_all/
	Remove all docker images


## /run/
	Run a container


## /stop/
	Stop a running container


## /wrap_exec/
	Exec a command inside an existing container


## /wrap_run/
	Exec a command inside a temporary container


# Functions 

## DOCKER\_DEP\_INSTALL()  
  
  
  
Verify that Docker Engine is installed  
otherwise install it.  
  
### Parameters:  
- $1: user to add to docker group.  
  
### Returns:  
- 0: success  
- 1: failure  
  
  
  
## DOCKER\_INSTALL()  
  
  
  
Install latest Docker and make it available to the user.  
  
### Parameters:  
- $1: user to add to docker group.  
  
### Returns:  
- 0: success  
- 1: failure  
  
  
  
## DOCKER\_RUN()  
  
  
  
Create and start a container.  
  
### Parameters:  
- $1: image to instantiate  
- $2: container name (optional)  
- $3: flags (optional)  
- $4: cmd (optional)  
- $5: args (optional)  
  
### Returns:  
- docker run status  
  
  
  
## DOCKER\_WRAP\_RUN()  
  
  
  
Wrap a command to be run inside a new container.  
  
### Expects:  
- ${DOCKERIMAGE}  
- ${DOCKERCONTAINER} (optional)  
- ${DOCKERFLAGS}  
- ${DOCKERCMD}  
  
  
  
## DOCKER\_EXEC()  
  
  
  
Exec command in existing docker container.  
  
### Parameters:  
- $1: container name  
- $2: flags  
- $3: cmd  
- $4: args (optional)  
  
### Returns:  
- docker exec status  
  
  
  
## DOCKER\_WRAP\_EXEC()  
  
  
  
Wrap another command to be run inside an existing container.  
  
### Expects:  
- ${DOCKERCONTAINER}  
- ${DOCKERFLAGS} (optional)  
- ${DOCKERCMD} (optional)  
- ${RUN is the space function to be wrapped.}  
  
  
  
## DOCKER\_ENTER()  
  
  
  
Start shell inside existing docker container.  
  
### Parameters:  
- $1: container name  
- $2: shell (optional, defaults to sh)  
  
### Returns:  
- docker exec status  
  
  
  
## DOCKER\_LS()  
  
  
  
List all containers.  
  
  
  
## DOCKER\_LS\_BY\_STATUS()  
  
  
  
List all containers filtered by status.  
  
Parameters;  
$1: status string, ex "Exited".  
  
  
  
## DOCKER\_EXIST()  
  
  
  
Check if a container exists.  
  
Parameters;  
$1: container name  
  
  
  
## DOCKER\_LOGS()  
  
  
  
Get container logs  
  
Parameters;  
$1: container name(s)  
  
  
  
## DOCKER\_RMI\_ALL()  
  
  
  
Remove all docker images.  
  
  
  
## DOCKER\_RM\_BY\_STATUS()  
  
  
  
Remove all containers filtered by their status.  
  
Parameters;  
$1: status string, ex "Exited".  
  
  
  
## DOCKER\_RM\_ALL()  
  
  
  
Remove all containers  
  
  
  
## DOCKER\_RM\_BY\_ID()  
  
  
  
Remove all containers by ID or name.  
  
Parameters;  
$1: IDs  
  
  
  
## DOCKER\_PS()  
  
  
  
Run "docker ps" to list all container.s  
  
### Parameters:  
- $@: All arguments are passed on.  
  
  
  
## DOCKER\_STOP()  
  
  
  
Stop a running container  
  
Parameters;  
$1: container name(s)  
  
  
  
