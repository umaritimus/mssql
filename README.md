
# mssql

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with mssql](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mssql](#beginning-with-mssql)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Changelog - what's new](#changelog)
1. [Limitations - OS compatibility, etc.](#limitations)

## Description

Puppet module to install and manage Microsoft SQL Server.

## Setup

### Setup Requirements

* This module requires `puppetlabs/stdlib` and `puppetlabs/inifile` to be present.

### Beginning with mssql

Define requirements in hiera, e.g.:

  ```yaml
  ---
  ...
  mssql::client::ensure: 'present'
  mssql::client::odbc::drivername: 'ODBC Driver 17 for SQL Server'
  mssql::client::odbc::driversource: 'c:/temp/msodbcsql_17.3.1.1_x64.msi'
  ```

  > _Note:_ The OdbcDriver name needs to be exact, as defined by Microsoft.  If you don't specify the correct name, problems will follow you around, e.g. during DSN creation...

## Usage

* Example ( Installing/Uninstalling SQL Server ):

```cmd

puppet apply -e "include ::mssql::server"

```

> _Note:_ Ensure that you are specifying correct parameters for your sql server version.  The settings are stored in `mssql::server::install::settings` hash.  The values are those that are used in `ConfigurationFile.ini` (why reinvent the wheel). So
specify the settings that you need for your configuration and the setup will take care of them for you.  Using this methodology guarantees compatibility with all sql server versions that have capabilities of command-line installation. However, ensure that your parameter values are properly enclosed in quotes and contain backslashes (in windows), see `INSTANCEDIR` and `SQLSYSADMINACCOUNTS` in the configuration example below:

```yaml

---
...
mssql::server::source: 'c:/temp/SQLServer2017-x64-ENU-Dev'
mssql::server::ensure: 'present'
mssql::server::install::settings:
  'OPTIONS':
    'ACTION': "Install"
    'FEATURES': "SQLENGINE"
    'INSTANCENAME': "MSSQLSERVER"
    'INSTANCEDIR': "\"c:\\Program Files\\Microsoft SQL Server\""
    'QUIET': "True"
    'IACCEPTSQLSERVERLICENSETERMS': "True"
    'SQLSYSADMINACCOUNTS': "\"domain\\adminuser1\" \"domain\\adminuser2\" \"domain\\admingroup1\""
    'INDICATEPROGRESS': "True"
    'UPDATEENABLED': "False"

```

> _Note:_ To run the uninstall, you can rewrite the `OPTIONS` subhash, but you really don't have to... You can just simply toggle the `mssql::server::ensure:` to `'absent'`.  and rerun the `include ::mssql::server`

* Example ( Installing client when parameters are defined in hiera ):

```cmd

puppet apply -e "include ::mssql::client"

```

* Example ( Installing OdbcDriver, when used as defined type ):

```cmd

puppet apply -e "mssql::client::odbc::driver { 'ODBC Driver 17 for SQL Server' : ensure => 'present', driver => 'ODBC Driver 17 for SQL Server', source => 'c:/temp/msodbcsql_17.3.1.1_x64.msi',  }"
  
```

* Example ( Installing sqlcmd )

> _Note:_ `Microsoft Command Line Utilities for SQL Server` package has a prerequisite of `Microsoft ODBC Driver` and a modern `.NET` libraries to be already installed

```cmd

puppet apply -e "mssql::client::cli::sqlcmd { 'Add sqlcmd' : package => 'Microsoft Command Line Utilities 15 for SQL Server', ensure => 'present', source => 'c:/temp/MsSqlCmdLnUtils.msi', }"
  
```

* Example ( Uninstalling sqlcmd )

```cmd

puppet apply -e "mssql::client::cli::sqlcmd { 'Remove sqlcmd' : package => 'Microsoft Command Line Utilities 15 for SQL Server', ensure => 'absent', source => 'c:/temp/MsSqlCmdLnUtils.msi', }"
  
```

## Changelog

For updates please see the [changelog](https://github.com/umaritimus/mssql/blob/master/CHANGELOG.md)

## Limitations

* Currently this module only works on Microsoft Windows platform.
* It has only been tested with `Microsoft SQL Server 2017, Developer edition`
* It has been developed and tested using `Open Source Puppet 5.5.10` and `pdk 1.7.0`

## Development

Use Pull Requests to contribute code, please!  Please see [description of how this was developed](https://github.com/umaritimus/mssql/blob/master/CONTRIBUTING.md)