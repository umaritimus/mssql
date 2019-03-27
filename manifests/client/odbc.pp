# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include mssql::client::odbc
class mssql::client::odbc (
  Enum['ODBC Driver 13 for SQL Server','ODBC Driver 17 for SQL Server'] $drivername,
  String $driversource,
  String $driverensure = $mssql::client::ensure,
) {

  mssql::client::odbc::driver { $drivername :
    ensure => $driverensure,
    driver => $drivername,
    source => $driversource,
  }
}
