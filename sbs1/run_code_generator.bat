@echo off

rem ----------------------------------------------------------------------------
rem
rem run_code_generator.bat: SBSDB - code generator.
rem
rem ----------------------------------------------------------------------------

echo.
echo Skript %0 is now running
echo.
echo You can find the run log in the file run_code_generator.log
echo.
echo Please wait ...
echo.

> run_code_generator.log (

    echo =======================================================================
    echo Start %0
    echo -----------------------------------------------------------------------
    echo Generating SBSDB wrapper files and installation scripts
    echo -----------------------------------------------------------------------
    echo HOME_TOAD : %HOME_TOAD%
    echo -----------------------------------------------------------------------
    echo:| TIME
    echo -----------------------------------------------------------------------

    SETLOCAL enableDelayedExpansion
    echo !time! Start Code Generator

    IF EXIST install\generated (
        RD /Q /S install\generated
    )
    IF EXIST src\deploy\*.* (
        DEL /Q src\deploy\*.*
    )
    IF EXIST src\functions\generated\*.fnc (
        DEL /Q src\functions\generated\*.fnc
    )
    IF EXIST src\packages\generated\*.pkb (
        DEL /Q src\packages\generated\*.pkb
    )
    IF EXIST src\packages\generated\*.pks (
        DEL /Q src\packages\generated\*.pks
    )
    IF EXIST src\procedures\generated\*.prc (
        DEL /Q src\procedures\generated\*.prc
    )
    IF EXIST test\install\generated (
        RD /Q /S test\install\generated
    )
    IF EXIST test\src\deploy\*.* (
        DEL /Q test\src\deploy\*.*
    )

    CALL rebar3 compile

    rem Starting code generator ................................................
    erl -noshell -pa _build\default\lib\sbsdb\ebin _build\default\lib\plsql_parser\ebin _checkouts\plsql_parser\ebin %HEAP_SIZE% -s code_generator generate -s init stop

    IF EXIST "%HOME_TOAD%" (
        "%HOME_TOAD%\toad.exe" -a "SBSDB Format Generated Files"
    )

    echo !time! End  Code Generator

    echo -----------------------------------------------------------------------
    echo:| TIME
    echo -----------------------------------------------------------------------
    echo End   %0
    echo =======================================================================
)
