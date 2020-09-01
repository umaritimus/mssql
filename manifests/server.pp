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
  contain 'mssql::server::install'
  contain 'mssql::server::update'

  if ($ensure == 'present') {
    Class['mssql::server::install'] -> Class['mssql::server::update']
  } else {
    Class['mssql::server::install']
  }
}
