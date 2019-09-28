@echo off

rem ----------------------------------------------------------------------------
rem
rem run_install_sbsdb_schema_update.bat: SBSDB - update the schemas.
rem
rem ----------------------------------------------------------------------------

setlocal EnableDelayedExpansion

if NOT ["%DOCKER_TOOLBOX_INSTALL_PATH%"] EQU [""] (
    for /F %%A IN ('docker-machine status') do (
        if ["%%A"] EQU ["Stopped"] (
            call docker-machine start
        )
    )
    docker start sbsdb

    for /F %%A IN ('docker-machine ip') do set DOCKER_IP_DEFAULT=%%A
) else (
    docker start sbsdb

    set DOCKER_IP_DEFAULT=0.0.0.0
)

set /P DOCKER_IP="Enter Database IP Address [default: %DOCKER_IP_DEFAULT%] "

if "%1"=="" (
    set /P PASSWORD_SYS="Enter SYS password "
    set /P PASSWORD_SBSDB="Enter SBSDB password "
) else (
    set PASSWORD_SYS=%1
    set PASSWORD_SBSDB=%2
)

if ["%DOCKER_IP%"] EQU [""] (
    set DOCKER_IP=%DOCKER_IP_DEFAULT%
)

set ORACLE_PDB=ORCLPDB1
set CONNECT_IDENTIFIER=//%DOCKER_IP%:1521/%ORACLE_PDB%
set USERNAME_SBSDB=sbs1_admin

echo.
echo Skript %0 is now running
echo.
echo You can find the run log in the file run_install_sbsdb_schema_update.log
echo.
echo Please wait ...
echo.

> run_install_sbsdb_schema_update.log (

    echo =======================================================================
    echo Start %0
    echo -----------------------------------------------------------------------
    echo Installing SBSDB Schema
    echo -----------------------------------------------------------------------
    echo USERNAME_SBSDB     : %USERNAME_SBSDB%
    echo CONNECT_IDENTIFIER : %CONNECT_IDENTIFIER%
    echo -----------------------------------------------------------------------
    echo:| TIME
    echo =======================================================================

    (
        echo @install/generated/sbsdb_schema_update_privileges.sql %USERNAME_SBSDB% %PASSWORD_SBSDB% %CONNECT_IDENTIFIER%
        echo @install/generated/sbsdb_schema_update_software.sql %USERNAME_SBSDB% %PASSWORD_SBSDB% %CONNECT_IDENTIFIER%
        echo @install/sbsdb_view_create.sql
        echo EXECUTE sys.UTL_RECOMP.recomp_serial;
        echo exit
    ) | sqlplus -s sys/%PASSWORD_SYS%@%CONNECT_IDENTIFIER% as sysdba

    echo:| TIME
    echo -----------------------------------------------------------------------
    echo End   %0
    echo =======================================================================
)
