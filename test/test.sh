_source "${DIR}/../Spacefile.sh"

_DOCKER_CHECK_NO_VOLUME ()
{
    SPACE_SIGNATURE="name"
    SPACE_CMDDEP="DOCKER_VOLUME_LS PRINT"

    local name="${1}"
    shift

    local volumes=
    volumes="$(DOCKER_VOLUME_LS -q | grep "^${name}\$"; :)"
    if [ -n "${volumes}" ]; then
        PRINT "Volume ${name} exists." "error"
        return 1
    fi
}

_DOCKER_CHECK_VOLUME ()
{
    # shellcheck disable=2034
    SPACE_SIGNATURE="name"
    # shellcheck disable=2034
    SPACE_CMDDEP="DOCKER_VOLUME_LS PRINT"

    local name="${1}"
    shift

    local volumes=
    volumes="$(DOCKER_VOLUME_LS -q | grep "^${name}\$"; :)"
    if [ -z "${volumes}" ]; then
        PRINT "Volume ${name} does not exist." "error"
        return 1
    fi
}
