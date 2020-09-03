# @summary Base class for installation and configuration of SQL Server
#
# @example
#   include mssql::server
class mssql::server (
  Enum['present','absent'] $ensure = 'absent',
) {

  notify { 'Processing mssql::server' : }

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
