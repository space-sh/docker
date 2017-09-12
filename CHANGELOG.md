# Space Module change log - docker

## [1.1.0 - 2017-08-28]

+ Add `logs` operation

+ Add optional flags support for `ps` operation

* Fix bugs in dependencies install for non-root accounts when docker group already exists

* Change `run` operation to consider multiple arguments as parameters

* Change `exec` operation to consider multiple arguments as parameters


## [1.0.3 - 2017-06-11]

* Update documentation


## [1.0.2 - 2017-05-16]

- Remove old `SUDO` behavior

- Remove unwanted surrounding quotes in `DOCKER_RUN` command


## [1.0.1 - 2017-04-26]

* Update auto completion

* Change `SPACE_SIGNATURE` to consider parameter constraints

* Change `RUN_WRAP` function to `WRAP_RUN`

* Change `/run_wrap/` to `/wrap_run/`

* Change `EXEC_WRAP` function to `WRAP_EXEC`

* Change `/exec_wrap/` to `/wrap_exec/`

* Update node descriptions

* Update include and clone statements


## [1.0.0 - 2017-04-12]

+ Initial version
