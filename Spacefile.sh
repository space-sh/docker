#
# Copyright 2016 Blockie AB
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

clone os

#======================
# DOCKER_DEP_INSTALL
#
# Verify that Docker Engine is installed
# otherwise install it.
#
# Parameters:
#   $1: user to add to docker group.
#
# Expects:
#   ${SUDO}: set to "sudo" to run as sudo.
#
# Returns:
#   0: success
#   1: failure
#
#======================
DOCKER_DEP_INSTALL ()
{
    SPACE_SIGNATURE="targetuser"
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
# Expects:
#   ${SUDO}: set to "sudo" to run as sudo.
#
# Returns:
#   0: success
#   1: failure
#
#======================
DOCKER_INSTALL ()
{
    SPACE_SIGNATURE="targetuser"
    SPACE_DEP="PRINT OS_IS_INSTALLED OS_USER_ADD_GROUP OS_SERVICE"
    SPACE_ENV="SUDO=\${SUDO-}"

    local targetuser="${1}"
    shift

    PRINT "Install Docker Engine.." "info"
    local SUDO="${SUDO-}"
    OS_IS_INSTALLED "curl" "curl"
    ${SUDO} curl -sL https://get.docker.com/ | sh &&
    OS_USER_ADD_GROUP "${targetuser}" "docker" &&
    OS_SERVICE "docker" "start"
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
DOCKER_RUN ()
{
    SPACE_SIGNATURE="image [container flags cmd args]"
    SPACE_DEP="PRINT"

    local image="${1}"
    shift

    local container="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local flags="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local cmd="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local args="${1-}"

    if [ -z "${image}" ]; then
        PRINT "Missing args: image [container flags cmd args]" "error"
        return 1
    fi

    if [ "${args}" != "" ] && [ "${cmd}" = "" ]; then
        PRINT "Cannot have args without cmd, setting default: sh -c." "debug"
        cmd="sh -c"
    fi

    PRINT "Run image ${image} flags: ${flags}." "debug"

    # shellcheck disable=2086
    docker run ${flags} ${container:+--name ${container}} "${image}" ${cmd} "${@}"
}

#=====================
# DOCKER_RUN_WRAP
#
# Wrap a command to be run inside a newly created container.
#
# Expects:
#   ${image}
#   ${container} (optional)
#   ${flags}
#   ${cmd}
#
#=====================
DOCKER_RUN_WRAP ()
{
    SPACE_FN="DOCKER_RUN"
    SPACE_ENV="image container=\${container-} flags cmd=\${cmd-}"
    # shellcheck disable=2016
    SPACE_ARGS='"${image}" "${container}" "${flags}" "${cmd-}" "${CMD}"'
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
DOCKER_EXEC ()
{
    SPACE_SIGNATURE="container flags cmd [args]"
    SPACE_DEP="PRINT"

    local container="${1}"
    shift

    local flags="${1}"
    shift

    local cmd="${1}"
    shift

    if [ "${cmd}" = "" ]; then
        PRINT "Setting default cmd: sh -c." "debug"
        cmd="sh -c"
    fi

    PRINT "Exec in ${container}." "debug"
    PRINT "cmd: ${cmd}." "debug"

    # shellcheck disable=2086
    docker exec ${flags} "${container}" ${cmd} "${@}"
}

#=====================
# DOCKER_EXEC_WRAP
#
# Wrap another command to be run inside an existing container.
#
# Expects:
#   ${container}
#   ${flags} (optional)
#   ${cmd} (optional)
#   ${CMD is the space function to be wrapped.}
#
#=====================
DOCKER_EXEC_WRAP ()
{
    # shellcheck disable=2034
    SPACE_FN="DOCKER_EXEC"
    # shellcheck disable=2034
    SPACE_ENV="container flags=\${flags--i} cmd=\${cmd-}"
    # shellcheck disable=2034
    # shellcheck disable=2016
    SPACE_ARGS='"${container}" "${flags}" "${cmd}" "${CMD}"'
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
DOCKER_ENTER ()
{
    SPACE_SIGNATURE="container [shell]"
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
# DOCKER_LS_BY_STATUS
#
# List all containers filtered by status.
#
# Parameters;
#   $1: status string, ex "Exited".
#
#=============================
DOCKER_LS_BY_STATUS ()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="status"

    # shellcheck disable=SC2039
    local status="${1}"
    shift

    docker ps -a | grep "${status}" | awk '{print $1}'
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
DOCKER_RM_BY_STATUS ()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="status"

    # shellcheck disable=SC2039
    local status="${1}"
    shift

    docker ps -a | grep "${status}" | awk '{print $1}' | xargs docker rm -f
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
DOCKER_RM_BY_ID ()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="ids"

    local ids="${1}"
    shift

    local id=
    for id in ${ids}; do
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
DOCKER_PS ()
{
    docker ps ${@:+"$@"}
}

