# mssql::client::odbc
#
# @summary Initializes OdbcDriver
#
# @param drivername
# Name of the Microsoft ODBC Driver - has to be exact, hence enumaration
#
# @param driversource
# Location of the downloaded msi installer
#
# @param driverensure
# Standard puppet ensure, e.g. present, absent, installed, etc
#
# @example
#   include mssql::client::odbc
#
class mssql::client::odbc (
  Enum[
    'ODBC Driver 13 for SQL Server',
    'ODBC Driver 17 for SQL Server'
  ] $drivername = 'ODBC Driver 17 for SQL Server',
  String $driversource = 'c:/temp/msodbcsql_17.3.1.1_x64.msi',
  String $driverensure = $mssql::client::ensure,
) {

  mssql::client::odbc::driver { $drivername :
    ensure => $driverensure,
    driver => $drivername,
    source => $driversource,
  }
}
