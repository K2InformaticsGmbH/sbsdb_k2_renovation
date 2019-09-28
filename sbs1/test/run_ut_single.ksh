#!/bin/ksh

{

# ------------------------------------------------------------------------------
#
# run_ut_single.ksh: SBSDB - unit testing of selected test suites.
#
# ------------------------------------------------------------------------------

docker start sbsdb

DOCKER_IP_DEFAULT=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" sbsdb)

printf "Enter Database IP Address [default: $DOCKER_IP_DEFAULT]: \n"; read DOCKER_IP; stty echo; printf "\n"

if [ -z $DOCKER_IP ]; then
    DOCKER_IP=$DOCKER_IP_DEFAULT
fi

ORACLE_PDB=ORCLPDB1
CONNECT_IDENTIFIER=//$DOCKER_MACHINE_IP:1521/$ORACLE_PDB
USERNAME_SBSDB=sbs1_admin
PASSWORD_SBSDB=oracle
PASSWORD_SYS=oracle

PACKAGE=test_in_development

# PACKAGE=test_pkg_admin_common
# PACKAGE=test_pkg_bdetail_common
# PACKAGE=test_pkg_bdetail_info
# PACKAGE=test_pkg_bdetail_mmsc
# PACKAGE=test_pkg_bdetail_msc
# PACKAGE=test_pkg_bdetail_settlement
# PACKAGE=test_pkg_bdetail_smsc
# PACKAGE=test_pkg_code_mgmt
# PACKAGE=test_pkg_common
# PACKAGE=test_pkg_common_mapping
# PACKAGE=test_pkg_common_packing
# PACKAGE=test_pkg_common_stats
# PACKAGE=test_pkg_debug
# PACKAGE=test_pkg_json
# PACKAGE=test_pkg_mec_ic_csv
# PACKAGE=test_pkg_reva
# PACKAGE=test_pkg_revi
# PACKAGE=test_sbsdb_io
# PACKAGE=test_sbsdb_logger
# PACKAGE=test_sbsdb_standalone

VERSION=utPLSQL-cli-3.1.7

echo "========================================================================="
echo "Start $0"
echo "-------------------------------------------------------------------------"
echo "Unit testing of all test suites"
echo "-------------------------------------------------------------------------"
echo "USERNAME_SBSDB      : $USERNAME_SBSDB"
echo "CONNECT_IDENTIFIER  : $CONNECT_IDENTIFIER"
echo "utPLSQL-cli VERSION : $VERSION"
echo "PACKAGE             : $PACKAGE"
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
echo "        -p=$USERNAME_SBSDB:$PACKAGE"
echo ""
$VERSION/bin/utplsql run $USERNAME_SBSDB/$PASSWORD_SBSDB@$CONNECT_IDENTIFIER \
        -c \
        -f=ut_documentation_reporter \
        -p=$USERNAME_SBSDB:$PACKAGE

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
echo "        -p=$USERNAME_SBSDB:$PACKAGE"
echo "        -source_path=../src"
echo "            -owner=$USERNAME_SBSDB"
echo "            -type_mapping=/"fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE/"
echo "        -test_path=src/packages"
echo "            -owner=$USERNAME_SBSDB"
echo "            -type_mapping=/"fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE/"
echo "        -include=$USERNAME_SBSDB:$PACKAGE"
echo ""
# $VERSION/bin/utplsql run $USERNAME_SBSDB/$PASSWORD_SBSDB@$CONNECT_IDENTIFIER \
#         -f=ut_coverage_html_reporter \
#         -o=Cover.html \
#         -p=$USERNAME_SBSDB:$PACKAGE \
#         -source_path=../src \
#            -owner="$USERNAME_SBSDB" \
#            -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE" \
#         -test_path=src/packages \
#             -owner="$USERNAME_SBSDB" \
#             -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE" \
#         -include=$USERNAME_SBSDB:$PACKAGE

(
#   echo @install/generated/sbsdb_ut_execute_revoke_cover.sql $USERNAME_SBSDB
#   echo @install/generated/sbsdb_ut_execute_revoke_test.sql $USERNAME_SBSDB
    echo exit
) | sqlplus -s $USERNAME_SBSDB/$PASSWORD_SBSDB@$CONNECT_IDENTIFIER

echo "-------------------------------------------------------------------------"
echo "End   $0"
echo "========================================================================="

} 2>&1 | tee run_ut_single.log

exit 0
