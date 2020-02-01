#!/bin/sh 

set -vx

###############################################################################
#                                                                             #
#                   Program      :    utility_func.sh                         #
#                   Author       :    itachi                                  #
#                   Publish      :    30-Jan-2020                             #
#                   Version      :    1.0                                     #
#                                                                             #
###############################################################################
#                                                                             #
#   Functions:-                                                               #
#                                                                             #
#     1. check_ora_log -> checking ora errors in logfile                      #
#     2. check_ftp_log -> checking ftp errors in ftp logfile                  #
#     3. report_header -> prints a report header in file                      #
#     4. removeCR      -> remove carriage return from a file                  #
#                                                                             #
###############################################################################
#                                                                             #
#   Version History:-                                                         #
#                                                                             #
#     -------     -----         ------        ------------------              #
#     Version     Dated         Author        Change Description              #
#     -------     -----         ------        ------------------              #
#       1.0   30-Jan-2020       itachi        Script Initialization           #
#       1.1   31-Jan-2020       itachi        Added functions 1-4             #
#                                                                             #
###############################################################################

machine=`uname -n`
sysdate=`date +%Y%m%d_%H%M`

LOG=tmp_${sysdate}.log

pad () {
    len=$1
    string=$2

    n_pad=$(( (len - ${#string} - 2) / 2 ))

    printf "%${n_pad}s" | tr ' ' "*"
    printf ' %s ' "$string"
    printf "%${n_pad}s\n" | tr ' ' "*"
}


new_printf() {
    star79=`printf "%*s\n" 79 " "|tr " " "*"`
    star5=`printf "%*s\n" 5 " "|tr " " "*"`
    
    header=${header}
    padding_str=${star5}
    program=${program}
    OCCURANCE=${OCCURANCE}
    errText=${errText}
    logfile=${logfile}
    exitMess=${exitMess}

printf "%-79s\n\
%-5s%74s\n\
%-10s%-59s%10s\n\
%-10s%02d%-19s%-38s%10s\n\
%-10s%-59s%10s\n\
%-5s%74s\n\
%-79s\n\n" "${header}" "${padding_str}" "${padding_str}" \
"${padding_str}" "${program}" "${padding_str}" \
"${padding_str}" "${OCCURANCE}" " ${errText} " "${logfile}" "${padding_str}" \
"${padding_str}" "${exitMess}" "${padding_str}" "${padding_str}" "${padding_str}" "${star79}" 
}


check_ora_log()
{
    header=`pad 80 "ORACLE ERROR CHECKING"`
    errText="ERROR(S) found in"
    logfile=${1}
 
    OCCURANCE=0
    OCCURANCE=`grep -c -f /home/itachi/myprojects/shellApps/ora_err_message ${1}`
    if [ ${OCCURANCE} -ne 0 ]
    then
        program="ORACLE Program didn't run properly"
        exitMess="Exiting program with ERROR CODE 1"
        new_printf >> ${LOG}               
        exit 1
    else
        program="ORACLE Program ran SUCCESSFULLY"
        exitMess=" "
        new_printf >> ${LOG}       
    fi 
}


check_ftp_log()
{
    header=`pad 80 "FTP ERROR  CHECKING"`
    errText="ERROR(S) found in"
    logfile=${1}
 
    OCCURANCE=0
    OCCURANCE=`grep -ic -f /home/itachi/myprojects/shellApps/ftp_err_message ${1}`
    if [ ${OCCURANCE} -ne 0 ]
    then
        program="FTP TRANSFER didn't run properly"
        exitMess="Exiting program with ERROR CODE 1"
        new_printf >> ${LOG}               
        exit 1
    else
        program="FTP TRANSFER SUCCESS"
        exitMess=" "
        new_printf >> ${LOG}       
    fi 
}


removeCR()
{
    #####   Function to remove Carriage return from the files   #####
    sed '%s///g' ${1} > tempfileCR
    mv tempfileCR ${1}
}


report_header()
{
    #####   Function to display the log Header  #####
    echo "\n************************************************"
    echo "*****              Log Report              *****"
    echo "*****                                      *****"
    echo "*****     Operating Sytem:`uname -n`       *****"
    echo "*****     Dated:  `date +%d%b%Y`             *****" 
    echo "*****                                      *****"
    echo "************************************************"
}

report_footer()
{
    #####   Function to display the log Footer  #####
    echo "\n************************************************"
    echo "*****             End of Report            *****" 
    echo "************************************************"
}

check_ftp_log oralog
check_ora_log ftplog
# check_ora_log oralog
check_ftp_log ftplog

