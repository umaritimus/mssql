# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include mssql::server
class mssql::server (
  String $ensure = 'absent',
  String $source = 'c:/temp/SQLServer2017-x64-ENU-Dev',
) {
  include ::mssql::server::install
}
