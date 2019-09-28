#!/bin/ksh

{

# ------------------------------------------------------------------------------
#
# run_install_full_docker.ksh: SBSDB - full installation of the database software.
#
# ------------------------------------------------------------------------------

docker start sbsdb

DOCKER_IP_DEFAULT=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" sbsdb)

printf "Enter Database IP Address [default: $DOCKER_IP_DEFAULT]: \n"; read DOCKER_IP; stty echo; printf "\n"

if [ -z $DOCKER_IP ]; then
    DOCKER_IP=$DOCKER_IP_DEFAULT
fi

PATH=$PATH:/u01/app/oracle/product/12.2/db_1/jdbc/lib

PASSWORD_SYS=$1
PASSWORD_SBSDB=$2

if [ "$#" -ne 2 ]; then
    stty -echo
    printf "Enter SYS password: \n"; read PASSWORD_SYS; stty echo; printf "\n"
    stty -echo
    printf "Enter SBSDB password: \n"; read PASSWORD_SBSDB; stty echo; printf "\n"
fi

ORACLE_PDB=ORCLPDB1
CONNECT_IDENTIFIER=//$DOCKER_IP:1521/$ORACLE_PDB
USERNAME_SBSDB=sbs1_admin

echo "========================================================================="
echo "Start $0"
echo "-------------------------------------------------------------------------"
echo "Installing SBSDB Schema"
echo "-------------------------------------------------------------------------"
echo "USERNAME_SBSDB     : $USERNAME_SBSDB"
echo "CONNECT_IDENTIFIER : $CONNECT_IDENTIFIER"
echo "-------------------------------------------------------------------------"
date +"DATE TIME          : %d.%m.%Y %H:%M:%S"
echo "========================================================================="

(
    echo @install/sbsdb_schema_create.sql $USERNAME_SBSDB $PASSWORD_SBSDB
    echo @install/generated/sbsdb_schema_update_privileges.sql $USERNAME_SBSDB $PASSWORD_SBSDB $CONNECT_IDENTIFIER
    echo @install/generated/sbsdb_schema_update_software.sql $USERNAME_SBSDB $PASSWORD_SBSDB $CONNECT_IDENTIFIER
    echo @install/sbsdb_view_create.sql
    echo EXECUTE sys.UTL_RECOMP.recomp_serial;
    echo exit
) | sqlplus -s sys/$PASSWORD_SYS@$CONNECT_IDENTIFIER as sysdba

echo "End   $0"
echo "========================================================================="

} 2>&1 | tee run_install_full_docker.log

exit 0
