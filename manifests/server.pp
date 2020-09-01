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


  if ($ensure == 'present') {

    contain 'mssql::server::install'
    contain 'mssql::server::update'
    contain 'mssql::server::config'

    Class['mssql::server::install'] -> Class['mssql::server::update'] -> Class['mssql::server::config']

  } else {

    contain 'mssql::server::install'

    Class['mssql::server::install']

  }
}
