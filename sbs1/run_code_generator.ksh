#!/bin/ksh

{

# ------------------------------------------------------------------------------
#
# run_code_generator.ksh: SBSDB - code generator.
#
# ------------------------------------------------------------------------------

echo "========================================================================="
echo "Start $0"
echo "-------------------------------------------------------------------------"
echo "Generating SBSDB wrapper files and installation scripts"
echo "-------------------------------------------------------------------------"
date +"DATE TIME          : %d.%m.%Y %H:%M:%S"
echo "========================================================================="

rm -rf install/generated

rm -f src/deploy/*.*
rm -f src/functions/generated/*.fnc
rm -f src/packages/generated/*.pkb
rm -f src/packages/generated/*.pks
rm -f src/procedures/generated/*.prc

rm -rf test/install/generated

rm -f  test/src/deploy/*.*

./rebar3 compile

# Starting code generator ......................................................
erl -noshell -pa _build/default/lib/sbsdb/ebin _build/default/lib/plsql_parser/ebin _checkouts/plsql_parser/ebin $HEAP_SIZE -s code_generator generate -s init stop

echo "End   $0"
echo "========================================================================="

} 2>&1 | tee run_code_generator.log

exit 0
