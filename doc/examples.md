---
modulename: Docker
title: Examples
giturl: gitlab.com/space-sh/docker
editurl: /edit/master/doc/examples.md
weight: 200
---
# Docker Module

The Space.sh Docker module is an interface to the Docker Engine command line tool.  
By having an interface to the Docker engine we can apply the Space.sh Shell power to it.  

## Simple usage

```sh
space -m docker /ps/

# Use tab auto completion to get som suggestions
space -m docker /ls_by_status/ -- [tab][tab]

space -m docker /rm_by_status/

# Get some suggestion of images to run.
space -m docker /run/ -e image=[tab][tab]

# Run a one shot container.
space -m docker /run/ -e image=alpine -e flags="--rm" -e args="ls /"

# Enter a running container, use tab completion to get a list
# of running containers.
space -m docker /enter/ -e container=[tab][tab]
```  

  Use [tab] to explore the nodes and arguments provided by the module.  
Apply the `-h` flag to het help on a specific node.  

## Wrap commands to be run inside containers

Sometimes you want to run a command in an existing container using `docker exec`, here you will see how to do that in an easy way.  

```sh
docker -m os /info/ -m docker /exec_wrap/ -e container=[tab][tab]
```  

How about doing this but on a container running on a remote host behind a firewall?
No biggies, try this:  

```sh
docker -m os /info/ -m ssh /wrap/ -eSSHHOST=host1,host2 \
    -m docker /exec_wrap/ -e container=[tab][tab]
```  

Note that for the auto completion to work in this case you must have ssh login keys setup,
because entering a password when tab completing will not work.  
