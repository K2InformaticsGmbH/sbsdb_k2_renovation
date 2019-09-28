@echo off

rem ----------------------------------------------------------------------------
rem
rem run_install_ut.bat: SBSDB - installation of the unit testing environment.
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
set VERSION=utPLSQL-3.1.7

echo.
echo -----------------------------------------------------------------------
echo Skript %0 is now running
echo.
echo You can find the run log in the file run_install_ut.log
echo.
echo Please wait ...
echo.

> run_install_ut.log (

    echo =======================================================================
    echo Start %0
    echo -----------------------------------------------------------------------
    echo Installing SBSDB Unit Test Environment
    echo -----------------------------------------------------------------------
    echo USERNAME_SBSDB     : %USERNAME_SBSDB%
    echo CONNECT_IDENTIFIER : %CONNECT_IDENTIFIER%
    echo utPLSQL VERSION    : %VERSION%
    echo -----------------------------------------------------------------------
    echo:| TIME
    echo -----------------------------------------------------------------------
    echo Uninstall schema UT3
    echo -----------------------------------------------------------------------

    (
        echo @%VERSION%/source/uninstall.sql ut3
        echo exit
    ) | sqlplus -s SYS/%PASSWORD_SYS%@%CONNECT_IDENTIFIER% AS SYSDBA

    echo -----------------------------------------------------------------------
    echo Drop schema UT3
    echo -----------------------------------------------------------------------

    (
        echo DROP USER ut3 CASCADE
        echo /
        echo exit
    ) | sqlplus -s SYS/%PASSWORD_SYS%@%CONNECT_IDENTIFIER% AS SYSDBA

    echo -----------------------------------------------------------------------
    echo Create and install schema UT3
    echo -----------------------------------------------------------------------

    del uninstall.log
    cd %VERSION%\source

    (
        echo @install_headless.sql
        echo ALTER PLUGGABLE DATABASE %ORACLE_PDB% OPEN READ WRITE;
        echo ALTER PLUGGABLE DATABASE %ORACLE_PDB% SAVE STATE;
        echo exit
    ) | sqlplus -s SYS/%PASSWORD_SYS%@%CONNECT_IDENTIFIER% AS SYSDBA

    echo -----------------------------------------------------------------------
    echo Install unit test envionment for SBSDB
    echo -----------------------------------------------------------------------

    del install.log
    cd ..\..

    (
        echo @install/generated/sbsdb_ut_package_create.sql
        echo EXECUTE sys.UTL_RECOMP.recomp_serial;
        echo exit
    ) | sqlplus -s %USERNAME_SBSDB%/%PASSWORD_SBSDB%@%CONNECT_IDENTIFIER%

    echo -----------------------------------------------------------------------
    echo:| TIME
    echo -----------------------------------------------------------------------
    echo End   %0
    echo =======================================================================
)
