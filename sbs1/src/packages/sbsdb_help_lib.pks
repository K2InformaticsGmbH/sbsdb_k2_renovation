CREATE OR REPLACE PACKAGE sbsdb_help_lib
IS
    /*<>
   Implementation package for providing help in the form of searchable MAN pages

    MODIFICATION HISTORY
    Code  Date        Comments
    001WW 07.03.2019  Creation
    */

    /* =========================================================================
       Public Procedure Declaration
       ---------------------------------------------------------------------- */

    --<> api_hidden = true
    FUNCTION help_text (
        p_api_group_in                          IN sbsdb_type_lib.api_scope_t,
        p_api_method_in                         IN sbsdb_type_lib.api_scope_t)
        RETURN sbsdb_type_lib.api_message_t;

    --<> api_hidden = true
    FUNCTION method_link (
        p_api_package_in                        IN sbsdb_type_lib.api_scope_t,
        p_api_method_in                         IN sbsdb_type_lib.api_scope_t)
        RETURN sbsdb_type_lib.api_message_t;

    --<> api_group = help
    PROCEDURE HELP (sqlt_str_filter IN sbsdb_type_lib.input_name_t:= NULL) /*<>
     Allows a search in the SBSDB help pages based on api_group (package name) or api_method (function or procedure name).
     The search is done with a LIKE match (ESCAPE '\').
     If the wildcard '%' is absent in the search filter, the search filter is prefixed and suffixed by '%'.

     The resulting output depends on how many matches are found:

     - only 1 match:         Returns a single help page for a SBSDB api_method or a SBSDB api_group
     - more than 1 match:    Returns a list of all matching help commands for drill down to the detail pages

     Examples:

     - sbsdb_help()
         Shows a list of all possible help commands.
         The list includes commands for which the user has no execute permission.

     - sbsdb_help('user')
         Shows a list of all help commands where the api_group or the api_method contains 'user'.

     - sbsdb_help('user_mgmt')
         Shows a list of help commands for the package user_mgmt.
         This includes a link to the summary for the package itself plus one link per method in this package.

     - sbsdb_help('user_mgmt.set')
         Shows all set... api_methods for the package user_mgmt.
         Because we only have one such method, this will result in a direct help page ouptput
         for the user_mgmt.set_config api_method.

     - sbsdb_help('\_mgmt.')
         Shows all api_methods for all packages which are named ..._mgmt but not the package summary

     - sbsdb_help('%mgmt')
         Shows links to all package descriptions for packages named ...mgmt but not for their methods
      */
                                                                          ;
END sbsdb_help_lib;
/
