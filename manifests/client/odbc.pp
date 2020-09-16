# mssql::client::odbc
#
# @summary Initializes OdbcDriver
#
# @example
#   include mssql::client::odbc
#
class mssql::client::odbc () {

  $drivers = lookup('mssql.client.odbc.drivers')
  if (!empty($drivers)) {
    $drivers.each | String $name, Hash $parameters | {
      $ensure = lookup("mssql.client.odbc.drivers.'${name}'.ensure")
      $source = lookup("mssql.client.odbc.drivers.'${name}'.source")
      $options = lookup("mssql.client.odbc.drivers.'${name}'.options")

      mssql::client::odbc::driver { $name :
        ensure  => $ensure,
        driver  => $name,
        source  => $source,
        options => $options,
      }
    }
  }
}
