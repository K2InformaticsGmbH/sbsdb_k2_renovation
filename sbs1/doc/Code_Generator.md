[Development Guidelines](../Development_Guidelines.md)

## [Code Generator](../Development_Guidelines.md#development_guidelines_code_generator)

### 1 Introduction

The code generator creates program code and script files based on the package specifications in the directory `...\src\packages`. 
The annotations contained in the package specifications play an important role in code generation.
The output of the code generator is placed in file subdirectories with the name `generated`.
Before the code generator is started, the files contained in these directories or the whole directories are deleted,

---- 

### 2 Running the Code Generator

The code generator is executed with the `run_code_generator.bat` script. 

The script performs the following processing steps:

1. delete the `...\install\generated` directory if it exists,
1. delete in directory `...\src\functions\generated` all files with file extension `fnc`,
1. delete in directory `...\src\packages\generated` all files with file extensions `pkb` and `pks`,
1. delete in directory `...\src\procedures\generated` all files with file extension `prc`,
1. delete the `...\test\install\generated` directory if it exists,
1. compile the code generator program,
1. run the code generator program,
1. run `SBSDB Format Generated Files` with the `Automation Designer` if Toad is installed.

The log file `run_code_generator.log` can be used to check whether the code generator ran without errors.

**Note:** Initialization of Toad's Automation Designer:

1. Create the environment variable `%HOME_TOAD%` that must point to the directory containing the `TOAD.EXE` file.
1. In Toad's Automation Designer (Menu: `Utilities -> Automation Designer`), import the `SBSDB Format Generated Files.txt` file from the `...\priv\Settings\Toad for Oracle` directory.
1. Adapt the pathnames in the automation scripts to your environment.

----

### 3 Code Generator Output for Production

The publicly available functionality of SBSDB is packaged in implementation packages. 
An implementation package has the suffix `_impl`. 
The functionality available to the SBSDB user can be found in the package specification as functions and procedures that are not marked as `hidden`.
However, the SBSDB user has no direct access to the implementation packages.
For the access the code generator generates invoker packages and accessor functions.
In addition, the code generator generates a few table functions and an installation script file to create a new SBSDB schema or update an existing SBSDB schema.

### 3.1 Generation of Invoker Packages 

An invoker package is generated for each implementation package.
The invoker package has the same name as the implementation package but without the suffix `_impl`.
For each function and procedure in the implementation package that are not annotated with `api_hidden`, a corresponding function or procedure is generated in the invoker package.
The generated invoker packages can be found in the directory `...\src\packages\generated`.

#### Simple functions and procedures

The simple methods work as follows:

1. a start entry is created for the log file,
1. the system checks whether the user has execution privilege for the accessor function belonging to this method,
1. the implementation method belonging to this method is called, and finally
1. an end entry for the log file is created.

Example of an implementation (and invoker) package specification:

```SQL
    PROCEDURE lock_user (p_username_in IN sbsdb_type_lib.input_name_t:= NULL);
```

Example of an invoker package body:

```SQL
    PROCEDURE lock_user (p_username_in IN sbsdb_type_lib.input_name_t:= NULL)
    IS
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'lock_user'),
            sbsdb_logger_lib.log_param ('p_username_in', p_username_in));
        sbsdb_api_impl.raise_access_denied ('SBSDB_AC_D5E27832E149E9CBE2F06E');
        user_mgmt_impl.lock_user (p_username_in);
        sbsdb_logger_lib.log_info ('End', sbsdb_logger_lib.scope ($$plsql_unit, 'lock_user'));
    EXCEPTION
        WHEN OTHERS
        THEN
            IF SQLCODE = sbsdb_error_lib.en_access_denied
            THEN
                sbsdb_error_lib.LOG (
                    SQLCODE,
                    SQLERRM,
                    sbsdb_logger_lib.scope ($$plsql_unit, 'lock_user'),
                    sbsdb_logger_lib.log_param ('p_username_in', p_username_in));
            END IF;

            RAISE;
    END lock_user;
```

#### Pipelined functions

The pipelined functions work as follows:

1. a start entry is created for the log file,
1. the system checks whether the user has execution privilege for the accessor function belonging to this function, and finally
1. the data from the pipelined implementation function is transferred to the caller.

Example of an implementation (and invoker) package specification:

```SQL
    FUNCTION HELP (sqlt_str_filter IN sbsdb_type_lib.input_name_t:= NULL)
        RETURN sbsdb_api_scope_help_nt
        PIPELINED;
```

Example of an invoker package body:

```SQL
    FUNCTION HELP (sqlt_str_filter IN sbsdb_type_lib.input_name_t:= NULL)
        RETURN sbsdb_api_scope_help_nt
        PIPELINED
    IS
        l_coll                         sbsdb_type_lib.sbsdb_api_scope_help_ct;
    BEGIN
        sbsdb_logger_lib.log_info (
            'Start',
            sbsdb_logger_lib.scope ($$plsql_unit, 'HELP'),
            sbsdb_logger_lib.log_param ('sqlt_str_filter', sqlt_str_filter));
        sbsdb_api_impl.raise_access_denied ('SBSDB_AC_9C4A476206FCDB893A57B2');

        SELECT *
          BULK COLLECT INTO l_coll
          FROM TABLE (sbsdb_help_impl.HELP (sqlt_str_filter));

       <<process_rows>>
        FOR indx IN 1 .. l_coll.COUNT
        LOOP
            PIPE ROW (sbsdb_help_impl.pipe_row (l_coll (indx)));
        END LOOP process_rows;

        RETURN;
    EXCEPTION
        WHEN no_data_needed
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            IF SQLCODE = sbsdb_error_lib.en_access_denied
            THEN
                sbsdb_error_lib.LOG (
                    SQLCODE,
                    SQLERRM,
                    sbsdb_logger_lib.scope ($$plsql_unit, 'HELP'),
                    sbsdb_logger_lib.log_param ('sqlt_str_filter', sqlt_str_filter));
            END IF;

            RAISE;
    END HELP;
```

### 3.2 Generation of Accessor Functions 

The accessor functions enable access control to the functions and procedures in the implementation packages.
The program code of the accessor function is not executed, but an object privilege `execute` is required for the accessor function to execute the corresponding methods in the implementation package.
The object privilege can be granted for individual methods or via annotations of type `api_group` for an entire set of implementation methods.
The generated accessor functions can be found in the directory `...\src\functions\generated`.

Example of an accessor function:

```SQL
    -- GENERATED CODE (based on function HELP in package specification sbsdb_help_impl)
    
    CREATE OR REPLACE FUNCTION sbsdb_ac_9c4a476206fcdb893a57b2
        RETURN VARCHAR2
    IS
    /*
       Implementation Method: sbsdb_help.HELP
    
       This is a accessor function placeholder. It can be ignored by all users of the database.
       SBSDB internal workflows may grant 'execute' to this object to a SBSDB user with the
       effect that the user gets access to the method <SBSDB Schema.>sbsdb.HELP.
    */
    BEGIN
        RETURN sbsdb_api_impl.scope ('sbsdb_help', 'HELP');
    END sbsdb_ac_9c4a476206fcdb893a57b2;
    /
```

### 3.3 Generation of Table Functions 

#### SBSDB_API_GROUP_TRANS

The data in this table function results from the annotation `api_group` in the implementation methods that are not provided with the annotation `api_hidden`.
Implementation methods with the annotation `api_hidden` are displayed here with the content `hidden` in the column `api_group`.
Other implementation methods that do not contain an annotation `api_group` are displayed here with the content `not_assigned` in the column `api_group`.

![](https://i.imgur.com/0KnJO6V.jpg)

#### SBSDB_API_SCOPE_HELP

The data in this table function results from the man pages in the implementation methods that are not provided with the annotation `api_hidden`.
The column `api_help_text` contains the cointent of the annotaion man page (`/*<>`) of the corresponding implementation method.

![](https://i.imgur.com/4oVcwvp.jpg)

#### SBSDB_API_SCOPE_TRANS

The data in this table function results from the implementation methods that are not provided with the annotation `api_hidden`.

![](https://i.imgur.com/ufOICmb.jpg)

### 3.4 Generation of the Installation Skript 

The generated installation script can either create a new SBSDB schema or update an existing SBSDB schema. 
The generated script is used in the `run_install_base` script in both Unix and Windows versions.  
The generated script can be found in the directory `...\install\generated`.

The generated script includes the following processing steps:

1. If the SBSDB schema already exists, then 
- drop all functions depending on types in the database for which corresponding files in the directory `...\src\functions` exist - except the accessor functions,
- drop all procedures depending on types in the database for which corresponding files in the directory `...\src\procedures` exist,
- drop all packages depending on types in the database for the corresponding files in the directory `...\src\packages` exist,
- drop all collection types belonging to the SBSDB schema, and
- drop all object types belonging to the SBSDB schema.
1. If the SBSDB schema does not yet exist, then it will be created.
1. The SBSDB schema is granted privileges based on the `object_privilege` and `system_privilege` annotations.
1. The logger sequence SBSDB_LOG_SEQ will be created.
1. If the io type log is table then the logger table SBSDB_LOG will be created.
1. If the io type property is table then the logger table SBSDB_PROPERTY will be created.
1. The type definitions (`...\src\types\sbsdb.tps`) and the package specifications of `sbsdb_type_lib` and `sbsdb_api` are compiled.
1. The generated functions in the directory `...\src\functions\generated` are compiled.
1. The package specifications in the directory `...\src\packages` are compiled.
1. The generated package specifications in the directory `...\src\packages\generated` are compiled.
1. The logger type in the package `sbsdb_logger_lib.pkb` is adapted.
1. The package bodies in the directory `...\src\packages` are compiled.
1. The generated package bodies in the directory `...\src\packages\generated` are compiled.
1. The functions available in the directory `...\src\functions` are compiled.
1. The procedures available in the directory `...\src\procedures` are compiled.
1. The SBSDB context is created.
1. If the logger type is table then the logger table SBSDB_LOG gets an initialization entry.
 
----

### 4 Code Generator Output for Unit Testing

The code generator supports unit testing by creating the following scripts based on selected existing files in the `...\src\packages` and `...\test\src\packages` directories.
These scripts are used in the scripts for the installation (`run_install_ut.bat`) and execution (`run_ut.bat`) of the unit tests.
The generated scripts can be found in the directory `...\test\install\generated`.

1. `sbsdb_ut_execute_grant_cover.sql` - grant the execute privilege for all packages with an existing package body located in the directory `...\src\packages`.
1. `sbsdb_ut_execute_grant_test.sql` - grant the execute privilege for all packages with an existing package body located in the directory `...\test\src\packages` whose names begin with the string `test_`.
1. `sbsdb_ut_execute_grant_test_swisscom.sql` - same functionality as the previous script, but adapted for the Swisscom environment.
1. `sbsdb_ut_execute_revoke_cover.sql` - revoke the execute privilege for all packages with an existing package body located in the directory `...\src\packages`. 
1. `sbsdb_ut_execute_revoke_test.sql` - revoke the execute privilege for all packages with an existing package body located in the directory `...\test\src\packages` whose names begin with the string `test_`. 
1. `sbsdb_ut_execute_revoke_test_swisscom.sql` - same functionality as the previous script, but adapted for the Swisscom environment. 
1. `sbsdb_ut_package_create.sql` - create or update all package specifications and package bodies in the database which are located in the directory `...\test\src\packages` whose names begin with the string `test_`.
1. `sbsdb_ut_package_drop.sql` - drop all packages from the database which are located in the directory `...\test\src\packages` whose names begin with the string `test_`. 
