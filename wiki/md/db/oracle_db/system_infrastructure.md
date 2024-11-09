
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [System Infastructure](#system-infastructure)
  - [System groups](#system-groups)
  - [Infrastructure](#infrastructure)
  - [Links](#links)

<!-- /code_chunk_output -->

# System Infastructure

## System groups
After installation it creates 2 group: *SYSDBA* and *SYSOPER*, see more info [here](https://docs.oracle.com/en/database/oracle/oracle-database/19/admqs/administering-user-accounts-and-security.html#GUID-2033E766-8FE6-4FBA-97E0-2607B083FA2C)

When we install from rpm pacakge, it automatically create group oracle user, groups - *oinstall* and *dba* groups

## Infrastructure
**What is Ora Inventory group?**
The physical group you designate as the Oracle Inventory directory is the central inventory of Oracle software installed on your system. It should be the primary group for all Oracle software installation owners. Users who have the Oracle Inventory group as their primary group are granted the OINSTALL privilege to read and write to the central inventory.

If you have an existing installation, then OUI detects the existing oraInventory directory from the/etc/oraInst.loc file, and uses this location.

If you are installing Oracle software for the first time, then you can specify the Oracle inventory directory and the Oracle base directory during the Oracle software installation, and Oracle Universal Installer will set up the software directories for you. Ensure that the directory paths that you specify are in compliance with the Oracle Optimal Flexible Architecture recommendations.

Ensure that the group designated as the OINSTALL group is available as the primary group for all planned Oracle software installation owners.
The Oracle Inventory directory is the central inventory location for all Oracle software installed on a server.

**Naming convension**

Oracle Installation base

/u01/app/oracle - owner is *oracle*. So thar if we have multiple installation, for every installation of Oracle Database we must have a separate owner.

Oracle Grid Installation base

/u01/app/grid - where *grid* - owner.

**Ora Inventory dir for Linux**
The directory that you designate as the Oracle Inventory directory (oraInventory) stores an inventory of all software installed on the system.

All Oracle software installation owners on a server are granted the OINSTALL privileges to read and write to this directory. If you have previous Oracle software installations on a server, then additional Oracle software installations detect this directory from the **/etc/oraInst.loc** file, and continue to use that Oracle Inventory. Ensure that the group designated as the OINSTALL group is available as a primary group for all planned Oracle software installation owners.

If you are installing Oracle software for the first time, then OUI creates an Oracle base and central inventory, and creates an Oracle inventory using information in the following priority:
In the path indicated in the *ORACLE_BASE* environment variable set for the installation owner user account

In an Optimal Flexible Architecture (OFA) path (u[01–99]/app/owner where owner is the name of the user account running the installation), and that user account has permissions to write to that path

In the user home directory, in the path /app/owner, where owner is the name of the user account running the installation

For example:

If you are performing an Oracle Database installation, and you set ORACLE_BASE for user oracle to the path /u01/app/oracle before installation, and grant 755 permissions to oracle for that path, then Oracle Universal Installer creates the Oracle Inventory directory one level above the ORACLE_BASE in the path ORACLE_BASE/../oraInventory, so the Oracle Inventory path is /u01/app/oraInventory. Oracle Universal Installer installs the software in the ORACLE_BASE path. If you are performing an Oracle Grid Infrastructure for a Cluster installation, then the Grid installation path is changed to root ownership after installation, and the Grid home software location should be in a different path from the Grid user Oracle base.

If you create the OFA path /u01, and grant oracle 755 permissions to write to that path, then the Oracle Inventory directory is created in the path /u01/app/oraInventory, and Oracle Universal Installer creates the path /u01/app/oracle, and configures the ORACLE_BASE environment variable for the Oracle user to that path. If you are performing an Oracle Database installation, then the Oracle home is installed under the Oracle base. However, if you are installing Oracle Grid Infrastructure for a cluster, then be aware that ownership of the path for the Grid home is changed to root after installation and the Grid base and Grid home should be in different locations, such as /u01/app/19.0.0/grid for the Grid home path, and /u01/app/grid for the Grid base. For example:
/u01/app/oraInventory, owned by grid:oinstall
/u01/app/oracle, owned by oracle:oinstall
/u01/app/oracle/product/19.0.0/dbhome_1/, owned by oracle:oinistall
/u01/app/grid, owned by grid:oinstall
/u01/app/19.0.0/grid, owned by root

If you have neither set ORACLE_BASE, nor created an OFA-compliant path, then the Oracle Inventory directory is placed in the home directory of the user that is performing the installation, and the Oracle software is installed in the path /app/owner, where owner is the Oracle software installation owner. For example:

**Oracle Grid Infrastructure**

The Oracle Grid Infrastructure for a standalone server is the Oracle software that provides system support for an Oracle database including volume management, file system, and automatic restart capabilities. If you plan to use Oracle Restart or Oracle Automatic Storage Management (Oracle ASM), you must install Oracle Grid Infrastructure before installing your database. Oracle Grid Infrastructure for a standalone server is the software that includes Oracle Restart and Oracle ASM. Oracle combined the two infrastructure products into a single set of binaries that is installed as the Oracle Grid Infrastructure home. Oracle Grid Infrastructure should be installed before installing Oracle Database 11g Release 2.

Oracle ASM is a volume manager and a file system for Oracle database files that supports single-instance Oracle Database and Oracle Real Application Clusters (Oracle RAC) configurations. Oracle ASM also supports a general purpose file system for your application needs including Oracle Database binaries. Oracle ASM is Oracle's recommended storage management solution that provides an alternative to conventional volume managers, file systems, and raw devices.

Oracle Restart improves the availability of your Oracle database by providing the following:

When there is a hardware or a software failure, Oracle Restart automatically starts all Oracle components, including Oracle database instance, Oracle Net Listener, database services, and Oracle ASM.

Oracle Restart starts up components in the proper order when the database host is restarted.

Oracle Restart runs periodic checks to monitor the health of Oracle components. If a check operation fails for a component, then the component is shut down and restarted.

**OFA Infrastructure Sample** See here: https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/optimal-flexible-architecture-file-path-examples.html#GUID-BB3EE4F7-50F4-4A2D-8A0D-96B7CC44029B


## Links
* https://docs.oracle.com/en/database/oracle/oracle-database/19/administration.html
* [About OFA - Optimal Flexible Architecture](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/optimal-flexible-architecture.html#GUID-34434C8B-EBEE-497A-BB92-26B43561B6B1
)

* [About Grid Infrastructure](https://docs.oracle.com/cd/E18185_01/doc/install.112/e16763/oraclerestart.htm)