
# mssql

## Table of Contents

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

This module requires the following modules to be present:

- `puppetlabs/stdlib`
- `puppetlabs/powershell`
- `puppetlabs/pwshlib`
- `puppetlabs/dsc`

### Beginning with mssql module

1. Deploy required puppet modules to your PUPPET_CODE_DIR

```cmd
${PuppetCodedir} = 'c:\ProgramData\PuppetLabs\code\environments'
puppet.bat module install puppetlabs-stdlib --modulepath ${PuppetCodedir}\production\modules --force
puppet.bat module install puppetlabs-powershell --modulepath ${PuppetCodedir}\production\modules --force
puppet.bat module install puppetlabs-pwshlib --modulepath ${PuppetCodedir}\production\modules --force
puppet.bat module install puppetlabs-dsc --modulepath ${PuppetCodedir}\production\modules --force
puppet.bat module install umaritimus-mssql --modulepath ${PuppetCodedir}\production\modules --force
```

2. Define requirements in hiera.  Please see [examples](https://github.com/umaritimus/mssql/tree/master/examples):

3. Run `puppet.bat apply ...`


## Usage

### Example ( Installing SQL Server for a PeopleSoft DPK):

> _Note:_ This implementation utilizes Powershell DSC, which makes it very easy to extend and maintain the module.  However, due to the nature of SQL Server
> installation parameters, the installation itself may demand some experimentation with parameter dependencies.  The following example illustrates 
> the choice of settings that I utilize for PeopleSoft DPK.  The installation parameters within mssql.server.instance hash reflect the dsc 
> equivalents in [MSFT_SqlSetup MOF](https://github.com/puppetlabs/puppetlabs-dsc/blob/main/lib/puppet_x/dsc_resources/SqlServerDsc/DSCResources/MSFT_SqlSetup/MSFT_SqlSetup.psm1).

```yaml

---
psadmin:
  name: 'PeopleSoft Administrator'
  user: 'domain\psadmin'
  password: 'TheD0mainPasswrod4psadminUser!'
  email: 'psadmin@domain.com'

mssql:
  server:
    ensure: 'present'
    source:
      install: '//share/software/SQLServer2019-x64-ENU-Enterprise'
      update : '//share/software/SQLServer2019-KB4563110-x64'
    instance:
      action: 'Install'
      features: 'SQLENGINE'
      instancedir: 'D:\\microsoft'
      instancename: 'MSSQLSERVER'
      sqlcollation: 'Latin1_General_BIN2'
      securitymode: 'SQL'
      sapwd:
        user: 'sa'
        password: "%{::random_password}"
      psdscrunascredential:
        user: "%{lookup('psadmin.user')}"
        password: "%{lookup('psadmin.password')}"
      sqlsysadminaccounts:
        - "%{lookup('psadmin.user')}"
        - 'NT AUTHORITY\SYSTEM'
      agtsvcstartuptype: 'Automatic'
      forcereboot: 'False'
      suppressreboot: 'True'
      browsersvcstartuptype: 'Disabled'
    configuration:
      - 'backup compression default' : 1
      - 'cost threshold for parallelism': 60
      - 'contained database authentication': 1
      - 'Database Mail XPs': 1
    login:
      'sa' :
        logintype: 'SqlLogin'
        disabled: 'True'
      'people' :
        logintype: 'SqlLogin'
        logincredential:
          user: 'people'
          password: 'peop1e'
    maxdop : 2
    tcpport: '1433'
    memory:
      'minmemory': 8192
      'maxmemory': 8192
    firewall:
      allow_remoteaddress:
        - '10.10.10.0/24'
      allow_localport:
        - '1433'
        - '5022'
    email:
      accountname: "%{lookup('psadmin.name')}"
      profilename: "%{lookup('psadmin.name')}"
      address: "%{lookup('psadmin.email')}"
      replytoaddress: "psadmin@domain.com"
      displayname: "%{lookup('psadmin.name')}"
      servername: "smtp.domain.com"
      description:  "%{lookup('psadmin.name')}"
      logginglevel: 'Normal'
      tcpport: 25
    security:
      credentials:
        "%{lookup('psadmin.user')}":
          user: "%{lookup('psadmin.user')}"
          password: "%{lookup('psadmin.password')}"
    linkedservers:
      'HRDB':
        server:    "%{lookup('hr_database_server')}"
        database:  "HRTST"
        login:     "%{lookup('hr_linked_username')}"
        password:  "%{lookup('hr_linked_password')}"
      'FSDB':
        server:    "%{lookup('fs_database_server')}"
        database:  "FSTST"
        login:     "%{lookup('fs_linked_username')}"
        password:  "%{lookup('fs_linked_password')}"
    sqlagent:
      operators:
        "%{lookup('psadmin.name')}":
          name: "%{lookup('psadmin.name')}"
          email: "%{lookup('psadmin.email')}"
      alerts:
        '017':
          name: '017 - Insufficient Resources'
          severity: '17'
          notify: "%{lookup('psadmin.name')}"
        '018' :
          name: '018 - Nonfatal Internal Error'
          severity: '18'
          notify: "%{lookup('psadmin.name')}"
        '019':
          name: '019 - Fatal Error in Resource'
          severity: '19'
          notify: "%{lookup('psadmin.name')}"
        '020' :
          name: '020 - Fatal Error in Current Process'
          severity: '20'
          notify: "%{lookup('psadmin.name')}"
        '021':
          name: '021 - Fatal Error in Database Processes'
          severity: '21'
          notify: "%{lookup('psadmin.name')}"
        '022' :
          name: '022 - Fatal Error: Table Integrity Suspect'
          severity: '22'
          notify: "%{lookup('psadmin.name')}"
        '023':
          name: '023 - Fatal Error: Database Integrity Suspect'
          severity: '23'
          notify: "%{lookup('psadmin.name')}"
        '024' :
          name: '024 - Fatal Error: Hardware Error'
          severity: '24'
          notify: "%{lookup('psadmin.name')}"
        '025':
          name: '025 - Fatal Error'
          severity: '25'
          notify: "%{lookup('psadmin.name')}"
      proxies:
        "%{lookup('psadmin.user')}":
          - 'Powershell'
          - 'CmdExec'

```

> _Note:_ The `ensure='absent'` functionality is presently not implemented within DSC... probably because the only feasible way to completely 
> remove Sql Server is to utilize a pack of plastic explosives.  In the meantime, our uninstallation is implemented using the native setup 
> command. Just simply toggle the `mssql.server.ensure:` to `'absent'` and rerun the `include ::mssql::server`.

```cmd
puppet apply -e "include ::mssql::server"
```

The output should look similar to:

```text
Notice: Compiled catalog for demo.domain.com in environment production in 1.84 seconds
Notice: Processing mssql::server
Notice: /Stage[main]/Mssql::Server/Notify[Processing mssql::server]/message: defined 'message' as 'Processing mssql::server'
Notice: Processing mssql::server::install
Notice: /Stage[main]/Mssql::Server::Install/Notify[Processing mssql::server::install]/message: defined 'message' as 'Processing mssql::server::install'
Notice: /Stage[main]/Mssql::Server::Install/Dsc_sqlsetup[Install SQL Server]/ensure: created
Notice: Processing mssql::server::update
Notice: /Stage[main]/Mssql::Server::Update/Notify[Processing mssql::server::update]/message: defined 'message' as 'Processing mssql::server::update'
Notice: /Stage[main]/Mssql::Server::Update/Exec[Apply SQL Server Cumulative Update]/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Update/Exec[Apply SQL Server Cumulative Update]/returns: executed successfully
Notice: Processing mssql::server::config
Notice: /Stage[main]/Mssql::Server::Config/Notify[Processing mssql::server::config]/message: defined 'message' as 'Processing mssql::server::config'
Notice: /Stage[main]/Mssql::Server::Config/Dsc_sqlserverlogin[sa]/ensure: created
Notice: /Stage[main]/Mssql::Server::Config/Dsc_sqlserverlogin[people]/ensure: created
Notice: /Stage[main]/Mssql::Server::Config/Dsc_sqlserverconfiguration[backup compression default]/ensure: created
Notice: /Stage[main]/Mssql::Server::Config/Dsc_sqlserverconfiguration[cost threshold for parallelism]/ensure: created
Notice: /Stage[main]/Mssql::Server::Config/Dsc_sqlserverconfiguration[contained database authentication]/ensure: createdNotice: /Stage[main]/Mssql::Server::Config/Dsc_sqlserverconfiguration[Database Mail XPs]/ensure: created
Notice: /Stage[main]/Mssql::Server::Config/Dsc_sqlserverdatabasemail[Enable Database Mail]/ensure: created
Notice: /Stage[main]/Mssql::Server::Config/Dsc_sqlservermaxdop[Set MAXDOP to 2]/ensure: created
Notice: /Stage[main]/Mssql::Server::Config/Dsc_sqlservermemory[Set Sql Server Memory to 8192]/ensure: created
Notice: /Stage[main]/Mssql::Server::Config/Notify[Processing mssql::server::config]/message: defined 'message' as 'Processing mssql::server::config'
Notice: /Stage[main]/Mssql::Server::Config/Dsc_firewall[Create SQL Server Firewall Rule]/ensure: created
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '017 - Insufficient Resources' to 'PeopleSoft Administrator']/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '017 - Insufficient Resources' to 'PeopleSoft Administrator']/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '018 - Nonfatal Internal Error' to 'PeopleSoft Administrator']/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '018 - Nonfatal Internal Error' to 'PeopleSoft Administrator']/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '019 - Fatal Error in Resource' to 'PeopleSoft Administrator']/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '019 - Fatal Error in Resource' to 'PeopleSoft Administrator']/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '020 - Fatal Error in Current Process' to 'PeopleSoft Administrator']/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '020 - Fatal Error in Current Process' to 'PeopleSoft Administrator']/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '021 - Fatal Error in Database Processes' to 'PeopleSoft Administrator']/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '021 - Fatal Error in Database Processes' to 'PeopleSoft Administrator']/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '022 - Fatal Error: Table Integrity Suspect' to 'PeopleSoft Administrator']/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '022 - Fatal Error: Table Integrity Suspect' to 'PeopleSoft Administrator']/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '023 - Fatal Error: Database Integrity Suspect' to 'PeopleSoft Administrator']/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '023 - Fatal Error: Database Integrity Suspect' to 'PeopleSoft Administrator']/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '024 - Fatal Error: Hardware Error' to 'PeopleSoft Administrator']/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '024 - Fatal Error: Hardware Error' to 'PeopleSoft Administrator']/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '025 - Fatal Error' to 'PeopleSoft Administrator']/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Alert for '025 - Fatal Error' to 'PeopleSoft Administrator']/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Linked Server for PSHRPRDDB01]/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Linked Server for PSHRPRDDB01]/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Linked Server for PSFSPRDDB01]/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Linked Server for PSFSPRDDB01]/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Credential for domain\psadmin]/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Add Credential for domain\psadmin]/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Register 'Powershell' subsystem to 'domain\psadmin' proxy account]/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Register 'Powershell' subsystem to 'domain\psadmin' proxy account]/returns: executed successfully
Notice: /Stage[main]/Mssql::Server::Config/Exec[Register 'CmdExec' subsystem to 'domain\psadmin' proxy account]/returns: [output redacted]
Notice: /Stage[main]/Mssql::Server::Config/Exec[Register 'CmdExec' subsystem to 'domain\psadmin' proxy account]/returns: executed successfully
Notice: Applied catalog in 304.53 seconds
```


### Example ( Installing client when parameters are defined in hiera ):

```yaml
---
...
mssql::client::ensure: 'present'
mssql::client::odbc::drivername: 'ODBC Driver 17 for SQL Server'
mssql::client::odbc::driversource: 'c:/temp/msodbcsql_17.3.1.1_x64.msi'
```
> _Note:_ The OdbcDriver name needs to be exact, as defined by Microsoft.  If you don't specify the correct name, problems will follow you around, e.g. during DSN creation...

```cmd
puppet apply -e "include ::mssql::client"
```

> _Note:_ The SQL Client is only really needed, if not installing SQL Server, as SQL client already contains all client pieces. 

### Example ( Installing OdbcDriver, when used as defined type ):

```cmd
puppet apply -e "mssql::client::odbc::driver { 'ODBC Driver 17 for SQL Server' : ensure => 'present', driver => 'ODBC Driver 17 for SQL Server', source => 'c:/temp/msodbcsql_17.3.1.1_x64.msi',  }"
```

### Example ( Installing sqlcmd )

> _Note:_ `Microsoft Command Line Utilities for SQL Server` package has a prerequisite of `Microsoft ODBC Driver` and a modern `.NET` libraries to be already installed

```cmd
puppet apply -e "mssql::client::cli::sqlcmd { 'Add sqlcmd' : package => 'Microsoft Command Line Utilities 15 for SQL Server', ensure => 'present', source => 'c:/temp/MsSqlCmdLnUtils.msi', }"
```

### Example ( Uninstalling sqlcmd )

```cmd
puppet apply -e "mssql::client::cli::sqlcmd { 'Remove sqlcmd' : package => 'Microsoft Command Line Utilities 15 for SQL Server', ensure => 'absent', source => 'c:/temp/MsSqlCmdLnUtils.msi', }"
```


## Changelog

For updates please see the [changelog](https://github.com/umaritimus/mssql/blob/master/CHANGELOG.md)


## Limitations

* Currently this module only works on Microsoft Windows platform.
* It has been tested with `Microsoft SQL Server 2017` and `Microsoft SQL Server 2019`
* Linked servers are only implemented for SQL Servers
* FCI and AG high availability configurations have not been fully implemented or tested.


## Upcoming features

* Startup Parameters and Trace Flags
* Hide sensitive data at `--debug --trace --verbose` (or not, since it may be useful for debugging)


## Development

Use Pull Requests to contribute code, please!  Please see [description of how this was developed](https://github.com/umaritimus/mssql/blob/master/CONTRIBUTING.md)