# Defined type for OdbcDriver
#
# @summary Installation and removal of an OdbcDriver
#
# @param driver 
# Microsoft OdbcDriver name
#
# @param ensure
# Standard puppet ensure
#
# @param source
# Location of OdbcDriver installation msi
#
# @param options
# Installation Options
#
# @example
#   mssql::client::odbc::driver { 'namevar': }
#
define mssql::client::odbc::driver (
  Enum['ODBC Driver 13 for SQL Server','ODBC Driver 17 for SQL Server'] $driver,
  Enum['present','absent'] $ensure,
  String $source,
  Array $options,
) {

  if ($facts['operatingsystem'] == 'windows') {

    package { "Microsoft ${driver}" :
      ensure          => $ensure,
      source          => $source,
      install_options => $options,
      provider        => 'windows',
    }

  } else {

    warn ('Only windows operating system is currently supported, please somebody add `yum`|`apt` sections')

  }
}
