@echo off

rem ----------------------------------------------------------------------------
rem
rem run_ut.bat: SBSDB - unit testing of all test suites.
rem
rem ----------------------------------------------------------------------------

setlocal EnableDelayedExpansion

if not ["%DOCKER_TOOLBOX_INSTALL_PATH%"] EQU [""] (
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
set VERSION=utPLSQL-cli-3.1.7

echo ===========================================================================
echo Start %0
echo ---------------------------------------------------------------------------
echo Unit testing of all test suites.
echo ---------------------------------------------------------------------------
echo USERNAME_SBSDB      : %USERNAME_SBSDB%
echo CONNECT_IDENTIFIER  : %CONNECT_IDENTIFIER%
echo utPLSQL-cli VERSION : %VERSION%
echo ---------------------------------------------------------------------------
echo:| TIME
echo ---------------------------------------------------------------------------

(
    echo @install/sbsdb_ut_schema_ut_create_or_update.sql %USERNAME_SBSDB% %USERNAME_SBSDB% %PASSWORD_SBSDB%
    echo exit
) | sqlplus -s sys/%PASSWORD_SYS%@%CONNECT_IDENTIFIER% as sysdba

(
    echo @install/generated/sbsdb_ut_execute_grant_test.sql %USERNAME_SBSDB%
    echo exit
) | sqlplus -s %USERNAME_SBSDB%/%PASSWORD_SBSDB%@%CONNECT_IDENTIFIER%

echo.
echo %VERSION%\bin\utplsql.bat run %USERNAME_SBSDB%/...@%CONNECT_IDENTIFIER%
echo          -c
echo          -f=ut_documentation_reporter
echo          -p=%USERNAME_SBSDB%
echo.

CALL %VERSION%\bin\utplsql.bat run %USERNAME_SBSDB%/%PASSWORD_SBSDB%@%CONNECT_IDENTIFIER% ^
              -c ^
              -f=ut_documentation_reporter ^
              -p=%USERNAME_SBSDB%

echo ===========================================================================
echo:| TIME
echo ---------------------------------------------------------------------------

(
    echo @install/generated/sbsdb_ut_execute_grant_cover.sql %USERNAME_SBSDB%
    echo exit
) | sqlplus -s %USERNAME_SBSDB%/%PASSWORD_SBSDB%@%CONNECT_IDENTIFIER%

echo.
echo %VERSION%\bin\utplsql.bat run %USERNAME_SBSDB%/...@%CONNECT_IDENTIFIER%
echo          -f=ut_coverage_html_reporter
echo          -o=Cover.html
echo          -p=%USERNAME_SBSDB%:test_pkg_admin_common,...
echo          -source_path=..\src
echo              -owner="%USERNAME_SBSDB%"
echo              -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE"
echo          -test_path=src\packages
echo              -owner="%USERNAME_SBSDB%"
echo              -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE"
echo          -exclude=%USERNAME_SBSDB%.sbsdb_api_group_trans,...
echo.

CALL %VERSION%\bin\utplsql.bat run %USERNAME_SBSDB%/%PASSWORD_SBSDB%@%CONNECT_IDENTIFIER% ^
              -f=ut_coverage_html_reporter ^
              -o=Cover.html ^
              -p=^
%USERNAME_SBSDB%:test_pkg_admin_common,^
%USERNAME_SBSDB%:test_pkg_bdetail_common,^
%USERNAME_SBSDB%:test_pkg_bdetail_info,^
%USERNAME_SBSDB%:test_pkg_bdetail_mmsc,^
%USERNAME_SBSDB%:test_pkg_bdetail_msc,^
%USERNAME_SBSDB%:test_pkg_bdetail_settlement,^
%USERNAME_SBSDB%:test_pkg_bdetail_smsc,^
%USERNAME_SBSDB%:test_pkg_code_mgmt,^
%USERNAME_SBSDB%:test_pkg_common,^
%USERNAME_SBSDB%:test_pkg_common_mapping,^
%USERNAME_SBSDB%:test_pkg_common_packing,^
%USERNAME_SBSDB%:test_pkg_common_stats,^
%USERNAME_SBSDB%:test_pkg_debug,^
%USERNAME_SBSDB%:test_pkg_json,^
%USERNAME_SBSDB%:test_pkg_mec_ic_csv,^
%USERNAME_SBSDB%:test_pkg_reva,^
%USERNAME_SBSDB%:test_pkg_revi,^
%USERNAME_SBSDB%:test_sbsdb_io,^
%USERNAME_SBSDB%:test_sbsdb_logger,^
%USERNAME_SBSDB%:test_sbsdb_standalone ^
              -source_path=..\src ^
                  -owner="%USERNAME_SBSDB%" ^
                  -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE" ^
              -test_path=src\packages ^
                  -owner="%USERNAME_SBSDB%" ^
                  -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE" ^
              -exclude=^
%USERNAME_SBSDB%.sbsdb_api_group_trans,^
%USERNAME_SBSDB%.sbsdb_api_scope_help,^
%USERNAME_SBSDB%.sbsdb_api_scope_trans,^
%USERNAME_SBSDB%.sbsdb_help,^
%USERNAME_SBSDB%.sbsdb_help_lib

(
rem echo @install/generated/sbsdb_ut_execute_revoke_cover.sql %USERNAME_SBSDB%
rem echo @install/generated/sbsdb_ut_execute_revoke_test.sql %USERNAME_SBSDB%
    echo exit
) | sqlplus -s %USERNAME_SBSDB%/%PASSWORD_SBSDB%@%CONNECT_IDENTIFIER%

echo ---------------------------------------------------------------------------
echo:| TIME
echo ---------------------------------------------------------------------------
echo End   %0
echo ===========================================================================
