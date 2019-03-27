
# mssql

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with mssql](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mssql](#beginning-with-mssql)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

Puppet module to install and manage Microsoft SQL Server.  So far it's only a demo of OdbcDriver installation, but later will be expanded...

## Setup

### Setup Requirements

* This module requires `puppetlabs/stdlib` to be present.

### Beginning with mssql

Define requirements in hiera, e.g.:

  ```yaml
  ---
  ...
  mssql::client::ensure: 'present'
  mssql::client::odbc::drivername: 'ODBC Driver 17 for SQL Server'
  mssql::client::odbc::driversource: 'c:/temp/msodbcsql_17.3.1.1_x64.msi'
  ```

  > _Note:_ The ODBCDriver name is fixed.  If you don't specify the correct name, problems will follow you around

## Usage

* Example (when parameters are defined in hiera):

  ```cmd
  puppet apply -e "include ::mssql::client"
  ```

* Example (when used as defined type):

  ```text
  puppet apply -e "mssql::client::odbc::driver { 'ODBC Driver 17 for SQL Server' : ensure => 'present', driver => 'ODBC Driver 17 for SQL Server', source => 'c:/temp/msodbcsql_17.3.1.1_x64.msi',  }"
  ```

## Limitations

* Currently this module only works on Microsoft Windows platform.

## Development

Use Pull Requests to contribute code, please!  Please see [description of how this was developed](CONTRIBUTING.md)