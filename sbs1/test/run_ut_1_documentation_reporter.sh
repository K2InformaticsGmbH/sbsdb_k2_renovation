#!/bin/bash

exec > >(tee -i run_ut_1_documentation_reporter.log)
sleep .1

# ------------------------------------------------------------------------------
#
# run_ut_1_documentation_reporter.sh: SBSDB - unit testing of all test suites.
#
# ------------------------------------------------------------------------------

EXITCODE="0"

docker start sbsdb

DOCKER_IP_DEFAULT=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" sbsdb)

printf "Enter Database IP Address [default: $DOCKER_IP_DEFAULT]: \n"; read DOCKER_IP; stty echo; printf "\n"

if [ -z $DOCKER_IP ]; then
    DOCKER_IP=$DOCKER_IP_DEFAULT
fi

PASSWORD_SYS=$1
PASSWORD_SBSDB=$2

if [ "$#" -ne 2 ]; then
    stty -echo
    printf "Enter SYS password: \n";    read PASSWORD_SYS; stty echo; printf "\n"
    stty -echo
    printf "Enter SBSDB password: \n";  read PASSWORD_SBSDB; stty echo; printf "\n"
fi

ORACLE_PDB=ORCLPDB1
CONNECT_IDENTIFIER=//$DOCKER_IP:1521/$ORACLE_PDB
USERNAME_SBSDB=sbs1_admin
VERSION=utPLSQL-cli-3.1.7

echo "========================================================================="
echo "Start $0"
echo "-------------------------------------------------------------------------"
echo "Unit testing of all test suites - documentation reporter"
echo "-------------------------------------------------------------------------"
echo "USERNAME_SBSDB      : $USERNAME_SBSDB"
echo "CONNECT_IDENTIFIER  : $CONNECT_IDENTIFIER"
echo "utPLSQL-cli VERSION : $VERSION"
echo "-------------------------------------------------------------------------"
date +"DATE TIME           : %d.%m.%Y %H:%M:%S"
echo "-------------------------------------------------------------------------"

(
    echo @install/sbsdb_ut_schema_ut_create_or_update.sql $USERNAME_SBSDB $USERNAME_SBSDB $PASSWORD_SBSDB
    echo exit
) | sqlplus -s sys/$PASSWORD_SYS@$CONNECT_IDENTIFIER as sysdba

(
    echo @install/generated/sbsdb_ut_execute_grant_test.sql $USERNAME_SBSDB
    echo exit
) | sqlplus -s $USERNAME_SBSDB/$PASSWORD_SBSDB@$CONNECT_IDENTIFIER

echo ""
echo "$VERSION/bin/utplsql run $USERNAME_SBSDB/...@$CONNECT_IDENTIFIER"
echo "        -c"
echo "        -f=ut_documentation_reporter"
echo "        -p=$USERNAME_SBSDB"
echo ""
$VERSION/bin/utplsql run $USERNAME_SBSDB/$PASSWORD_SBSDB@$CONNECT_IDENTIFIER \
            -c \
            -f=ut_documentation_reporter \
            -p=$USERNAME_SBSDB

EXITCODE=$?

echo "========================================================================="
date +"DATE TIME           : %d.%m.%Y %H:%M:%S"
echo "-------------------------------------------------------------------------"

echo "-------------------------------------------------------------------------"
echo "End   $0"
echo "========================================================================="

exit $EXITCODE
