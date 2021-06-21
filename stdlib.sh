###
### stdlib.sh - foundation library for Bash scripts
### Need Bash version 4.3 or above 
###
### Areas covered:
###     - logging
###     - error handling
###

################################################# INITIALIZATION #######################################################

#
# make sure we do nothing in case the library is sourced more than once in the same shell
#
[[ $__stdlib_sourced__ ]] && return
__stdlib_sourced__=1

#
# The only code that executes when the library is sourced
#
__stdlib_init__() {
    __log_init__

    # call future init functions here
}

#################################################### LOGGING ###########################################################

__log_init__() {
    if [[ -t 1 ]]; then
        # colors for logging in interactive mode
        [[ $COLOR_BOLD ]]   || COLOR_BOLD="\033[1m"
        [[ $COLOR_RED ]]    || COLOR_RED="\033[0;31m"
        [[ $COLOR_GREEN ]]  || COLOR_GREEN="\033[0;34m"
        [[ $COLOR_YELLOW ]] || COLOR_YELLOW="\033[0;33m"
        [[ $COLOR_BLUE ]]   || COLOR_BLUE="\033[0;32m"
        [[ $COLOR_OFF ]]    || COLOR_OFF="\033[0m"
    else
        # no colors to be used if non-interactive
        COLOR_RED= COLOR_GREEN= COLOR_YELLOW= COLOR_BLUE= COLOR_OFF=
    fi
    readonly COLOR_RED COLOR_GREEN COLOR_YELLOW COLOR_BLUE COLOR_OFF

    #
    # map log level strings (FATAL, ERROR, etc.) to numeric values
    #
    # Note the '-g' option passed to declare - it is essential
    #
    unset _log_levels _loggers_level_map
    declare -gA _log_levels _loggers_level_map
    _log_levels=([FATAL]=0 [ERROR]=1 [WARN]=2 [INFO]=3 [DEBUG]=4 [VERBOSE]=5)

    #
    # hash to map loggers to their log levels
    # the default logger "default" has INFO as its default log level
    #
    _loggers_level_map["default"]=3  # the log level for the default logger is INFO
}

#
# set_log_level
#
set_log_level() {
    local logger=default in_level l
    [[ $1 = "-l" ]] && { logger=$2; shift 2 2>/dev/null; }
    in_level="${1:-INFO}"
    if [[ $logger ]]; then
        l="${_log_levels[$in_level]}"
        if [[ $l ]]; then
            _loggers_level_map[$logger]=$l
        else
            printf '[%(%Y-%m-%d:%H:%M:%S)T] %-7s %s\n' -1 WARN \
                "${BASH_SOURCE[2]}:${BASH_LINENO[1]} Unknown log level '$in_level' for logger '$logger'; setting to INFO"
            _loggers_level_map[$logger]=3
        fi
    else
        printf '[%(%Y-%m-%d:%H:%M:%S)T] %-7s %s\n' -1 WARN \
            "${BASH_SOURCE[2]}:${BASH_LINENO[1]} Option '-l' needs an argument" >&2
    fi
}

#
# Core and private log printing logic to be called by all logging functions.
# Note that we don't make use of any external commands like 'date' and hence we don't fork at all.
# We use the Bash's printf builtin instead.
#
_print_log() {
    local in_level=$1; shift
    local logger=default log_level_set log_level
    [[ $1 = "-l" ]] && { logger=$2; shift 2; }
    log_level="${_log_levels[$in_level]}"
    log_level_set="${_loggers_level_map[$logger]}"
    if [[ $log_level_set ]]; then
        ((log_level_set >= log_level)) && {
            printf '[%(%Y-%m-%d:%H:%M:%S)T] %-7s %s ' -1 "$in_level" "${BASH_SOURCE[2]}:${BASH_LINENO[1]}   :-  "
            printf '%s\n' "$@"
        }
    else
        printf '[%(%Y-%m-%d:%H:%M:%S)T] %-7s %s\n' -1 WARN "${BASH_SOURCE[2]}:${BASH_LINENO[1]} Unknown logger '$logger'"
    fi
}

#
# core function for logging contents of a file
#
_print_log_file()   {
    local in_level=$1; shift
    local logger=default log_level_set log_level file
    [[ $1 = "-l" ]] && { logger=$2; shift 2; }
    file=$1
    log_level="${_log_levels[$in_level]}"
    log_level_set="${_loggers_level_map[$logger]}"
    if [[ $log_level_set ]]; then
        if ((log_level_set >= log_level)) && [[ -f $file ]]; then
            log_debug "Contents of file '$1':" 
            cat -- "$1"
        fi
    else
        printf '[%(%Y-%m-%d:%H:%M:%S)T] %s\n' -1 "WARN ${BASH_SOURCE[2]}:${BASH_LINENO[1]} Unknown logger '$logger'"
    fi
}

#
# main logging functions
#
log_fatal()   { _print_log FATAL   "$@"; }
log_error()   { _print_log ERROR   "$@"; }
log_warn()    { _print_log WARN    "$@"; }
log_info()    { _print_log INFO    "$@"; }
log_debug()   { _print_log DEBUG   "$@"; }
log_verbose() { _print_log VERBOSE "$@"; }
log_header()  { _print_log_header INFO "$@"; }
#
# logging file content
#
log_info_file()    { _print_log_file INFO    "$@"; }
log_debug_file()   { _print_log_file DEBUG   "$@"; }
log_verbose_file() { _print_log_file VERBOSE "$@"; }
#
# logging for function entry and exit
#
log_info_enter()    { _print_log INFO    "+++++   Entering Function ${FUNCNAME[1]}    +++++"; }
log_info_leave()    { _print_log INFO    "-----   Leaving Function ${FUNCNAME[1]}     -----";  }


################################################## ERROR HANDLING ######################################################

dump_trace() {
    local frame=0 line func source n=0
    while caller "$frame"; do
        ((frame++))
    done | while read line func source; do
        ((n++ == 0)) && {
            printf 'Encountered a fatal error\n'
        }
        printf '%4s at %s\n' " " "$func ($source:$line)"
    done
}

exit_if_error() {
    (($#)) || return
    local num_re='^[0-9]+'
    local rc=$1; shift
    local message="${@:-No message specified}"
    if ! [[ $rc =~ $num_re ]]; then
        log_error "'$rc' is not a valid exit code; it needs to be a number greater than zero. Treating it as 1."
        rc=1
    fi
    ((rc)) && {
        log_fatal "$message"
        dump_trace "$@"
        exit $rc
    }
    return 0
}

fatal_error() {
    local ec=$?                # grab the current exit code
    ((ec == 0)) && ec=1        # if it is zero, set exit code to 1
    exit_if_error "$ec" "$@"
}

#
# run a simple command (no compound statements or pipelines) and exit if it exits with non-zero 
#
run_simple() {
    log_debug "Running command: $*"
    "$@"
    exit_if_error $? "run failed: $@"
}


################################################# MISC FUNCTIONS #######################################################
#
#####   Execute SQL Script and Logging   #####
#
execute_sql() 
{
    log_info_enter

    export ORACLE_HOME=/oracle/app/oracle/product/12.1.0/client_1
    export ORACLE_BASE=/oracle
    export PATH=${ORACLE_HOME}/bin:${PATH}
    export TNS_ADMIN=${ORACLE_HOME}/network/admin
    
    echo " 
        set serveroutput on size unlimited
        set feed off;
        set pagesize 0;
        set linesize 5000;
        whenever oserror exit oscode rollback;
        whenever sqlerror exit sql.sqlcode rollback;
        @"${1}"
        set serveroutput off;
        exit;" | "${ORACLE_HOME}"/bin/sqlplus -s "${ORA_CONN}" >"${2}"

    SQLPLUS_RC=$?
    log_info_file "${2}" 
    if [ -f "${2}" ]
    then
        log_info "Removing sql logfile...."
        rm "${2}"
    fi
    exit_if_error "${SQLPLUS_RC}" "Sql Execution Failed with status code ${SQLPLUS_RC}"

    log_info_leave
}    

#
#####   Print Header    #####
#
_print_log_header() 
{
    local in_level=$1; shift
    local logger=default log_level_set log_level
    [[ $1 = "-l" ]] && { logger=$2; shift 2; }
    log_level="${_log_levels[$in_level]}"
    log_level_set="${_loggers_level_map[$logger]}"
    echo -e "               ========================================================================="
    echo -e "                                   SCRIPT_NAME :   ${PROGNAME}.sh"
    echo -e "                                     HOST_NAME :   ${MACHINE}"
    echo -e "                                    START_TIME :   $(date)"
    echo -e "               =========================================================================\n\n\n"
}

#
#####   Print Footer    #####
#
log_footer() 
{
    echo -e "\n\n               =========================================================================" >> ${LOG_FILE}
    echo -e "                                     END_TIME  :       $(date +%Y-%m-%d:%H%M)" >> ${LOG_FILE}
    echo -e "               =========================================================================\n\n" >> ${LOG_FILE}
}

#
#####   atexit FUNCTION     #####
#
atexit()
{

    echo -e "\n               ======================          at exit           =======================" >> ${LOG_FILE}
    echo -e "               Job Status=${JOB_STATUS}            " >> ${LOG_FILE}

    ELAPSED_TIME=${SECONDS}
    echo -e "               ==================================================" >> ${LOG_FILE}
    echo -e "               Elapsed Time:          $((${ELAPSED_TIME} / 60)) minutes and $((${ELAPSED_TIME} % 60)) seconds" >> ${LOG_FILE}
    echo -e "               ==================================================" >> ${LOG_FILE} >> ${LOG_FILE}
    echo -e "               =========================================================================" >> ${LOG_FILE}

}
################################################# MISC FUNCTIONS #######################################################
#
# For functions that need to return a single value, we use the global variable OUTPUT.
# For functions that need to return multiple values, we use the global variable OUTPUT_ARRAY.
# These global variables eliminate the need for a subshell when the caller wants to retrieve the
# returned values.
#
# Each function that makes use of these global variables would call __clear_output__ as the very first step.
#
__clear_output__() { unset OUTPUT OUTPUT_ARRAY; }

#
# return path to parent script's source directory
#
get_my_source_dir() {
    __clear_output__

    # Reference: https://stackoverflow.com/a/246128/6862601
    OUTPUT="$(cd "$(dirname "${BASH_SOURCE[1]}")" >/dev/null 2>&1 && pwd -P)"
}

#
# wait for user to hit Enter key
#
wait_for_enter() {
    local prompt=${1:-"Press Enter to continue"}
    read -r -n1 -s -p "Press Enter to continue" </dev/tty
}

#
# Control the set_log_level using file
#
debug_file_control() {
    local file="/tmp/set_debug_flag"
    if [ -f "$file" ]; then
        local FLAG=$(cat "$file")
        if [ "$FLAG" = "VERBOSE" -o "$FLAG" = "DEBUG" -o "$FLAG" = "INFO" -o "$FLAG" = "WARN" ]; then
            echo $FLAG
            set_log_level "$FLAG"
            log_info "Default Log_Level set to:     $FLAG"
        else
            log_error "Not a valid DEBUG Level, set a valid level[ VERBOSE|DEBUG|INFO|WARN ] in /tmp/set_debug_flag"
            exit 1
        fi
        rm -f "$file"
    else
        set_log_level INFO
    fi
}

#################################################### END OF FUNCTIONS ##################################################

__stdlib_init__

#debug_file_control
