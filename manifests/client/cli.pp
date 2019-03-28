# mssql::client::cli
#
# @summary Initializes SQLCMD
#
# @param cliname
# Name of the Microsoft Command Line Utilities - has to be exact, hence enumaration
#
# @param clisource
# Location of the downloaded msi installer
#
# @param cliensure
# Standard puppet ensure, e.g. present, absent, installed, etc
#
# @example
#   include mssql::client::cli
class mssql::client::cli (
  Enum[
    'Microsoft Command Line Utilities 14 for SQL Server',
    'Microsoft Command Line Utilities 15 for SQL Server'
  ] $cliname = 'Microsoft Command Line Utilities 15 for SQL Server',
  String $clisource = 'c:/temp/MsSqlCmdLnUtils.msi',
  String $cliensure = $mssql::client::ensure,
) {

  mssql::client::cli::sqlcmd { $cliname :
    ensure  => $cliensure,
    package => $cliname,
    source  => $clisource,
  }
}
