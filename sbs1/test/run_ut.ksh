#!/bin/ksh

{

# ------------------------------------------------------------------------------
#
# run_ut.ksh: SBSDB - unit testing of all test suites.
#
# ------------------------------------------------------------------------------

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
echo "Unit testing of all test suites"
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

echo "========================================================================="
date +"DATE TIME           : %d.%m.%Y %H:%M:%S"
echo "-------------------------------------------------------------------------"

(
    echo @install/generated/sbsdb_ut_execute_grant_cover.sql $USERNAME_SBSDB
    echo exit
) | sqlplus -s $USERNAME_SBSDB/$PASSWORD_SBSDB@$CONNECT_IDENTIFIER

echo ""
echo "$VERSION/bin/utplsql run $USERNAME_SBSDB/...@$CONNECT_IDENTIFIER"
echo "        -f=ut_coverage_html_reporter"
echo "        -o=Cover.html"
echo "        -p=$USERNAME_SBSDB:test_pkg_admin_common,..."
echo "        -source_path=../src"
echo "            -owner=$USERNAME_SBSDB"
echo "            -type_mapping=/"fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE/"
echo "        -test_path=src/packages"
echo "            -owner=$USERNAME_SBSDB"
echo "            -type_mapping=/"fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE/"
echo "        -exclude=$USERNAME_SBSDB.sbsdb_api_group_trans,..."
echo ""
$VERSION/bin/utplsql run $USERNAME_SBSDB/$PASSWORD_SBSDB@$CONNECT_IDENTIFIER \
        -f=ut_coverage_html_reporter \
        -o=Cover.html \
        -p=\
$USERNAME_SBSDB:test_pkg_admin_common,\
$USERNAME_SBSDB:test_pkg_bdetail_common,\
$USERNAME_SBSDB:test_pkg_bdetail_info,\
$USERNAME_SBSDB:test_pkg_bdetail_mmsc,\
$USERNAME_SBSDB:test_pkg_bdetail_msc,\
$USERNAME_SBSDB:test_pkg_bdetail_settlement,\
$USERNAME_SBSDB:test_pkg_bdetail_smsc,\
$USERNAME_SBSDB:test_pkg_code_mgmt,\
$USERNAME_SBSDB:test_pkg_common,\
$USERNAME_SBSDB:test_pkg_common_mapping,\
$USERNAME_SBSDB:test_pkg_common_packing,\
$USERNAME_SBSDB:test_pkg_common_stats,\
$USERNAME_SBSDB:test_pkg_debug,\
$USERNAME_SBSDB:test_pkg_json,\
$USERNAME_SBSDB:test_pkg_mec_ic_csv,\
$USERNAME_SBSDB:test_pkg_reva,\
$USERNAME_SBSDB:test_pkg_revi,\
$USERNAME_SBSDB:test_sbsdb_io,\
$USERNAME_SBSDB:test_sbsdb_logger,\
$USERNAME_SBSDB:test_sbsdb_standalone \
        -source_path=../src \
           -owner="$USERNAME_SBSDB" \
           -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE" \
        -test_path=src/packages \
            -owner="$USERNAME_SBSDB" \
            -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE" \
        -exclude=\
$USERNAME_SBSDB.sbsdb_api_group_trans,\
$USERNAME_SBSDB.sbsdb_api_scope_help,\
$USERNAME_SBSDB.sbsdb_api_scope_trans,\
$USERNAME_SBSDB.sbsdb_help,\
$USERNAME_SBSDB.sbsdb_help_lib

(
#   echo @install/generated/sbsdb_ut_execute_revoke_cover.sql $USERNAME_SBSDB
#   echo @install/generated/sbsdb_ut_execute_revoke_test.sql $USERNAME_SBSDB
    echo exit
) | sqlplus -s $USERNAME_SBSDB/$PASSWORD_SBSDB@$CONNECT_IDENTIFIER

echo "-------------------------------------------------------------------------"
echo "End   $0"
echo "========================================================================="

} 2>&1 | tee run_ut.log

exit 0
