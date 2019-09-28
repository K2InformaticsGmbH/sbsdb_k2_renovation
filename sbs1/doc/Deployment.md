# Deployment in the Swisscom Environment

## 1 General Information

The existing SBSDB system is based on a mixture of Java and PL/SQL. 
This will be replaced step by step by a purer PL/SQL solution. 
However, the existing user interfaces must be completely retained. 
For this new development, the new branch 'development' was added to the existing SBSDB repository. 
In order to provide SBSDB customers with the new building blocks, 
the deployment environment described in the next section is made 
available in the branch 'development' with the new SBSDB.

## 2 Usage Deployment

The objects required for deployment in a production environment are located in the `src/deploy` directory and consist of 

- a set of functions, packages and procedures ready to install for the database schema `SBSDB`and
- an installation procedure in KornShell format with supporting sqlplus scripts.

To install the new SBSDB software into an existing SBSDB schema, start the installation script as follows:

    ksh run_install.ksh <schema> <password> <connect_identifier>
    
The installation script executes the following processing steps:
  
- creates the sequences `SBSDB_JOB_SEQ` and `SBSDB_LOG_SEQ` if they do not already exist.
- creates or updates the context `SBSDB_CONTEXT`.
- creates or updates the SBSDB specific type definitions.
- compiles the functions, packages and procedures of the new SBSDB system.
- creates or updates the following Oracle Directory objects and their associated file system directories: `SBSDB_CONFIG_DIR`,  `SBSDB_LOG_DIR`, and  `SBSDB_WORK_DIR`.

The installation script also creates a log file of the same name with the suffix `log`. 

## 3 Unit Test Deployment

**Urgent warning**: It is strongly recommended to install and execute the unit tests only in a pure test environment, because unit tests can in the worst case render the database unusable and in any case there is no guarantee that existing data will not be lost or changed or that test data is still available in the database after the unit tests have been run.

The unit tests for SBSDB are based on the two tools [utPLSQL](http://utplsql.org "utPLSQL") and [utPLSQL-cli](https://github.com/utPLSQL/utPLSQL-cli "utPLSQL-cli"). 

The objects required for the unit tests are located in the `test/src/deploy` directory and consist of 

- a set of test packages ready to install for the database schema `SBSDB`and
- an installation procedure in KornShell format with supporting sqlplus scripts.

To install the test packages into an existing SBSDB schema, start the installation script as follows:

    ksh run_install_ut.ksh <schema> <password> <connect_identifier>
    
The installation script executes the following processing steps:
  
- uninstalls an existing `utPLSQL` tool from schema `UT3`.
- drops the schema `UT3`.
- creates the schema `UT3` and installs the `utPLSQL` tool.
- compiles the test packages of the SBSDB system.

The installation script also creates the log file `run_install_ut.log`. 

## 4 Running Unit Tests

The unit tests are started with the following script:

    ksh run_ut.ksh <schema> <password> <connect_identifier>
    
The tests then run in the given schema and the two following processing steps are carried out: 

1. perform all test procedures and create a detailed record of the test result in the event of success or failure.
2. create a summary and a detailed report on how much of the existing code is covered by unit tests.

The results of step 1 are available on screen and in the log file `run_ut.log` (see 4.1).
The results of step 2 are available in the browser via file `test\Cover.html` (see 4.2 and 4.3). 

### 4.1 Sample output for step 1:

![Monitor screenshot](https://i.imgur.com/yfCqm3g.png)

### 4.2 Sample summary coverage report:

![Summary Coverage](https://i.imgur.com/fOaDM6x.png)

### 4.3 Sample detailed coverage report:

![Detailed Coverage](https://i.imgur.com/RS9bhmz.png)
