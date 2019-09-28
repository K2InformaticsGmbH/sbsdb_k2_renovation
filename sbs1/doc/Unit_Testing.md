[Development Guidelines](../Development_Guidelines.md)

## [Unit Testing](../Development_Guidelines.md#development_guidelines_unit_testing)

### 1 Introduction

The fact that code already works does not make unit testing pointless. 
It is just harder to see the value of tests. 
Unit tests should be written as an example use cases of your code. 
Written that way, unit tests become a living documentation for your code.
Tests that are documenting code are eventually becoming the ultimate resource of knowledge about “how the code works”. 
The main difference between unit tests and static documentation for the code is that tests are executable. 
Therefore you can actually validate that every example use case, described by tests is still working.
Well written unit tests become both documentation and safety-harness for your code. 
When a change needs to be done, you can simply go and make a change to the code. 
Unit tests, when executed will validate that all of the existing functionality still works.
The biggest value of unit test is its ability to fail. 
A failing test is allows us to see that something got broken due to a change in the code and therefore the code needs to be fixed.

#### Unit testing private methods

One of the biggest misconceptions in unit testing is this notion that, when you test a package, you should cover each and every method in it with unit tests. 
A logical extension of this thought is to try to cover private methods with tests too. 
Just make them public – not a big deal! – and be done with it. 
Well, that’s a horrible approach to unit testing. 
By exposing methods that you would otherwise keep private, you reveal implementation details. 
And by coupling tests to those implementation details, you get a fragile unit test suite.

When your tests start to know too much about the internals of the system under test (SUT), that leads to false positives during refactoring. 
Which means they won’t act as a safety net anymore and instead will impede your refactoring efforts because of the necessity to refactor them along with the implementation details they are bound to. 
Basically, they will stop fulfilling their main objective: providing you with the confidence in code correctness.

When it comes to unit testing, you need to follow this one rule: **test only the public API of the SUT, don’t expose its implementation details in order to enable unit testing**. 
Your tests should use the SUT the same way its regular clients do, don’t give them any special privileges.

----

### 2 utPLSQL

SBSDB uses utPLSQL as unit testing tool. utPLSQL is a very versatile open source unit testing framework for Oracle PL/SQL.

It allows for automated testing of:

- Packages,
- Functions,
- Procedures.

Anything that can be executed or observed in PL/SQL such as:

- Table Default Values,
- Table Triggers,
- View Triggers,
- Objects.

utPLSQL was originally developed by Steven Feuerstein and is now maintained by an active team of developers.

----

### 3 Coding Test Suites

Unit tests are organized in test suites. 
In SBSDB, there is a corresponding test suite for each package. 
The name of the test suite starts with the string `test_`. 
For example, for the package `sbsdb_api` there is the test suite named `test_sbsdb_api`. 
All test suites are located in the `...\test\src\packages` directory. 
For reasons of clarity, it is strongly recommended to name the individual test methods as the original methods to be tested, possibly with a suffix, e.g. when testing exceptions. 

**Annotations:** Annotations are used to configure tests and suites in a declarative way. 
This way, test configuration is stored along with the test logic inside the test package. 
No configuration files or tables are needed.  
Annotations are interpreted only in the package specification and are case-insensitive. 
It is strongly recommend to use lower-case annotations as described in the documentation. 
There are two distinct types of annotations, identified by their location in package:

- Procedure level annotations - placed directly before a procedure (--%test, --%beforeall, --%beforeeach etc.).
- Package level annotations - placed at any place in package except directly before procedure (--%suite, --%suitepath etc.).

It is also strongly recommend putting package level annotations at the very top of package except for the --%context annotations. 
A detailed documentation for creating test suites can be found in the documentation of utPLSQL [here](http://utplsql.org/utPLSQL/latest/). 
You will also find a quick overview [here](https://www.cheatography.com/jgebal/cheat-sheets/utplsql-v3-1-2/#downloads) that can be used as a cheat sheet.  

The following are a few simple examples of a test suite and variants of test methods.

#### Example 1 - Test suite specification.

```SQL
CREATE OR REPLACE PACKAGE test_sbsdb_api
IS
    /*<>
       Unit testing package sbsdb_api.
    */

    /* =========================================================================
       Public Procedure Declaration.
       ---------------------------------------------------------------------- */

    --%suite([Test package sbsdb_api])
    --%rollback(manual)

    --%test([Test method sbsdb_api.raise_access_denied])
    PROCEDURE raise_access_denied;

    --%test([Test method sbsdb_api.raise_access_denied - exception])
    --%throws(-20008)
    PROCEDURE raise_access_denied_exception;

    --%test([Test method sbsdb_api.scope])
    PROCEDURE scope;
END test_sbsdb_api;
/
```    

#### Example 2 - Test with equality matcher.

Package specification:

```SQL
    --%test([Test method sbsdb_api.scope])
    PROCEDURE scope;
```    
    
Package body:

```SQL
    PROCEDURE scope
    IS
    BEGIN
        ut.expect (sbsdb_api.scope ('package', 'method')).to_ (equal ('package.method'));
        ut.expect (sbsdb_api.scope ('PACKAGE', 'METHOD')).to_ (equal ('package.method'));
        ut.expect (sbsdb_api.scope ('', 'method')).to_ (equal ('.method'));
        ut.expect (sbsdb_api.scope ('package', '')).to_ (equal ('package.'));
        ut.expect (sbsdb_api.scope ('', '')).to_ (equal ('.'));
    END scope;
```    

#### Example 3 - Test with exception.

Package specification:

```SQL
    --%test([Test method sbsdb_api.raise_access_denied - exception])
    --%throws(-20008)
    PROCEDURE raise_access_denied_exception;
```    

Package body:

```SQL
    PROCEDURE raise_access_denied_exception
    IS
    BEGIN
        sbsdb_api.raise_access_denied ('n/a');
    END raise_access_denied_exception;
```    

#### Example 4 - Test with no problems expectation.

Package specification:

```SQL
    --%test([Test method sbsdb_api.raise_access_denied])
    PROCEDURE raise_access_denied;
```    
    
Package body:

```SQL
    PROCEDURE raise_access_denied
    IS
    BEGIN
        sbsdb_api.raise_access_denied ('SBSDB_AC_003DB9DE92AF2E7A472222');
    END raise_access_denied;
```    

----

### 4 Code Generator Support

The code generator supports unit testing by creating the following scripts based on selected existing files in the `...\src\packages` and `...\test\src\packages` directories:

1. `sbsdb_ut_execute_grant_cover.sql` - grant the execute privilege for all packages with an existing package body located in the directory `...\src\packages`.
1. `sbsdb_ut_execute_grant_test.sql` - grant the execute privilege for all packages with an existing package body located in the directory `...\test\src\packages` whose names begin with the string `test_`.
1. `sbsdb_ut_execute_grant_test_swisscom.sql` - same functionality as the previous script, but adapted for the Swisscom environment.
1. `sbsdb_ut_execute_revoke_cover.sql` - revoke the execute privilege for all packages with an existing package body located in the directory `...\src\packages`. 
1. `sbsdb_ut_execute_revoke_test.sql` - revoke the execute privilege for all packages with an existing package body located in the directory `...\test\src\packages` whose names begin with the string `test_`. 
1. `sbsdb_ut_execute_revoke_test_swisscom.sql` - same functionality as the previous script, but adapted for the Swisscom environment. 
1. `sbsdb_ut_package_create.sql` - create or update all package specifications and package bodies in the database which are located in the directory `...\test\src\packages` whose names begin with the string `test_`.
1. `sbsdb_ut_package_drop.sql` - drop all packages from the database which are located in the directory `...\test\src\packages` whose names begin with the string `test_`. 
 
---- 

### 5 Installing the Unit Test Environment

The UT3 schema, the utPLSQL software and the unit test suites are only required in the software development phase. 
The unit test suites will be installed in the SBSDB schema.
The SYS authorization is necessary to install or uninstall utPLSQL and its schema UT3.
If new test suites have been created, the installation script must first be updated by running the code generator again.

The test suites are installed with the `run_install_ut.bat` script. 
The script needs the following parameters:

1. the password of the SYS schema, and
1. the name of the SBSDB schema,
1. the password of the SBSDB schema, and
1. the connect identifier.

The script performs the following steps:

1. uninstall an existing version of utPLSQL and drop the UT3 schema,
1. reinstalling the utPLSQL software in a new UT3 schema,
1. installation of the Unit Test Suites in the SBSDB schema.

The log file `run_install_ut.log` can be used to check whether the installation ran without errors.

There is also the script `run_uninstall_ut.bat` available to drop the test suites, to uninstall the utPLSQL 
software and to drop the UT3 schema when they are no longer needed.
 
---- 

### 6 Running the Unit Test Suites

**Note**: The used version of utPLSQL-cli (command line tool of utPLSQL) requires 
the installation of Java SE Runtime Environment 8.

The unit test suites can be executed in any schema - in the following called 'unit test schema'.
If the unit test schema does not exist yet, it will be created.
The SYS authorization is required to create schemas for testing purposes and 
to create the unit test schema if required.

The test suites are executed with the `run_ut.bat` script. 
The script needs the following parameters:

1. the name of the SYS schema,
1. the name of the unit test schema,
1. the password of the unit test schema,
1. the name of the SBSDB schema,
1. the password of the SBSDB schema, and
1. the connect identifier.

The script performs the following processing steps:

1. creates schemas for testing purposes,
1. creates or updates the unit test schema,
1. grants the unit test schema the execution rights for the test suites,
1. performs the unit tests with the reporter `ut_documentation_reporter`,
1. grants the unit test schema the execution rights for the SBSDB packages,
1. performs the unit tests with the reporter `ut_coverage_html_reporter`,
1. revokes from the unit test schema the execution rights for the SBSDB packages,
1. revokes the unit test schema the execution rights for the test suites, and finally
1. drops the schemas created in the first step.

The output of the reporter `ut_documentation_reporter` looks like this: 

![Coloured Output](https://i.imgur.com/TLZxaTk.jpg)

To get a colored output you have to install the tool ANSICON.

#### Install ANSICON for coloured output:

You can find the ANSICON tool under the following link: https://github.com/adoxa/ansicon.

1. Open CMD in repository directory ...\ansi185\x64.
1. Type ansicon.exe -i and ansicon will be installed.

---- 

### 7 Code Coverage Analysis

utPLSQL comes with a built-in coverage reporting engine. 
The code coverage reporting is based on the DBMS_PROFILER package provided with Oracle database. 
SBSDB code coverage is gathered  only for package bodies.

**Note:** The package specifications are explicitly excluded from code coverage analysis. 
This limitation is introduced to avoid false-negatives. 
Typically package specifications contain no executable code. 
The only exception is initialization of global constants and variables in package specification. 
Since most package specifications are not executable at all, there is no information available on the number of lines covered and those would be reported as 0% covered, which is not desirable.

To obtain information about code coverage of your SBSDB unit tests, all you need to do is run the script `run_ut.bat`. 
The script uses the reporter `ut_coverage_html_reporter`. 
The result is the HTML file `Cover.html` in the directory `...\test`.

In the start window, the analyzed packages are displayed with the corresponding coverage values:

![Coverage Overview](https://i.imgur.com/3PvVviG.jpg)

By clicking on the package name you get an exact overview of the covered (= green) and uncovered (= red) program lines:

![Coverage Detail](https://i.imgur.com/W4eCr5C.jpg)
