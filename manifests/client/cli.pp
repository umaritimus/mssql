# mssql::client::cli
#
# @summary Initializes SQLCMD
#
# @example
#   include mssql::client::cli
#
class mssql::client::cli () {

  $cli = lookup('mssql.client.cli')
  if (!empty($cli)) {
    $cli.each | String $name, Hash $parameters | {
      $ensure = lookup("mssql.client.cli.'${name}'.ensure")
      $source = lookup("mssql.client.cli.'${name}'.source")
      $options = lookup("mssql.client.cli.'${name}'.options")

      mssql::client::cli::sqlcmd { $name :
        ensure  => $ensure,
        package => $name,
        source  => $source,
        options => $options,
      }
    }
  }
}
