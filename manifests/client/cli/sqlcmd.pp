# Defined type for SQLCMD
#
# @summary Installation and removal of an SQL Server Command Line Utilities
#
# @param package 
# Name of the SQL Server Command Line Utilities package
#
# @param ensure
# Standard puppet ensure
#
# @param source
# Location of SQLCMD installation msi
#
# @example
#   mssql::client::cli::sqlcmd { 'namevar': }
#
define mssql::client::cli::sqlcmd(
  Enum['Microsoft Command Line Utilities 14 for SQL Server','Microsoft Command Line Utilities 15 for SQL Server'] $package,
  String $ensure,
  String $source,
  Array $options,
) {

  if ($facts['operatingsystem'] == 'windows') {

    package { $package :
      ensure          => $ensure,
      source          => $source,
      install_options => $options,
      provider        => 'windows',
    }

    if ($name == 'Microsoft Command Line Utilities 15 for SQL Server') {
      exec { "Add '${name}' to Path" :
        command   => ("
            ${file('mssql/mssql.psm1')}
            New-PathVariable `
              -Path 'C:\\Program Files\\Microsoft SQL Server\\Client SDK\\ODBC\\170\\Tools\\Binn' `
              -Verbose
          "),
        provider  => powershell,
        logoutput => true,
      }

    }

  } else {

    warn ('Only windows operating system is currently supported, please somebody add `yum`|`apt` sections')

  }
}

