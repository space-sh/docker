#
# Copyright 2016-2017 Blockie AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#======================
# DOCKER_DEP_INSTALL
#
# Verify that Docker Engine is installed
# otherwise install it.
#
# Parameters:
#   $1: user to add to docker group.
#
# Returns:
#   0: success
#   1: failure
#
#======================
DOCKER_DEP_INSTALL()
{
    SPACE_SIGNATURE="targetuser:1"
    SPACE_DEP="PRINT DOCKER_INSTALL"

    # shellcheck disable=SC2039
    local targetuser="${1}"
    shift

    if OS_IS_INSTALLED "docker"; then
        PRINT "Docker is already installed. To reinstall run: space -m docker /install/." "ok"
        return 0
    fi

    DOCKER_INSTALL "${targetuser}"
}


# Disable warning about local keyword
# shellcheck disable=SC2039

#======================
# DOCKER_INSTALL
#
# Install latest Docker and make it available to the user.
#
# Parameters:
#   $1: user to add to docker group.
#
# Returns:
#   0: success
#   1: failure
#
#======================
DOCKER_INSTALL()
{
    SPACE_SIGNATURE="targetuser:1"
    SPACE_DEP="PRINT OS_IS_INSTALLED OS_USER_ADD_GROUP OS_SERVICE OS_GROUP_EXIST OS_ADD_GROUP"

    local targetuser="${1}"
    shift

    PRINT "Install Docker Engine.." "info"

    if OS_INSTALL_PKG "docker"; then
        if [ "${targetuser}" != "root" ]; then
           if ! OS_GROUP_EXIST "docker"; then
               if ! OS_ADD_GROUP "docker"; then
                   PRINT "Could not create docker group." "error"
                   return 1
               fi
           fi
           OS_USER_ADD_GROUP "${targetuser}" "docker"
        fi
        OS_SERVICE "docker" "start"
        OS_SERVICE "docker" "enable"
    else
        OS_IS_INSTALLED "curl" "curl"
        curl -sL https://get.docker.com/ | sh &&
        if [ "${targetuser}" != "root" ]; then
           if ! OS_GROUP_EXIST "docker"; then
               if ! OS_ADD_GROUP "docker"; then
                   PRINT "Could not create docker group." "error"
                   return 1
               fi
           fi
           OS_USER_ADD_GROUP "${targetuser}" "docker"
        fi
        OS_SERVICE "docker" "start"
        OS_SERVICE "docker" "enable"
    fi
}


# Disable warning about local keyword
# shellcheck disable=SC2039

#=====================
# DOCKER_RUN
#
# Create and start a container.
#
# Parameters:
#   $1: image to instantiate
#   $2: container name (optional)
#   $3: flags (optional)
#   $4: cmd (optional)
#   $5: args (optional)
#
# Returns:
#   docker run status
#
#=====================
DOCKER_RUN()
{
    SPACE_SIGNATURE="image:1 [container flags cmd args]"
    SPACE_DEP="PRINT"
    SPACE_ENV="_FORCE_BASH"

    local image="${1}"
    shift

    local container="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local flags="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local cmd="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local args="$*"

    if [ -z "${image}" ]; then
        PRINT "Missing args: image [container flags cmd args]" "error"
        return 1
    fi

    if [ "${args}" != "" ] && [ "${cmd}" = "" ]; then
        PRINT "Cannot have args without cmd, setting default..." "debug"
        if [ ${_FORCE_BASH} = "1" ]; then
            PRINT "Setting default cmd: bash -c." "debug"
            cmd="bash -c"
        else
            PRINT "Setting default cmd: sh -c." "debug"
            cmd="sh -c"
        fi
    fi

    if [ -t 0 ] && [ -t 1 ] && [ -t 2 ]; then
        flags="${flags} -t"
    fi

    PRINT "docker run ${flags} ${container:+--name ${container}} ${image} ${cmd} ${args:+$*}." "debug"

    # shellcheck disable=2086
    docker run ${flags} ${container:+--name "${container}"} "${image}" ${cmd} ${args:+"$@"}
}

#=====================
# DOCKER_WRAP_RUN
#
# Wrap a command to be run inside a new container.
#
# Expects:
#   ${DOCKERIMAGE}
#   ${DOCKERCONTAINER} (optional)
#   ${DOCKERFLAGS}
#   ${DOCKERCMD}
#
#=====================
DOCKER_WRAP_RUN()
{
    SPACE_FN="DOCKER_RUN"
    # shellcheck disable=2016
    SPACE_ARGS="\"${DOCKERIMAGE}\" \"${DOCKERCONTAINER}\" \"${DOCKERFLAGS}\" \"${DOCKERCMD-}\" \"\${RUN}\""
}


# Disable warning about local keyword
# shellcheck disable=SC2039

#=====================
# DOCKER_EXEC
#
# Exec command in existing docker container.
#
# Parameters:
#   $1: container name
#   $2: flags
#   $3: cmd
#   $4: args (optional)
#
# Returns:
#   docker exec status
#
#=====================
DOCKER_EXEC()
{
    SPACE_SIGNATURE="container:1 flags cmd:0 [args]"
    SPACE_DEP="PRINT"
    SPACE_ENV="_FORCE_BASH"

    local container="${1}"
    shift

    local flags="${1}"
    shift

    local cmd="${1}"
    shift

    local args="$*"

    if [ "${cmd}" = "" ]; then
        if [ ${_FORCE_BASH} = "1" ]; then
            PRINT "Setting default cmd: bash -c." "debug"
            cmd="bash -c"
        else
            PRINT "Setting default cmd: sh -c." "debug"
            cmd="sh -c"
        fi
    fi

    if [ -t 0 ] && [ -t 1 ] && [ -t 2 ]; then
        flags="${flags} -t"
    fi

    PRINT "Exec in ${container}." "debug"
    PRINT "cmd: ${cmd}." "debug"
    PRINT "flags: ${flags}." "debug"

    # shellcheck disable=2086
    docker exec ${flags} ${container} ${cmd} "$@"
}

#=====================
# DOCKER_WRAP_EXEC
#
# Wrap another command to be run inside an existing container.
#
# Expects:
#   ${DOCKERCONTAINER}
#   ${DOCKERFLAGS} (optional)
#   ${DOCKERCMD} (optional)
#   ${RUN is the space function to be wrapped.}
#
#=====================
DOCKER_WRAP_EXEC()
{
    # shellcheck disable=2034
    SPACE_FN="DOCKER_EXEC"
    # shellcheck disable=2034
    # shellcheck disable=2016
    SPACE_ARGS="\"${DOCKERCONTAINER}\" \"${DOCKERFLAGS}\" \"${DOCKERCMD}\" \"\${RUN}\""
}


# Disable warning about local keyword
# shellcheck disable=SC2039

#=====================
# DOCKER_ENTER
#
# Start shell inside existing docker container.
#
# Parameters:
#   $1: container name
#   $2: shell (optional, defaults to sh)
#
# Returns:
#   docker exec status
#
#=====================
DOCKER_ENTER()
{
    SPACE_SIGNATURE="container:1 [shell]"
    # shellcheck disable=2034
    SPACE_DEP="PRINT"

    local container="${1}"
    shift

    local shell="${1:-sh}"
    shift $(( $# > 0 ? 1 : 0 ))

    PRINT "Enter ${container} using ${shell}." "debug"

    # shellcheck disable=2086
    docker exec -ti "${container}" ${shell}
}

#=============================
# DOCKER_LS
#
# List all containers.
#
#=============================
DOCKER_LS()
{
    docker ps -a
}

#=============================
# DOCKER_LS_BY_STATUS
#
# List all containers filtered by status.
#
# Parameters;
#   $1: status string, ex "Exited".
#
#=============================
DOCKER_LS_BY_STATUS()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="status:1"

    # shellcheck disable=SC2039
    local status="${1}"
    shift

    docker ps -a | grep "${status}" | awk '{print $1}'
}

#=============================
# DOCKER_EXIST
#
# Check if a container exists.
#
# Parameters;
#   $1: container name
#
#=============================
DOCKER_EXIST()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="container:1"

    # shellcheck disable=SC2039
    local name="${1}"
    shift

    local list
    list=$(docker ps -a | grep "\<${name}$")
    [ -n "${list}" ]
}

#=============================
# DOCKER_LOGS
#
# Get container logs
#
# Parameters;
#   $1: container name(s)
#
#=============================
DOCKER_LOGS()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="containers:1"

    docker logs ${@:+"$@"}
}

#=============================
# DOCKER_RMI_ALL
#
# Remove all docker images.
#
#=============================
DOCKER_RMI_ALL()
{
    docker images -q | xargs docker rmi -f
}

#=============================
# DOCKER_RM_BY_STATUS
#
# Remove all containers filtered by their status.
#
# Parameters;
#   $1: status string, ex "Exited".
#
#=============================
DOCKER_RM_BY_STATUS()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="status:1"

    # shellcheck disable=SC2039
    local status="${1}"
    shift

    docker ps -a | grep "${status}" | awk '{print $1}' | xargs docker rm -f
}

#=============================
# DOCKER_RM_ALL
#
# Remove all containers
#
#=============================
DOCKER_RM_ALL()
{
    docker ps -a -q | xargs docker rm -f
}

# Disable warning about local keyword
# shellcheck disable=SC2039

#=============================
# DOCKER_RM_BY_ID
#
# Remove all containers by ID or name.
#
# Parameters;
#   $1: IDs
#
#=============================
DOCKER_RM_BY_ID()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="id:1 [id]"

    local id=
    for id in "$@"; do
        docker rm -f "${id}"
    done
}

#=====================
# DOCKER_PS
#
# Run "docker ps" to list all container.s
#
# Parameters:
#   $@: All arguments are passed on.
#
#=====================
DOCKER_PS()
{
    docker ps ${@:+"$@"}
}

#=============================
# DOCKER_STOP
#
# Stop a running container
#
# Parameters;
#   $1: container name(s)
#
#=============================
DOCKER_STOP()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="containers:1"

    docker stop ${@:+"$@"}
}
