# Help Documentation

## 1 Why have a help system?

SBSDB offers a wide collection of API calls to the users.
This collection is continuously extended with new or overloaded method calls. 
It is therfore difficult for the user to accurately understand the current SBSDB offerings for the SBSDB version he (or she) is working with.
A help tool is needed which allows to learn, with minimal a priori knowledge, wheather SBSDB can solve a user problem under given circumstances or not.
If it can, the help details should tell the user how to pick the right method and parameters to achieve his goal.
For advanced SBSDB methods, the help system has to explain the processing steps and potential risks involved in executing them. 

## 2 Help pages

To solve the problem, the basic concept of Unix MAN pages is combined with a simple search algorithm.
A call to sbsdb_help({SearchFilter}) provides one of the following Server Outputs:

- an overview list of SBSDB methods or SBSDB packages matching a given API signature search string
- a description page per SBSDB package (which implements related SBSDB methods)
- a detail page per SBSDB method (implemented as a standalone method or in a package)

The wrapper help({SearchFilter}) is provided to provide help for the legacy SBSDB methods which are not ported to PL/SQL yet. 
Legacy help works slightly differently to sbsdb_help as described here. Its usage is explained in sbsdb.help('help').

SBSDB API signatures are composed like {PackageName}.{MethodName} and consequently have one of the following patterns:

| API signature | used for | example |
| --- | --- | --- |
| {PackageName}. | package reference | 'USER-MGMT.' |
| {PackageName}.{MethodName} | packaged method signature | 'USER-MGMT.CONFIG' | 
| .{MethodName} | standalone method | '.SBSDB_HELP' |

Overloaded methods (differing number or types of parameters) use the same API signature. 

The help search works on API signatures, is case insensitive and uses the SQL LIKE operator with ESCAPE '\\'.
A missing or empty or '%' value for {SearchFilter} returns an overview link list to descriptions of all SBSDB methods and packages, including the ones for which the current user does not have execute privileges. 
If {SearchFilter} does not contain the '%' wildcard, it is automatically framed by two '%' characters.
The (possibly modified) search filter must match a piece of above API signatures for the item to appear in the overview list.
If only one item is found, the corresponding detail page is shown directly.

## 3 API specification used for help pages

The specification file of good PL/SQL code already contains an accurate description of the API which is supported by the SBSDB method (procedure or function).
The specification is written by the API-designer who decides about functional change requests and casts this into a text according to the standards defined in the next section.
The text acts like a service level agreement between the implementer and the caller of the method.
This is exactly the information a SBSDB user needs to use the tool efficiently. Note to the SBSDB developer: Implementation details which are not relevant to the API user are commented in the implementation body. 

## 4 API specification content

The specification of a SBSDB API method should be similar to the example below.
It contains, just after the method declaration, the help page details as presented in the help system in the form of a PL/SQL comment.
Specifications should have the following sections:

- without title: A description of user 'problems' which the method solves and how this is achieved. This text is written in plain English. It may use technical terms understandable by the average user.
- Parameters: A section which explains the possible call parameter values. 'optional' should be mentioned for optional parameters with a brief mentioning what happens if the parameter is missing. If NULL provokes a special behaviour, this should be declared too.
- Usage: A section which gives one or more sample call invocations which could make sense.
- Restriction: A section which explains under which situations this method cannot (or should not normally) be used.
- Return: (for function methods only) Explains the output type and possible values or formats.
- Output: (optional) Explains the happy path (success) Server Output and important variants for failure cases.
- Exceptions: (optional) Lists important error codes.
- SeeAlso: (optional) Lists zero or more help commands for related methods where additional information can be found.

Example method specification:
```
    /* =========================================================================
       Creates a database profile.
       ---------------------------------------------------------------------- */

    --<> object_privilege select = sys.dba_profiles
    --<> api_group = user_mgmt
    --<> system_privilege = alter system
    --<> system_privilege = create profile
    PROCEDURE create_profile (
        p_suffix_in                             IN sbsdb_type_lib.input_name_t := NULL,
        p_sessions_in                           IN PLS_INTEGER := 0) /*<>
    Creates a new database profile which is compliant with the SBSDB restrictions imposed
    for applications, their profiles and their users. The profile name is determined by 
    the first input and current application configuration parameters.

    If no suffix is given, the profile is created using the config parameter {USER_PROFILE} or its default.
    If a suffix is given, the profile name is constructed using P_{APP_ID}_{p_suffix_in}
    The profile is created in the DB if it does not yet exist.

    Parameters:
      p_suffix_in   - optional, the suffix of the profile name, defaults to NULL which creates {USER_PROFILE}
      p_sessions_in - optional, the session limit per user, defaults to 0 which means 5 sessions

    Usage: exec sbsdb.user_mgmt.create_profile();            -> server output
           will create a profile {USER_PROFILE} with 5 sessions per user
    
    Usage: exec sbsdb.user_mgmt.create_profile('ABC', 1);    -> server output
           will create a profile P_{APP_ID}_ABC with 1 session only per user

        {APP_ID} defaults to 'APP' if not configured using user_mgmt.set_config()
        {USER_PROFILE} defaults to P_{APP_ID}_RO if not configured using user_mgmt.set_config()

    Restriction:
      - the profile suffix must be a valid SQL identifier.
      - the final profile must not exist in the database.

    SeeAlso:  
            sbsdb.sbsdb_help('%user_mgmt');   -- package for application user management
            sbsdb.sbsdb_help('user_mgmt.config');   -- application configuration
            sbsdb.sbsdb_help('user_mgmt.set_config');   -- application config change
    */;
```

Note to the developer:

The following comments are optional flags for the generation of SBSDB privileges 
during installation. If SBSDB privileges are manually coded, the flags are not needed.
```
    --<> object_privilege select = sys.dba_profiles
    --<> system_privilege = alter system
    --<> system_privilege = create profile
```

The following optional comment could allow a grouping of SBSDB methods according to arbitrary topics.
This is not needed for the system to work since the default value {PackageName} is used for a missing tag.  
```
    --<> api_group = user_mgmt
```

## 5 Automatic help page generation

SBSDB can generate (on a properly installed dev workstation) the help functions from which sbsdb_help_lib produces the help pages.
The generator parses the package specification files to find help texts and method grouping information.
Standalone (non-packaged) methods cannot be parsed. Their method specifications should be copied to a special package spec in the following file: sbsdb_standalone_spec.pks. This package does not have or need a body. Its only purpose is to provide help page information for standalone methods to the code generator.

The code generator produces PL/SQL code files representing three table functions:   

- sbsdb_api_group_trans.fnc   (list of API groups and their methods with package_name and method_name)
- sbsdb_api_scope_help.fnc    (list of help texts per api_scope = {package_name}.{method_name})
- sbsdb_api_scope_trans.fnc   (not used by current SBSDB implementation)

These functions are then queried in the sbsdb_help_lib module and searched for help information matching the {SearchFilter} parameter.
The following queries can be used for inspection purposes:

```
SELECT api_group, package_name, method_name FROM TABLE (sbsdb.sbsdb_api_group_trans());

SELECT * FROM TABLE (sbsdb.sbsdb_api_scope_help());
```

## 6 Manual help page implementation

Maintaining the SBSDB help system is possible without code generation. 
For a new API method, two functions must be extended by changing one code line and adding one table row each:

```    
FUNCTION sbsdb_api_group_trans

    -- change first line in function body
    l_sbsdb_api_group_trans_ntv.EXTEND ({IncrementedMethodCount});  
    ...
    -- insert new last table row in function body, just befor the RETURN clause
    l_sbsdb_api_group_trans_ntv ({IncrementedMethodCount}) := 
        sbsdb_api_group_trans_ot (api_group => '{PackageName}',
                                 package_name => '{PackageName}',
                                 method_name => '{MethodName}'
                                );
```    

```    
FUNCTION sbsdb_api_scope_help

    -- change first line in function body
    l_sbsdb_api_scope_help_ntv.EXTEND ({IncrementedHelpPageCount});
    ...
    -- insert new last table row in function body, just befor the RETURN clause
    l_sbsdb_api_scope_help_ntv ({IncrementedHelpPageCount}) := 
        sbsdb_api_scope_help_ot (api_scope => 'USER_MGMT', 
                                api_help_text => '{HelpTextFromSpec}'
                               );
```

