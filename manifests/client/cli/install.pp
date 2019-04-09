# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include mssql::client::cli::install
class mssql::client::cli::install (
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
