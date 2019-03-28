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
  String $package = $mssql::client::cli::cliname,
  String $ensure = $mssql::client::cli::cliensure,
  String $source = $mssql::client::cli::clisource,
) {

  if ($facts['operatingsystem'] == 'windows') {

    package { $package :
      ensure          => $ensure,
      source          => $source,
      install_options => [ { 'ADDLOCAL' => 'All' }, { 'IACCEPTMSSQLCMDLNUTILSLICENSETERMS' => 'YES' } ],
      provider        => 'windows',
    }

  } else {

    warn ('Only windows operating system is currently supported, please somebody add `yum`|`apt` sections')

  }
}

