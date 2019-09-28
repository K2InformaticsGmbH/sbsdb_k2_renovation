# Unit Testing

## 1. Introduction

Tests with databases are a challenge in terms of test repeatability.
Therefore in the sbsdb project all test data is generated before each test and then deleted again.
In order to avoid that data of third parties in the database are changed by the unit tests, it is strongly recommended to perform the tests in an empty database. 

The simplest solution for providing an empty database is a suitable docker container with an empty database.
The sbsdb data dictionary is then loaded into this container.

The actual unit tests are done with the test framework [utPLSQL](http://utplsql.org) and the corresponding command line tool [utPLSQL-cli](https://github.com/utPLSQL/utPLSQL-cli).

Unit testing in sbsdb now requires the following steps: 

- Installing the [Docker Toolbox](https://docs.docker.com/toolbox/ "Docker Toolbox") software.
- Creating a Docker virtual machine.
- Creating a Docker image with an empty database.
- Creating a Docker container from the Docker image.
- Load the data dictionary from sbsdb into the Docker container.
- Load the refactored database software from sbsdb into the Docker container.
- Installing [utPLSQL](http://utplsql.org "utPLSQL") in the Docker container.
- Load the unit test packages from sbsdb into the docker container.
- Execute the unit tests.
- Check the test results. 

In following examples it is assumed that the password for the `SYS` schema is `oracle` and the IP address of the Docker container sbsdb is `192.168.99.109`. 

## 2. Installing Docker Toolbox and Docker Virtual Machine

Installing the [Docker Toolbox](https://docs.docker.com/toolbox/ "Docker Toolbox") is preferable to installing [Docker](https://www.docker.com/ "Docker"), otherwise the VirtualBox can no longer be used for other purposes - quote from the Docker documentation:

> After Hyper-V is enabled, VirtualBox no longer works, but any VirtualBox VM images remain. VirtualBox VMs created with docker-machine (including the default one typically created during Toolbox install) no longer start.

To run a Docker container, you:

- create a new (or start an existing) Docker virtual machine
- use the docker client to create, load, and manage containers

Once you create a machine, you can reuse it as often as you like. 
Like any VirtualBox VM, it maintains its configuration between uses.

#### Processing steps:

- Download from [here](https://github.com/docker/toolbox/releases) and install the [Docker Toolbox](https://docs.docker.com/toolbox/toolbox_install_windows/ "Install Docker Toolbox on Windows") software.

- Create a suitable Docker virtual machine from a PowerShell based command window: with the following command: 

    ```docker-machine create -d virtualbox --virtualbox-disk-size "24000" --virtualbox-memory "3072" default```

- With the command `docker-machine ls` the state of the Docker virtual machine can be queried:

![docker-machine ls](https://i.imgur.com/nrfo0yz.png)

- It is a good practice always to terminate the Docker virtual machine when it is no longer needed:

    ```docker-machine stop```

- The start of `Docker Quickstart Terminal` always starts the Docker virtual machine as well. To start or restart the Docker virtual machine manually use the command:

    ```docker-machine start```

## 3. Creation of a Docker Image

This section can be skipped, if the prebuilt Docker image [konnexionsgmbh/db_12_2](https://cloud.docker.com/u/konnexionsgmbh/repository/docker/konnexionsgmbh/db_12_2) should be used with Oracle Database 12c Release 2.
In this case you only have to download the docker image with the command `docker pull konnexionsgmbh/db_12_2` (best with the  `Docker Quickstart Terminal` if the docker demon is not running in the background yet).

#### Processing steps:

- Download Oracle's [docker-images repository](https://github.com/oracle/docker-images "docker-images"). The supported database versions are contained in the directory:
 
    ```..\docker-images\OracleDatabase\SingleInstance\dockerfiles```


- Download the desired version of the database software from the Oracle Website [Technical Reources](https://www.oracle.com/technical-resources/ "Technical Resources from Oracle"). Select the Linux version (64-bit) and place the downloaded `zip` file in the corresponding repository directory. For example for Oracle Database 12c Release 2 the file `linuxx64_12201_database.zip` in the directory:
 
    ```..\docker-images\OracleDatabase\SingleInstance\dockerfiles\12.2.0.1``` 

- Start the `Docker Quickstart Terminal` or start the Docker virtual machine manually, switch to the repository directory `..\docker-images\OracleDatabase\SingleInstance\dockerfiles` and start the corresponding Docker image creation script, e.g. for Oracle Database 12c Release 2: 

    ```./buildDockerImage.sh -v 12.2.0.1 -e -i```

- With the docker command `docker images` the result can be seen:

![docker images -a](https://i.imgur.com/lElHmVC.png)

- Optionally the created Docker image can be tagged, e.g.:

    ```docker tag oracle/database:12.2.0.1-ee konnexionsgmbh/db_12_2```

- and then uploaded to the Docker Hub, e.g.: 

    ```docker push konnexionsgmbh/db_12_2```

## 4. Creation of a Docker Container

For the creation of the Docker container you can use either an existing docker image from [dockerhub](https://hub.docker.com/ "dockerhub") or a self-created docker image as described above.
The following assumes that the docker image [konnexionsgmbh/db_12_2](https://cloud.docker.com/u/konnexionsgmbh/repository/docker/konnexionsgmbh/db_12_2) from [dockerhub](https://hub.docker.com/ "dockerhub") is used. 

#### Processing steps:

- Start the `Docker Quickstart Terminal` or alternatively start the Docker virtual machine in a PowerShell based command window:

    ```docker-machine start```

- Create the Docker container with the following command - if necessary, the database password for SYS etc. may be adjusted using parameter `ORACLE_PWD`:

    ```docker run --name sbsdb -p 1521:1521/tcp -e ORACLE_PWD=oracle konnexionsgmbh/db_12_2```

- In another PowerShell based command window, the result can be checked with the command: 

    ```docker ps -a```

![docker ps -a](https://i.imgur.com/ae6GYcS.png)

- The Docker container`sbsdb` is then to be terminated with the command:  

    ```docker stop sbsdb```

- For any further processing, the Docker container`sbsdb` can then be started again in the background with the command:

    ```docker start sbsdb```

- Conversely, it is always very advisable to stop the Docker container`sbsdb` after processing so that the Oracle database it contains is not destroyed: 

    ```docker stop sbsdb```

- If for any reason you need the IP address of the container, just execute the following command: 

    ```docker-machine ip default```

The created docker container sbsdb now contains an Oracle database version 12c release 2 with the pluggable container orclpdb1. 
The database schema SYS is assigned the password oracle by default. 
A possible entry in the file tnsnames.ora looks like this: 

```
ORCLCDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.109)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orclcdb)
    )
  )

ORCLPDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.99.109)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orclpdb1)
    )
  )
```

## 5. Creating the Data Dictionary for Schema SBS1_ADMIN

The main goal here is to reproduce the database schema SBS1_ADMIN as accurately as possible.
The scripts for creating the Data Dictionary are based on the Export DDL function of Toad (menu: Database -> Export -> Export DDL). 
The scripts created by Toad then had to be simplified, because e.g. the following functionalities cannot be mapped in the new test database to be created:

- file directories,
- remote database access.

This and the following sections assume that the Docker virtual machine and the Docker container `sbsdb` are both already running:

- Start the Docker virtual machine via `Docker Quickstart Terminal` or manually with the command: `docker-machine start`.
- Start the Docker container `sbsdb` with the command: `docker start sbsdb`.

Caution: The `create_schemas.sql` script recreates all affected schemas and deletes them if they already exist.

#### Processing steps:

- Download the [sbsdb repository](https://github.com/K2InformaticsGmbH/sbsdb "sbsdb").

- Switch to the sbsdb repository directory `..\sbsdb\install\schema_skeletons`.

- Start `sqlplus` and execute the script `create_schemas.sql`, for example as follows: 

    ```sqlplus sys/oracle@//192.168.99.109:1521/orclpdb1 as sysdba @create_schemas.sql``` 
 
After executing the script, the necessary database schemas should be created, in particular `SBS0_ADMIN`, `SBS1_ADMIN` and `SBS2_ADMIN`. 
By default all schemas are created with the password `oracle`.

The protocol of a successful installation looks as follows (at first creation the messages for DROP operations are missing):

```

SQL*Plus: Release 12.1.0.2.0 Production on Fr Mai 24 08:50:52 2019

Copyright (c) 1982, 2014, Oracle.  All rights reserved.

Verbunden mit: 
Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

PL/SQL-Prozedur erfolgreich abgeschlossen.

================================================================================
Start clean_up.sql
--------------------------------------------------------------------------------
Session user: SYS
<------------------------------------------------------------------------------>
Processing database links ...
<------------------------------------------------------------------------------>
Executed: DROP DATABASE LINK PPB_RO_DBL.EXASTAG.PIOSCS
Executed: DROP DATABASE LINK SIS_DS_SBS_RW.INT.DBS
<------------------------------------------------------------------------------>
Processing database users ...
<------------------------------------------------------------------------------>
Executed: DROP USER ADMIN CASCADE
Executed: DROP USER DBM_ADMIN CASCADE
Executed: DROP USER SBS0_AAAPROVWS CASCADE
Executed: DROP USER SBS0_ADMIN CASCADE
Executed: DROP USER SBS0_APP CASCADE
Executed: DROP USER SBS0_CPRO CASCADE
Executed: DROP USER SBS1_ADMIN CASCADE
Executed: DROP USER SBS1_APP CASCADE
Executed: DROP USER SBS1_CPRO CASCADE
Executed: DROP USER SBS1_DBL_CENTRUM CASCADE
Executed: DROP USER SBS1_DBL_RA CASCADE
Executed: DROP USER SBS1_SBSWEB CASCADE
Executed: DROP USER SBS2_ADMIN CASCADE
Executed: DROP USER SBS2_APP CASCADE
Executed: DROP USER SBS2_DBL_ILP CASCADE
<------------------------------------------------------------------------------>
Processing profiles ...
<------------------------------------------------------------------------------>
Executed: DROP PROFILE SBS0_ADMIN_P
Executed: DROP PROFILE SBS1_ADMIN_P
Executed: DROP PROFILE SBS2_ADMIN_P
<------------------------------------------------------------------------------>
Processing roles ...
<------------------------------------------------------------------------------>
Executed: DROP ROLE APP_ADMIN_R
Executed: DROP ROLE DBM_ADMIN_CLIENT_R
Executed: DROP ROLE DBM_ADMIN_R
Executed: DROP ROLE SBS_NAVIGATOR_R
Executed: DROP ROLE SBS0_APP_USER_R
Executed: DROP ROLE SBS1_APP_USER_R
Executed: DROP ROLE SBS1_DBL_RA_USER_R
Executed: DROP ROLE SBS1_SBSWEB_USER_R
Executed: DROP ROLE SBS2_APP_USER_R
<------------------------------------------------------------------------------>
Processing synonyms ...
<------------------------------------------------------------------------------>
Executed: DROP PUBLIC SYNONYM CAUGHT_ERROR_DETAILS
Executed: DROP PUBLIC SYNONYM CLOBTAB
Executed: DROP PUBLIC SYNONYM DBM_CAUGHT_ERRORS
Executed: DROP PUBLIC SYNONYM DBM_INSTANCE_SESSIONS
Executed: DROP PUBLIC SYNONYM DBM_INSTANCE_SQL_COMMANDS
Executed: DROP PUBLIC SYNONYM DBM_SERVICE_V$SESSION
Executed: DROP PUBLIC SYNONYM DBM_SESSIONS
Executed: DROP PUBLIC SYNONYM DBM_SQL_COMMANDS
Executed: DROP PUBLIC SYNONYM DBM_UTL
Executed: DROP PUBLIC SYNONYM DBM_V$PARAMETER
Executed: DROP PUBLIC SYNONYM DYNSQL
Executed: DROP PUBLIC SYNONYM KILL_SESSION
Executed: DROP PUBLIC SYNONYM MONITORING_SESSIONS_PER_USER
Executed: DROP PUBLIC SYNONYM TABMGMT
Executed: DROP PUBLIC SYNONYM TABMGMTADM
<------------------------------------------------------------------------------>
Processing tablespaces ...
<------------------------------------------------------------------------------>
--------------------------------------------------------------------------------
End   clean_up.sql
================================================================================
--------------------------------------------------------------------------------
Begin COMMON_ADMIN.sql
================================================================================
--------------------------------------------------------------------------------
End   COMMON_ADMIN.sql
================================================================================
--------------------------------------------------------------------------------
Begin DBM_ADMIN.sql
================================================================================
--------------------------------------------------------------------------------
End   DBM_ADMIN.sql
================================================================================
--------------------------------------------------------------------------------
Begin ADMIN.sql
================================================================================
--------------------------------------------------------------------------------
End   ADMIN.sql
================================================================================
--------------------------------------------------------------------------------
Begin SBS0_ADMIN.sql
================================================================================

Warnung: Funktion wurde mit Kompilierungsfehlern erstellt.


Warnung: Funktion wurde mit Kompilierungsfehlern erstellt.


Warnung: Funktion wurde mit Kompilierungsfehlern erstellt.


Warnung: Funktion wurde mit Kompilierungsfehlern erstellt.


Warnung: Package Body wurde mit Kompilierungsfehlern erstellt.


Warnung: Package Body wurde mit Kompilierungsfehlern erstellt.


Warnung: Funktion wurde mit Kompilierungsfehlern erstellt.


Warnung: Package Body wurde mit Kompilierungsfehlern erstellt.


Warnung: Package Body wurde mit Kompilierungsfehlern erstellt.


Warnung: Package Body wurde mit Kompilierungsfehlern erstellt.


Warnung: Package wurde mit Kompilierungsfehlern erstellt.


Warnung: Package Body wurde mit Kompilierungsfehlern erstellt.


Warnung: Package Body wurde mit Kompilierungsfehlern erstellt.

SP2-0027: Eingabe ist zu lang (mehr als 2499 Zeichen) - Zeile wurde ignoriert
--------------------------------------------------------------------------------
End   SBS0_ADMIN.sql
================================================================================
--------------------------------------------------------------------------------
Begin SBS1_ADMIN.sql
================================================================================

Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: Package Body wurde mit Kompilierungsfehlern erstellt.


Warnung: Package Body wurde mit Kompilierungsfehlern erstellt.


Warnung: Funktion wurde mit Kompilierungsfehlern erstellt.


Warnung: Funktion wurde mit Kompilierungsfehlern erstellt.


Warnung: Funktion wurde mit Kompilierungsfehlern erstellt.


Warnung: Funktion wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.


Warnung: View wurde mit Kompilierungsfehlern erstellt.

--------------------------------------------------------------------------------
End   SBS1_ADMIN.sql
================================================================================
--------------------------------------------------------------------------------
Begin SBS2_ADMIN.sql
================================================================================
--------------------------------------------------------------------------------
End   SBS2_ADMIN.sql
================================================================================
--------------------------------------------------------------------------------
Begin SBS0_ADMIN_2.sql
================================================================================
--------------------------------------------------------------------------------
End   SBS0_ADMIN_2.sql
================================================================================
--------------------------------------------------------------------------------
Begin SBS1_ADMIN_2.sql
================================================================================
--------------------------------------------------------------------------------
End   SBS1_ADMIN_2.sql
================================================================================
--------------------------------------------------------------------------------
End   create_schemas.sql
================================================================================
```

## 6. Installing the Refactored sbsdb Database Software

The refactored source code is located in the directories:

- `..\sbsdb\sbs1\src\functions`,
- `..\sbsdb\sbs1\src\packages`,
- `..\sbsdb\sbs1\src\procedures` etc.

During development, the code generator generated the necessary installation scripts.

#### Processing steps:

- Open a new command window and switch to the sbsdb repository directory `..\sbsdb\sbs1`.

- Run the `run_install_full_docker` script. The script requires the `SYS` and `SBS1_ADMIN` schema passwords.

- The installation process carried out can be checked in the runtime log file `run_install_full_docker.log`.

## 7. Create Unit Test Environment

Unit Testing is based on the test framework [utPLSQL](http://utplsql.org "utPLSQL") and the corresponding command line tool [utPLSQL-cli](https://github.com/utPLSQL/utPLSQL-cli "utPLSQL-cli"). 
The installation of these two tools is done together with the installation of the sbsdb Unit Test packages.
The refactored source code is located in the directories:

- `..\sbsdb\sbs1\test\packages`.

During development, the code generator generated the necessary installation scripts.

#### Processing steps:

- Open a new command window or switch to the sbsdb repository directory `..\sbsdb\sbs1\test`.

- Run the `run_install_ut` script. The script requires the `SYS` and `SBS1_ADMIN` schema passwords.

- The installation process carried out can be checked in the runtime log file `run_install_ut.log`.

## 8. Run Unit Tests

Unit testing consists of two steps: the first step checks the correctness of the program code and the second step checks whether the program code is completely covered by unit tests.

#### Processing steps:

- Open a new command window or switch to the sbsdb repository directory `..\sbsdb\sbs1\test`.

- Run the `run_ut` script. The script requires the `SYS` and `SBS1_ADMIN` schema passwords.

- The success or failure of the unit tests is recorded in the runtime log of the `run_ut` script:

![utPLSQL runtime log](https://i.imgur.com/9qiLa21.png)

- The code coverage can be checked in the HTML file `Cover.html`: 

![utPLSQL Code Coverage](https://i.imgur.com/FZxwNwI.png)

![utPLSQL Code Coverage detailled](https://i.imgur.com/2Qd5fbj.png)
