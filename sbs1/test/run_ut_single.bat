@echo off

rem ----------------------------------------------------------------------------
rem
rem run_ut_single.bat: SBSDB - unit testing of a selected test suite.
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

if ["%DOCKER_IP%"] EQU [""] (
    set DOCKER_IP=%DOCKER_IP_DEFAULT%
)

SET ORACLE_PDB=ORCLPDB1
SET CONNECT_IDENTIFIER=//%DOCKER_IP%:1521/%ORACLE_PDB%
SET USERNAME_SBSDB=sbs1_admin
SET PASSWORD_SBSDB=oracle
SET PASSWORD_SYS=oracle

SET PACKAGE=test_in_development

rem SET PACKAGE=test_pkg_admin_common
rem SET PACKAGE=test_pkg_bdetail_common
rem SET PACKAGE=test_pkg_bdetail_info
rem SET PACKAGE=test_pkg_bdetail_mmsc
rem SET PACKAGE=test_pkg_bdetail_msc
rem SET PACKAGE=test_pkg_bdetail_settlement
rem xxx SET PACKAGE=test_pkg_bdetail_smsc
rem SET PACKAGE=test_pkg_code_mgmt
rem SET PACKAGE=test_pkg_common
rem SET PACKAGE=test_pkg_common_mapping
rem SET PACKAGE=test_pkg_common_packing
rem SET PACKAGE=test_pkg_common_stats
rem SET PACKAGE=test_pkg_debug
rem SET PACKAGE=test_pkg_json
rem SET PACKAGE=test_pkg_mec_ic_csv
rem SET PACKAGE=test_pkg_reva
rem SET PACKAGE=test_pkg_revi
rem SET PACKAGE=test_sbsdb_io
rem SET PACKAGE=test_sbsdb_logger
rem SET PACKAGE=test_sbsdb_standalone

SET VERSION=utPLSQL-cli-3.1.7

echo ===========================================================================
echo Start %0
echo ---------------------------------------------------------------------------
echo Unit testing of all test suites.
echo ---------------------------------------------------------------------------
echo USERNAME_SBSDB      : %USERNAME_SBSDB%
echo CONNECT_IDENTIFIER  : %CONNECT_IDENTIFIER%
echo utPLSQL-cli VERSION : %VERSION%
echo PACKAGE             : %PACKAGE%
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
echo          -p=%USERNAME_SBSDB%:%PACKAGE%
echo.

CALL %VERSION%\bin\utplsql.bat run %USERNAME_SBSDB%/%PASSWORD_SBSDB%@%CONNECT_IDENTIFIER% ^
              -c ^
              -f=ut_documentation_reporter ^
              -p=%USERNAME_SBSDB%:%PACKAGE%

echo ===========================================================================
echo:| TIME
echo ---------------------------------------------------------------------------
(
rem echo @install/generated/sbsdb_ut_execute_grant_cover.sql %USERNAME_SBSDB%
    echo exit
) | sqlplus -s %USERNAME_SBSDB%/%PASSWORD_SBSDB%@%CONNECT_IDENTIFIER%

echo.
echo %VERSION%\bin\utplsql.bat run %USERNAME_SBSDB%/...@%CONNECT_IDENTIFIER%
echo          -f=ut_coverage_html_reporter
echo          -o=Cover.html
echo          -p=%USERNAME_SBSDB%:%PACKAGE%
echo          -source_path=..\src
echo              -owner="%USERNAME_SBSDB%"
echo              -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE"
echo          -test_path=src\packages
echo              -owner="%USERNAME_SBSDB%"
echo              -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE"
echo          -include=%USERNAME_SBSDB%:%PACKAGE%
echo.

rem           -f=ut_coverage_html_reporter ^
rem           -f=ut_coveralls_reporter ^

CALL %VERSION%\bin\utplsql.bat run %USERNAME_SBSDB%/%PASSWORD_SBSDB%@%CONNECT_IDENTIFIER% ^
              -f=ut_coverage_html_reporter ^
              -o=Cover.html ^
              -p=%USERNAME_SBSDB%:%PACKAGE% ^
              -source_path=..\src ^
                  -owner="%USERNAME_SBSDB%" ^
                  -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE" ^
              -test_path=src\packages ^
                  -owner="%USERNAME_SBSDB%" ^
                  -type_mapping="fnc=FUNCTION/pkb=PACKAGE BODY/prc=PROCEDURE" ^
              -include=%USERNAME_SBSDB%:%PACKAGE%

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
