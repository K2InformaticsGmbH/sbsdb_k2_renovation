#!/bin/ksh

{

# ------------------------------------------------------------------------------
#
# run_install_ut.ksh: SBSDB - installation of the unit testing environment.
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
set VERSION=utPLSQL-3.1.7

echo "========================================================================="
echo "Start $0"
echo "-------------------------------------------------------------------------"
echo "Installing SBSDB Unit Test Environment"
echo "-------------------------------------------------------------------------"
echo "USERNAME_SBSDB     : $USERNAME_SBSDB"
echo "CONNECT_IDENTIFIER : $CONNECT_IDENTIFIER"
echo "utPLSQL VERSION    : $VERSION"
date +"DATE TIME          : %d.%m.%Y %H:%M:%S"
echo "-------------------------------------------------------------------------"
echo "Uninstall schema UT3"
echo "-------------------------------------------------------------------------"

(
    echo @$VERSION/source/uninstall.sql ut3
    echo exit
) | sqlplus -s sys/$PASSWORD_SYS@$CONNECT_IDENTIFIER as sysdba

echo "-------------------------------------------------------------------------"
echo "Drop schema UT3"
echo "-------------------------------------------------------------------------"

(
    echo DROP USER ut3 CASCADE
    echo /
    echo exit
) | sqlplus -s sys/$PASSWORD_SYS@$CONNECT_IDENTIFIER as sysdba

echo "-------------------------------------------------------------------------"
echo "Create and install schema UT3"
echo "-------------------------------------------------------------------------"

rm uninstall.log
cd $VERSION/source

(
    echo @install_headless.sql
    echo exit
) | sqlplus -s sys/$PASSWORD_SYS@$CONNECT_IDENTIFIER as sysdba

echo "-------------------------------------------------------------------------"
echo "Install unit test envionment for SBSDB"
echo "-------------------------------------------------------------------------"

pwd
rm install.log
cd ../..
pwd

(
    echo @install/generated/sbsdb_ut_package_create.sql
    echo EXECUTE sys.UTL_RECOMP.recomp_serial;
    echo exit
) | sqlplus -s $USERNAME_SBSDB/$PASSWORD_SBSDB@$CONNECT_IDENTIFIER

echo "-------------------------------------------------------------------------"
echo "End   $0"
echo "========================================================================="

} 2>&1 | tee run_install_ut.log

exit 0
