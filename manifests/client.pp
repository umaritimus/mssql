# mssql::client
#
# @summary Standard constructor
#
# @param ensure
# Standard puppet ensure, e.g. present, absent, installed, etc
#
# @example
#   include mssql::client
class mssql::client (
  String $ensure = 'absent'
) {
  include ::mssql::client::odbc
  include ::mssql::client::cli

  Class[::mssql::client::odbc]
  -> exec { "wait for odbc" : command => 'Start-Sleep -Seconds 10', provider => 'powershell', }
  -> Class[::mssql::client::cli]
}
