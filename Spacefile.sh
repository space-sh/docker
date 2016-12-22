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

clone os file

##======================
## DOCKER_OS_DEP_INSTALL
##
## Install latest Docker on and make it available to the user.
##
#======================
DOCKER_DEP_INSTALL ()
{
    SPACE_SIGNATURE="targetuser"
    SPACE_CMDDEP="PRINT OS_UPGRADE OS_IS_INSTALLED OS_USER_ADD_GROUP OS_SERVICE"
    SPACE_CMDENV="SUDO=\${SUDO-}"

    local targetuser="${1}"
    shift

    PRINT "Install Docker Engine.." "info"

    local SUDO="${SUDO-}"
    OS_IS_INSTALLED "curl" "curl"
    ${SUDO} curl -L https://get.docker.com/ | sh &&
    OS_USER_ADD_GROUP "${targetuser}" "docker" &&
    OS_SERVICE "docker" "start"
}

##=====================
## DOCKER_RUN
##
##
##=====================
DOCKER_RUN ()
{
    SPACE_SIGNATURE="image container [flags cmd args]"
    SPACE_CMDDEP="PRINT"

    local image="${1}"
    shift

    local container="${1}"
    shift

    local flags="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local cmd="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local args="${1-}"
    #shift $(( $# > 0 ? 1 : 0 ))

    if [ "${args}" != "" ] && [ "${cmd}" = "" ]; then
        PRINT "Cannot have args without cmd, setting default: sh -c." "debug"
        cmd="sh -c"
        return 1
    fi

    PRINT "Run ${image}." "debug"

    # shellcheck disable=2086
    docker run ${flags} ${container:+--name ${container}} "${image}" ${cmd} "${@}"
}

##=====================
## DOCKER_RUN_WRAP
##
##
##=====================
DOCKER_RUN_WRAP ()
{
    SPACE_CMD="DOCKER_RUN"
    SPACE_CMDENV="image container=\${container-} flags cmd"
    # shellcheck disable=2016
    SPACE_CMDARGS='"${image}" "${container-}" "${flags}" "${cmd}" "${CMD}"'
}

##=====================
## DOCKER_EXEC
##
##
##=====================
DOCKER_EXEC ()
{
    SPACE_SIGNATURE="container flags cmd [args]"
    SPACE_CMDDEP="PRINT"

    local container="${1}"
    shift

    local flags="${1}"
    shift

    local cmd="${1}"
    shift

    #local args="${1-}"
    #shift $(( $# > 0 ? 1 : 0 ))

    PRINT "Exec in ${container}." "debug"
    PRINT "cmd: ${cmd}." "debug"
    PRINT "args: ${*}." "debug"

    # shellcheck disable=2086
    docker exec ${flags} "${container}" ${cmd} "${@}"
}

##=====================
## DOCKER_ENTER
##
##
##=====================
DOCKER_ENTER ()
{
    SPACE_SIGNATURE="container [shell]"
    SPACE_CMDDEP="PRINT"

    local container="${1}"
    shift

    local shell="${1:-sh}"
    shift $(( $# > 0 ? 1 : 0 ))

    PRINT "Enter ${container} using ${shell}." "debug"

    # shellcheck disable=2086
    docker exec -ti "${container}" ${shell}
}

##=============================
## DOCKER_RM_STATUS
##
##=============================
DOCKER_RM_STATUS ()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="status"

    local status="${1}"
    shift

    docker ps -a | grep "${status}" | awk '{print $1}' | xargs docker rm -f
}

##=====================
## DOCKER_PS
##
##
##=====================
DOCKER_PS ()
{
    docker ps ${@:+"$@"}
}

##=====================
## DOCKER_EXEC_WRAP
##
##
##=====================
DOCKER_EXEC_WRAP ()
{
    SPACE_CMD="DOCKER_EXEC"
    # shellcheck disable=2034
    SPACE_CMDENV="container flags cmd"
    # shellcheck disable=2016
    SPACE_CMDARGS='"${container}" "${flags}" "${cmd}" "${CMD}"'
}

##=====================
## DOCKER_VOLUME_RM
##
##
##=====================
DOCKER_VOLUME_RM ()
{
    SPACE_SIGNATURE="volume [volume]"
    docker volume rm "${@}"
}

##=====================
## DOCKER_VOLUME_LS
##
##
##=====================
DOCKER_VOLUME_LS ()
{
    SPACE_SIGNATURE="[flags]"
    docker volume ls "${@}"
}

##=====================
## DOCKER_LOGS
##
##
##=====================
DOCKER_LOGS ()
{
    SPACE_SIGNATURE="container [flags]"
    docker logs "${@}"
}

##======================
## DOCKER_VOLUME_RESTORE
##
## Restore a tar.gz archive or local dir into a volume,
## possibly delete all files in volume first.
##
## If archive is local dir, beware of permissions, all files
## will be extraced as root:root, which may brake stuff if
## your applications runs as other users than root.
## However when restoring a snapshot tar.gz taken, permissions are preserved.
##
## If using $useacl=1, which is the default, then a permissions
## dump is taken of the target directory and is used to restore
## permissions after the snapshot have been extracted.
##
##=====================
DOCKER_VOLUME_RESTORE()
{
    SPACE_SIGNATURE="volumename archive.tar.gz|dir|- [rmrf targetdir image savepermissions flags]"
    SPACE_CMD="_DOCKER_VOLUME_RESTORE_IMPL"
    SPACE_CMDWRAP="DOCKER_RUN_WRAP"

    local volume="${1}"
    shift

    local archive="${1}"
    shift

    local rmrf="${1:-0}"
    shift $(( $# > 0 ? 1 : 0 ))

    local targetdir="${1:-/volume}"
    shift $(( $# > 0 ? 1 : 0 ))

    # This variable will get exported.
    image="${1:-alpine}"
    shift $(( $# > 0 ? 1 : 0 ))

    local savepermissions="${1:-1}"
    shift $(( $# > 0 ? 1 : 0 ))

    # This variable will get exported.
    flags="${1:-}"
    shift $(( $# > 0 ? 1 : 0 ))
    if [ "${flags}" = "" ]; then
        flags="-i --rm -v ${volume}:${targetdir}"
    fi

    if [ "${archive}" = "-" ]; then
        if [ -t "0" ]; then
            PRINT "OMG STDIN is a terminal! I was totally expecting a tar.gz stream." "error"
            return 1
        fi
    else
        if [ -d "${archive}" ]; then
            # TODO Bashism
            SPACE_CMDREDIR="< <(cd ${archive}; tar -cvzf --owner=root --group=root - .)"
        else
            SPACE_CMDREDIR="<${archive}"
        fi
    fi

    # These variables will get exported.
    container=
    cmd="sh -c"

    SPACE_CMDARGS="\"${targetdir}\" \"${rmrf}\" \"${savepermissions}\""
}

##=====================
## _DOCKER_VOLUME_RESTORE_IMPL
##
##
##=====================
_DOCKER_VOLUME_RESTORE_IMPL ()
{
    SPACE_SIGNATURE="targetdir rmrf savepermissions"
    SPACE_CMDDEP="PRINT FILE_GET_PERMISSIONS FILE_RESTORE_PERMISSIONS"

    local targetdir="${1}"
    shift

    local rmrf="${1}"
    shift

    local savepermissions="${1}"
    shift

    if [ -t "0" ]; then
        PRINT "OMG STDIN is a terminal! I was so expecting a tar.gz stream." "error"
        return 1
    fi

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    if [ "${rmrf}" = "1" ]; then
        rm -rf "${targetdir:?}/"* 2>/dev/null
    fi

    local permissions=
    if [ "${savepermissions}" = "1" ]; then
        permissions="$(FILE_GET_PERMISSIONS "${targetdir}")"
    fi

    PRINT "tar -xvz -C ${targetdir}" "debug"

    tar -xvz -C "${targetdir}"
    if [ "$?" -gt 0 ]; then
        return 1
    fi

    if [ "${savepermissions}" = "1" ]; then
        FILE_RESTORE_PERMISSIONS "${targetdir}" "${permissions}"
    fi
}

##======================
## DOCKER_VOLUME_EMPTY
##
## Delete all files in a volume.
##
##=====================
DOCKER_VOLUME_EMPTY ()
{
    SPACE_SIGNATURE="volume [targetdir image flags]"
    SPACE_CMD="_DOCKER_VOLUME_EMPTY_IMPL"
    SPACE_CMDWRAP="DOCKER_RUN_WRAP"

    local volume="${1}"
    shift

    local targetdir="${1:-/volume}"
    shift $(( $# > 0 ? 1 : 0 ))

    # This variable will get exported.
    image="${1:-alpine}"
    shift $(( $# > 0 ? 1 : 0 ))

    # This variable will get exported.
    flags="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))
    if [ "${flags}" = "" ]; then
        flags="-i --rm -v ${volume}:${targetdir}"
    fi

    # These variables will get exported.
    container=
    cmd="sh -c"

    SPACE_CMDARGS="\"${targetdir}\""
}

##=====================
## _DOCKER_VOLUME_EMPTY_IMPL
##
##
##=====================
_DOCKER_VOLUME_EMPTY_IMPL ()
{
    SPACE_SIGNATURE="targetdir"
    # shellcheck disable=2034
    SPACE_CMDDEP="PRINT"

    local targetdir="${1}"
    shift

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    rm -rf "${targetdir:?}/"* 2>/dev/null
}

##======================
## DOCKER_VOLUME_CHMOD
##
## Set the permissions of the mountpoint for a volume.
##
##=====================
DOCKER_VOLUME_CHMOD ()
{
    SPACE_SIGNATURE="volume chmod [chown targetdir image flags]"
    SPACE_CMD="_DOCKER_VOLUME_CHMOD_IMPL"
    SPACE_CMDWRAP="DOCKER_RUN_WRAP"

    local volume="${1}"
    shift

    local chmod="${1}"
    shift

    local chown="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local targetdir="${1:-/volume}"
    shift $(( $# > 0 ? 1 : 0 ))

    # This variable will get exported.
    image="${1:-alpine}"
    shift $(( $# > 0 ? 1 : 0 ))

    # This variable will get exported.
    flags="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))
    if [ "${flags}" = "" ]; then
        flags="-i --rm -v ${volume}:${targetdir}"
    fi

    # These variables will get exported.
    container=
    cmd="sh -c"

    SPACE_CMDARGS="\"${targetdir}\" \"${chmod}\" \"${chown}\""
}

##=====================
## _DOCKER_VOLUME_CHMOD_IMPL
##
##
##=====================
_DOCKER_VOLUME_CHMOD_IMPL ()
{
    SPACE_SIGNATURE="targetdir chmod [chown]"
    SPACE_CMDDEP="PRINT"

    local targetdir="${1}"
    shift

    local _chmod="${1}"
    shift

    local _chown="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    if [ -n "${_chmod}" ]; then
        chmod "${_chmod}" "${targetdir}"
    fi
    if [ -n "${_chown}" ]; then
        chown "${_chown}" "${targetdir}"
    fi
}

##=====================
## DOCKER_VOLUME_CREATE
##
## docker volume create.
##
##=====================
DOCKER_VOLUME_CREATE()
{
    SPACE_SIGNATURE="volumename [driver opts label]"
    SPACE_CMDDEP="PRINT"

    local volume="${1}"
    shift

    local driver="${1-}"
    shift

    local opts="${1-}"
    shift

    # TODO allow for more than one label.
    local label="${1-}"
    shift

    PRINT "Create Docker volume" "debug"
    # shellcheck disable=2086
    docker volume create --name "${volume}" ${driver:+--driver ${driver}} ${opts:+--opt ${opts}} ${label:+--label ${label}}
}

##=====================
## DOCKER_VOLUME_INSPECT
##
##
##=====================
DOCKER_VOLUME_INSPECT ()
{
    SPACE_SIGNATURE="volume [args]"
    docker volume inspect "${@}"
}

##=====================
## DOCKER_INSPECT
##
##
##=====================
DOCKER_INSPECT ()
{
    SPACE_SIGNATURE="container [args]"
    docker inspect "${@}"
}

##=====================
## DOCKER_COMPOSE
##
##
##=====================
DOCKER_COMPOSE ()
{
    SPACE_SIGNATURE="args"
    docker-compose "${@}"
}

##=======================
## DOCKER_VOLUME_SNAPSHOT
##
## Archive all files inside volume into
## a tar.gz archive, or optionally to stdout.
##
##=======================
DOCKER_VOLUME_SNAPSHOT ()
{
    SPACE_SIGNATURE="volumename archive.tar.gz|dir|- [targetdir image flags]"
    # shellcheck disable=2034
    SPACE_CMDWRAP="DOCKER_RUN_WRAP"
    # shellcheck disable=2034
    SPACE_CMD="_DOCKER_VOLUME_SNAPSHOT_IMPL"

    local volume="${1}"
    shift

    local archive="${1}"
    shift

    local targetdir="${1:-/volume}"
    shift $(( $# > 0 ? 1 : 0 ))

    # This variable will get exported.
    image="${1:-alpine}"
    shift $(( $# > 0 ? 1 : 0 ))

    # This variable will get exported.
    flags="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))
    if [ "${flags}" = "" ]; then
        flags="-i --rm -v ${volume}:${targetdir}"
    fi

    if [ "${archive}" = "-" ]; then
        if [ -t 1 ]; then
            PRINT "[error] OMG STDOUT is a terminal! You do not want this." "error"
            return 1
        fi
    else
        if [ -d "${archive}" ]; then
            # shellcheck disable=2034
            SPACE_CMDREDIR="| tar -xzf - -C ${archive}"
        else
            # shellcheck disable=2034
            SPACE_CMDREDIR=">${archive}"
        fi
    fi

    # These variables will get exported.
    container=
    cmd="sh -c"
    # shellcheck disable=2034
    SPACE_CMDARGS="${targetdir}"
}

##=======================
## _DOCKER_VOLUME_SNAPSHOT_IMPL
##
##
##=======================
_DOCKER_VOLUME_SNAPSHOT_IMPL ()
{
    # shellcheck disable=2034
    SPACE_SIGNATURE="targetdir"
    # shellcheck disable=2034
    SPACE_CMDDEP="PRINT"

    local targetdir="${1}"
    shift

    if [ -t "1" ]; then
        PRINT "OMG STDOUT is a terminal! We are so different, you and I." "error"
        return 1
    fi

    if ! mountpoint -q "${targetdir}"; then
        PRINT "Target dir ${targetdir} is not a mountpoint, it must be a mounted volume." "error"
        return 1
    fi

    cd "${targetdir}" && tar -cvz .
}
