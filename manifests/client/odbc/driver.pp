# Defined type for OdbcDriver
#
# @summary Installation and removal of an OdbcDriver
#
# @driver Microsoft OdbcDriver name
# @ensure Standard puppet ensure
# @source Location of OdbcDriver installation msi
#
# @example
#   mssql::client::odbc::driver { 'namevar': }
define mssql::client::odbc::driver (
  String $driver = $mssql::client::odbc::drivername,
  String $ensure = $mssql::client::odbc::driverensure,
  String $source = $mssql::client::odbc::driversource,
) {

  if ($facts['operatingsystem'] == 'windows') {

    package { "Microsoft ${driver}" :
      ensure          => $ensure,
      source          => $source,
      install_options => [ { 'ADDLOCAL' => 'All' }, { 'IACCEPTMSODBCSQLLICENSETERMS' => 'YES' } ],
      provider        => 'windows',
    }

  } else {

    warn ('Only windows operating system is currently supported, please somebody add `yum`|`apt` sections')

  }
}
