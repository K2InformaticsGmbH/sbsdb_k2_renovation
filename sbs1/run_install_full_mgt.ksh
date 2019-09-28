#!/bin/ksh

{

# ------------------------------------------------------------------------------
#
# run_install_full_mgt.ksh: SBSDB - full installation of the database software.
#
# ------------------------------------------------------------------------------

PATH=$PATH:/u01/app/oracle/product/12.2/db_1/jdbc/lib

USERNAME_SBSDB=sbs1_admin
PASSWORD_SBSDB=t7GkAFQk7CFuEpdJ
CONNECT_IDENTIFIER=SBSMGT1_RW

echo "========================================================================="
echo "Start $0"
echo "-------------------------------------------------------------------------"
echo "Installing SBSDB Schema - Swisscom Management Database."
echo "-------------------------------------------------------------------------"
echo "USERNAME_SBSDB     : $USERNAME_SBSDB"
echo "CONNECT_IDENTIFIER : $CONNECT_IDENTIFIER"
date +"DATE TIME          : %d.%m.%Y %H:%M:%S"
echo "========================================================================="

(
    echo @install/generated/sbsdb_schema_update_software.sql $USERNAME_SBSDB $PASSWORD_SBSDB $CONNECT_IDENTIFIER
    echo @install/sbsdb_view_create.sql
    echo exit
) | sqlplus -s $USERNAME_SBSDB/PASSWORD_SBSDB@$CONNECT_IDENTIFIER as sysdba

echo "End   $0"
echo "========================================================================="

} 2>&1 | tee run_install_full_mgt.log

exit 0
